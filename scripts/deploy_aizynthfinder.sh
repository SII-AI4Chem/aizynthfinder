#!/usr/bin/env bash
# Simple end-to-end deployment helper for AiZynthFinder.
#
# This script creates an isolated Python virtual environment, installs
# AiZynthFinder with optional extras, downloads the public data bundle,
# prepares an example SMILES list, and finally runs `aizynthcli` once to
# validate that everything works.
#
# Usage:
#   ./scripts/deploy_aizynthfinder.sh [data_dir] [smiles_file]
#
# - data_dir:   Directory for downloaded models and generated config (default: ~/aizynth-data)
# - smiles_file:Path to a SMILES input file (default: ./example_smiles.txt)
#
# The script is idempotent. Re-running it will reuse the created virtual
# environment and downloaded data if they already exist.

set -euo pipefail

# Make sure we run from the project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${PROJECT_ROOT}"

VENV_DIR="${PROJECT_ROOT}/.aizynthfinder-venv"
DATA_DIR="${1:-$HOME/aizynth-data}"
SMILES_FILE="${2:-${PROJECT_ROOT}/example_smiles.txt}"
PYTHON_BIN=${PYTHON_BIN:-python3}

function ensure_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "[ERROR] Required command '$1' not found in PATH." >&2
        exit 1
    fi
}

ensure_command "${PYTHON_BIN}"

if [[ ! -d "${VENV_DIR}" ]]; then
    echo "[INFO] Creating virtual environment at ${VENV_DIR}".
    "${PYTHON_BIN}" -m venv "${VENV_DIR}"
fi

# shellcheck source=/dev/null
source "${VENV_DIR}/bin/activate"

pip install --upgrade pip

if [[ -n "${AIZYNTH_EXTRAS:-1}" ]]; then
    echo "[INFO] Installing AiZynthFinder with extras"
    pip install ".[all]"
else
    echo "[INFO] Installing AiZynthFinder core"
    pip install "."
fi

export AIZYNTH_DATA_HOME="${DATA_DIR}"
mkdir -p "${DATA_DIR}"

if [[ ! -f "${DATA_DIR}/config.yml" ]]; then
    echo "[INFO] Downloading public data into ${DATA_DIR}"
    download_public_data "${DATA_DIR}"
else
    echo "[INFO] Reusing existing data at ${DATA_DIR}"
fi

if [[ ! -f "${SMILES_FILE}" ]]; then
    cat <<'EOL' > "${SMILES_FILE}"
CCO
CC(=O)Oc1ccccc1C(=O)O
EOL
    echo "[INFO] Created example SMILES list at ${SMILES_FILE}"
else
    echo "[INFO] Reusing SMILES file ${SMILES_FILE}"
fi

aizynthcli --config "${DATA_DIR}/config.yml" --smiles "${SMILES_FILE}" --output "${SMILES_FILE}.results.json"

echo
cat <<EOF
[INFO] AiZynthFinder deployment finished successfully.

To start using AiZynthFinder, activate the environment with:
  source "${VENV_DIR}/bin/activate"

Run future retrosynthesis jobs with:
  aizynthcli --config "${DATA_DIR}/config.yml" --smiles YOUR_SMILES_FILE --output results.json
EOF

