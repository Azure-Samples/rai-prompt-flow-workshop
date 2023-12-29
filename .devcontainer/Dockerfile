FROM mcr.microsoft.com/devcontainers/miniconda:0-3
# System packages 
RUN apt-get update && apt-get install -y curl

# needed for build_mlindex
RUN apt update && apt install -y fuse

# Install mamba
RUN conda install -n base -c conda-forge mamba

#Choose your version of azcli
RUN echo "pip install azure-cli" | bash
#Choose your version of ml cli
RUN echo "az extension add -n ml" | bash 
RUN echo "pip install azure-ml==0.0.139 --extra-index-url https://azuremlsdktestpypi.azureedge.net/sdk-cli-v2" | bash


# This is to support updating conda environment with user supplied packages with environment.yml
COPY environment.yml* .devcontainer/noop.txt /tmp/conda-tmp/
RUN if [ -f "/tmp/conda-tmp/environment.yml" ]; then umask 0002 && /opt/conda/bin/mamba env create -f /tmp/conda-tmp/environment.yml; fi \
    && rm -rf /tmp/conda-tmp