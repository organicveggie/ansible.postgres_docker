#!/bin/sh

echo virtualenv venv
virtualenv venv
source venv/bin/activate

echo pip install --upgrade pip
pip install --upgrade pip

echo pip install "ansible"
pip install "ansible"

echo pip install "molecule"
pip install "molecule"

echo pip install "ansible-lint"
pip install "ansible-lint"

echo pip install "molecule[docker]"
pip install "molecule[docker]"
