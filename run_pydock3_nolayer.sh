#!/usr/bin/env bash
set -euo pipefail
proj="/nfs/home/alina/new_scoring_pydock3_by_Alina"
source "$proj/.venv/bin/activate"
export PYTHONPATH="$proj/pydock3:${PYTHONPATH:-}"
python -m pydock3.scripts "$@"
