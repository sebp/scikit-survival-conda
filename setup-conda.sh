#!/bin/bash

RUNNER_OS="${1}"
RUNNER_ARCH="${2}"

run_check_sha() {
    echo "${1}" | shasum -a 256 --check --strict -
}

if [[ "${CONDA:-}" = "" ]]; then
    # download and install conda
    MINICONDA_VERSION="Miniconda3-py312_24.1.2-0"

    if [[ "${RUNNER_OS}" = "macOS" ]] && [[ "${RUNNER_ARCH}" = "ARM64" ]]; then
        MINICONDA_VERSION="${MINICONDA_VERSION}-MacOSX-arm64"
        MINICONDA_HASH="1c277b1ec046fd1b628390994e3fa3dbac0e364f44cd98b915daaa67a326c66a"
    elif [[ "${RUNNER_OS}" = "macOS" ]] && [[ "${RUNNER_ARCH}" = "X64" ]]; then
        MINICONDA_VERSION="${MINICONDA_VERSION}-MacOSX-x86_64"
        MINICONDA_HASH="bc45a2ceea9341579532847cc9f29a9769d60f12e306bba7f0de6ad5acdd73e9"
    elif [[ "${RUNNER_OS}" = "Linux" ]] && [[ "${RUNNER_ARCH}" = "X64" ]]; then
        MINICONDA_VERSION="${MINICONDA_VERSION}-Linux-x86_64"
        MINICONDA_HASH="b978856ec3c826eb495b60e3fffe621f670c101150ebcbdeede4f961f22dc438"
    else
        echo "Unsupported OS or ARCH: ${RUNNER_OS} ${RUNNER_ARCH}"
        exit 1
    fi

    export CONDA="${RUNNER_TEMP}/miniconda3"

    mkdir -p "${CONDA}" && \
    curl "https://repo.anaconda.com/miniconda/${MINICONDA_VERSION}.sh" -o "${CONDA}/miniconda.sh" && \
    run_check_sha "${MINICONDA_HASH}  ${CONDA}/miniconda.sh" && \
    bash "${CONDA}/miniconda.sh" -b -u -p "${CONDA}" && \
    rm -rf "${CONDA}/miniconda.sh" || exit 1

    echo "CONDA=${CONDA}" >> "${GITHUB_ENV}"
fi

"${CONDA}/bin/conda" config --set always_yes yes && \
"${CONDA}/bin/conda" config --set changeps1 no && \
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

echo "${CONDA}" >> "${GITHUB_PATH}"

"${CONDA}/bin/conda" info --all
"${CONDA}/bin/conda" config --show
