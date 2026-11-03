FROM rocker/r-ver:4.5.1

WORKDIR /project

RUN /rocker_scripts/install_python.sh

RUN export DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y git python3-venv

# venv evita o erro "externally-managed-environment" (PEP 668) do Ubuntu 24.04
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
COPY DESCRIPTION .

RUN pip install --upgrade pip setuptools wheel
RUN pip install -r requirements.txt
RUN Rscript -e "install.packages('renv')" && Rscript -e 'renv::install()'
