FROM python:3.7

COPY . /jumeaux
RUN pip install /jumeaux
WORKDIR tmp

ENTRYPOINT ["jumeaux"]

