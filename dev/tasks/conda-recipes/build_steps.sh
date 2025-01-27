#!/usr/bin/env bash

# NOTE: This script has been slightly adopted to suite the Apache Arrow / crossbow CI
# 	setup. The next time this is updated to the current version on conda-forge,
#       you will also make this additions afterwards.

# PLEASE NOTE: This script has been automatically generated by conda-smithy. Any changes here
# will be lost next time ``conda smithy rerender`` is run. If you would like to make permanent
# changes to this script, consider a proposal to conda-smithy so that other feedstocks can also
# benefit from the improvement.

set -xeuo pipefail

output_dir=${1}

export PYTHONUNBUFFERED=1
export FEEDSTOCK_ROOT="${FEEDSTOCK_ROOT:-/home/conda/feedstock_root}"
export CI_SUPPORT="${FEEDSTOCK_ROOT}/.ci_support"
export CONFIG_FILE="${CI_SUPPORT}/${CONFIG}.yaml"

cat >~/.condarc <<CONDARC

conda-build:
 root-dir: ${output_dir}

CONDARC

mamba install --update-specs --yes --quiet "conda-forge-ci-setup=3" conda-build pip boa -c conda-forge
mamba update --update-specs --yes --quiet "conda-forge-ci-setup=3" conda-build pip boa -c conda-forge

# set up the condarc
setup_conda_rc "${FEEDSTOCK_ROOT}" "${FEEDSTOCK_ROOT}" "${CONFIG_FILE}"

source run_conda_forge_build_setup

# make the build number clobber
make_build_number "${FEEDSTOCK_ROOT}" "${FEEDSTOCK_ROOT}" "${CONFIG_FILE}"

if [[ "${HOST_PLATFORM}" != "${BUILD_PLATFORM}" ]] && [[ "${HOST_PLATFORM}" != linux-* ]] && [[ "${BUILD_WITH_CONDA_DEBUG:-0}" != 1 ]]; then
    EXTRA_CB_OPTIONS="${EXTRA_CB_OPTIONS:-} --no-test"
fi

export CONDA_BLD_PATH="${output_dir}"

conda mambabuild \
    "${FEEDSTOCK_ROOT}/arrow-cpp" \
    "${FEEDSTOCK_ROOT}/parquet-cpp" \
    -m "${CI_SUPPORT}/${CONFIG}.yaml" \
    --clobber-file "${CI_SUPPORT}/clobber_${CONFIG}.yaml" \
    --output-folder "${output_dir}" \
    ${EXTRA_CB_OPTIONS:-}

if [ ! -z "${R_CONFIG:-}" ]; then
  conda mambabuild \
      "${FEEDSTOCK_ROOT}/r-arrow" \
      -m "${CI_SUPPORT}/r/${R_CONFIG}.yaml" \
      --output-folder "${output_dir}" \
      ${EXTRA_CB_OPTIONS:-}
fi


touch "${output_dir}/conda-forge-build-done-${CONFIG}"
