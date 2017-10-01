#!/usr/bin/env bash
set -ve

wget https://raw.githubusercontent.com/pelson/Obvious-CI/master/bootstrap-obvious-ci-and-miniconda.py
python bootstrap-obvious-ci-and-miniconda.py ~/miniconda x64 3 --without-obvci && source ~/miniconda/bin/activate root

conda config --set show_channel_urls true
conda config --set add_pip_as_python_dependency false
conda config --add channels sebp

conda update -n root --yes --quiet conda conda-env
conda install -n root --yes --quiet anaconda-client conda-build setuptools

conda info
conda config --get

export PATH=~/miniconda/bin:$PATH
