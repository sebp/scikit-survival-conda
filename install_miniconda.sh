#!/usr/bin/env bash
set -ve

curl -fsSL https://raw.githubusercontent.com/pelson/Obvious-CI/master/bootstrap-obvious-ci-and-miniconda.py > bootstrap-obvious-ci-and-miniconda.py
python bootstrap-obvious-ci-and-miniconda.py ~/miniconda x64 3 --without-obvci && source ~/miniconda/bin/activate base

conda config --set show_channel_urls true
conda config --set add_pip_as_python_dependency false
conda config --add channels sebp

conda update -n base -c defaults --yes --quiet conda
conda install -n base --yes --quiet anaconda-client conda-build setuptools

conda info
conda config --get
