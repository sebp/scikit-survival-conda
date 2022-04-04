#!/bin/bash
# adapted from https://github.com/conda-forge/conda-forge-ci-setup-feedstock/blob/master/recipe/run_conda_forge_build_setup_osx

if [[ ! -d "/Applications" ]]; then
    exit 0
fi

export CPU_COUNT=2

export PYTHONUNBUFFERED=1

export MACOSX_DEPLOYMENT_TARGET="${1:-10.9}"

OSX_SDK_DIR="$(xcode-select -p)/Platforms/MacOSX.platform/Developer/SDKs"
export CONDA_BUILD_SYSROOT="${OSX_SDK_DIR}/MacOSX${MACOSX_DEPLOYMENT_TARGET}.sdk"

if [[ ! -d "${CONDA_BUILD_SYSROOT}" || "${OSX_FORCE_SDK_DOWNLOAD}" == "1" ]]; then
    echo "Downloading ${MACOSX_DEPLOYMENT_TARGET} sdk"
    curl -L -O https://github.com/phracker/MacOSX-SDKs/releases/download/11.3/MacOSX${MACOSX_DEPLOYMENT_TARGET}.sdk.tar.xz
    mkdir -p "$(dirname "$CONDA_BUILD_SYSROOT")"
    tar -xf MacOSX${MACOSX_DEPLOYMENT_TARGET}.sdk.tar.xz -C "$(dirname "$CONDA_BUILD_SYSROOT")"
fi

if [[ "${MACOSX_DEPLOYMENT_TARGET}" == 10.* && "${USING_SYSTEM_SDK_DIR:-}" == "1" ]]; then
    # set minimum sdk version to our target
    plutil -replace MinimumSDKVersion -string ${MACOSX_DEPLOYMENT_TARGET} $(xcode-select -p)/Platforms/MacOSX.platform/Info.plist
    plutil -replace DTSDKName -string macosx${MACOSX_DEPLOYMENT_TARGET}internal $(xcode-select -p)/Platforms/MacOSX.platform/Info.plist
fi

if [ -d "${CONDA_BUILD_SYSROOT}" ]
then
    echo "Found CONDA_BUILD_SYSROOT: ${CONDA_BUILD_SYSROOT}"
else
    echo "Missing CONDA_BUILD_SYSROOT: ${CONDA_BUILD_SYSROOT}"
    exit 1
fi
