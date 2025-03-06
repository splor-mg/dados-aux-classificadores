FROM rocker/r-ver:4.3.1

WORKDIR /project

RUN /rocker_scripts/install_python.sh

RUN export DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y git

RUN echo 'alias python=python3' >> /etc/bash.bashrc

COPY requirements.txt .
COPY DESCRIPTION .

RUN python3 -m pip install --upgrade pip setuptools wheel
RUN python3 -m pip install -r requirements.txt
RUN Rscript -e "install.packages('renv')" && Rscript -e 'renv::install()'
