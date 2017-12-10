MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help

.PHONY: $(shell egrep -oh ^[a-zA-Z0-9][a-zA-Z0-9_-]+: $(MAKEFILE_LIST) | sed 's/://')

help: ## Print this help
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9][a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

#------

init: ## Intialize develop environment
	@echo Start $@
	@pipenv install -d
	@echo End $@

build-docs: ## Build documentation
	@echo Start $@
	@pipenv run mkdocs serve -a 0.0.0.0:8000
	@echo End $@

package-docs: ## Package documentation
	@echo Start $@
	@pipenv run mkdocs build
	@echo End $@

test: ## Test
	@echo Start $@
	@pipenv run pytest
	@echo End $@

release: init package-docs ## Release (Not push anywhere)
	@echo '1. Recreate `jumeaux/__init__.py`'
	@echo "__version__ = '$(version)'" > jumeaux/__init__.py
	
	@echo '2. Recreate `Dockerfile`'
	@cat template/Dockerfile | sed -r 's/VERSION/$(version)/g' > Dockerfile
	
	@echo '3. Staging and commit'
	git add jumeaux/__init__.py
	git add Dockerfile
	git add docs
	git commit -m ':package: Version $(version)'
	
	@echo '4. Tags'
	git tag $(version) -m $(version)
	
	@echo 'Success All!!'
	@echo 'Now you should only do `git push`!!'

