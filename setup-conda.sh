#!/bin/bash

RUNNER_OS="${1}"
RUNNER_ARCH="${2}"

run_check_sha() {
    echo "${1}" | shasum -a 256 --check --strict -
}

if [[ "${CONDA:-}" = "" ]]; then
    # download and install conda
    MINICONDA_VERSION="Miniconda3-py311_23.11.0-2"

    if [[ "${RUNNER_OS}" = "macOS" ]] && [[ "${RUNNER_ARCH}" = "ARM64" ]]; then
        MINICONDA_VERSION="${MINICONDA_VERSION}-MacOSX-arm64"
        MINICONDA_HASH="5694c382e6056d62ed874f22692224c4f53bca22e8135b6f069111e081be07aa"
    elif [[ "${RUNNER_OS}" = "macOS" ]] && [[ "${RUNNER_ARCH}" = "X64" ]]; then
        MINICONDA_VERSION="${MINICONDA_VERSION}-MacOSX-x86_64"
        MINICONDA_HASH="2b7f9e46308c28c26dd83abad3e72121ef63916eaf17b63723b5a1f728dc3032"
    elif [[ "${RUNNER_OS}" = "Linux" ]] && [[ "${RUNNER_ARCH}" = "X64" ]]; then
        MINICONDA_VERSION="${MINICONDA_VERSION}-Linux-x86_64"
        MINICONDA_HASH="c9ae82568e9665b1105117b4b1e499607d2a920f0aea6f94410e417a0eff1b9c"
    else
        echo "Unsupported OS or ARCH: ${RUNNER_OS} ${RUNNER_ARCH}"
        exit 1
    fi

    export CONDA="${GITHUB_WORKSPACE}/miniconda3"

    mkdir -p "${CONDA}" && \
    curl "https://repo.anaconda.com/miniconda/${MINICONDA_VERSION}.sh" -o "${CONDA}/miniconda.sh" && \
    run_check_sha "${MINICONDA_HASH}  ${CONDA}/miniconda.sh" && \
    bash "${CONDA}/miniconda.sh" -b -u -p "${CONDA}" && \
    rm -rf "${CONDA}/miniconda.sh" || exit 1

    echo "CONDA=${CONDA}" >> "${GITHUB_ENV}"
fi

"${CONDA}/bin/conda" config --set always_yes yes --set changeps1 no && \
"${CONDA}/bin/conda" config --set auto_update_conda false && \
"${CONDA}/bin/conda" config --set show_channel_urls true && \
"${CONDA}/bin/conda" config --set add_pip_as_python_dependency false && \
"${CONDA}/bin/conda" config --set conda_build.pkg_format 2 && \
"${CONDA}/bin/conda" config --add channels sebp || \
exit 1

sudo "${CONDA}/bin/conda" update -q -n base conda && \
sudo "${CONDA}/bin/conda" install -q -n base anaconda-client conda-build && \
sudo chown -R "${USER}" "${CONDA}" || \
exit 1

"${CONDA}/bin/conda" info --all
"${CONDA}/bin/conda" config --show
