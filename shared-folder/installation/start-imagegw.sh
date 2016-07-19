#!/bin/bash

SYSTEMS="mycluster"
ROOT_TREE=/opt/shifter/imagegw
PYTHON_VENV=${ROOT_TREE}/python-virtualenv

source ${PYTHON_VENV}/bin/activate
[[ $? -ne 0 ]] && echo "Error, cannot activate Python environment" && exit 1

export PYTHONPATH=${ROOT_TREE}:${PYTHONPATH}
for QA in ${SYSTEMS}; do
 echo "Starting Celery Queue $QA"
 celery -A shifter_imagegw.imageworker worker -Q $QA --loglevel=INFO -n worker.queue.$QA &
done

echo "Starting imagegw API"
python $ROOT_TREE/imagegwapi.py
