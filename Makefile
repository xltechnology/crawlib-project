# -*- coding: utf-8 -*-
#
# This Makefile is a dev-ops tool set.
# Compatible with:
#
# - Windows
# - MacOS
# - MacOS + pyenv + pyenv-virtualenv tool set
# - Linux
#
# The file structure should like this:
#
# repo_dir
#     |--- source_dir (package source code dir)
#         |--- __init__.py
#         |--- ...
#     |--- docs (documents dir)
#         |--- build (All build html will be here)
#         |--- source (doc source)
#         |--- Makefile (auto-generated by sphinx)
#         |--- make.bat (for windows)
#         |--- create_doctree.py (a tools automatically build doc tree)
#     |--- tests (unittest dir)
#         |--- all.py (run all test from python)
#     |--- README.rst (readme file)
#     |--- release-history.rst
#     |--- setup.py (installation behavior definition)
#     |--- requirements.txt
#     |--- LICENSE.txt
#     |--- MANIFEST.in
#     |--- tox.ini (tox setting)
#     |--- .travis.yml (travis-ci setting)
#     |--- .coveragerc (code coverage text setting)
#     |--- .gitattributes (git attribute file)
#     |--- .gitignore (git ignore file)
#     |--- fixcode.py (autopep8 source code and unittest code)
#
# Frequently used make command:
#
# - make up
# - make clean
# - make install
# - make test
# - make tox
# - make build_doc
# - make view_doc
# - make deploy_doc
# - make reformat
# - make publish


#--- User Defined Variable ---
PACKAGE_NAME="crawlib"

# Python version Used for Development
PY_VER_MAJOR="2"
PY_VER_MINOR="7"
PY_VER_MICRO="13"

#  Other Python Version You Want to Test With
# (Only useful when you use tox locally)
TEST_PY_VER2="3.4.6"
TEST_PY_VER3="3.5.3"
TEST_PY_VER4="3.6.2"
TEST_PY_VER5=""

# Virtualenv Name
VENV_NAME="${PACKAGE_NAME}_venv"

# If you use pyenv-virtualenv, set to "Y"
USE_PYENV="Y"

# S3 Bucket Name
BUCKET_NAME="www.wbh-doc.com"

#--- Derive Other Variable ---
CURRENT_DIR=${shell pwd}

ifeq (${OS}, Windows_NT)
    DETECTED_OS := Windows
else
    DETECTED_OS := $(shell uname -s)
endif

# Windows
ifeq (${DETECTED_OS}, Windows)
    USE_PYENV="N"

    VENV_DIR_REAL="${CURRENT_DIR}/${VENV_NAME}"
    BIN_DIR="${VENV_DIR_REAL}/Scripts"
    SITE_PACKAGES="${VENV_DIR_REAL}/Lib/site-packages"

    GLOBAL_PYTHON="/c/Python${PY_VER_MAJOR}${PY_VER_MINOR}/python.exe"
    OPEN_COMMAND="start"
endif


# MacOS
ifeq (${DETECTED_OS}, Darwin)

ifeq ($(USE_PYENV), "Y")
    VENV_DIR_REAL="${HOME}/.pyenv/versions/${PY_VERSION}/envs/${VENV_NAME}"
    VENV_DIR_LINK="${HOME}/.pyenv/versions/${VENV_NAME}"
    BIN_DIR="${VENV_DIR_REAL}/bin"
    SITE_PACKAGES="${VENV_DIR_REAL}/lib/python${PY_VER_MAJOR}.${PY_VER_MINOR}/site-packages"
else
    VENV_DIR_REAL="${CURRENT_DIR}/${VENV_NAME}"
    VENV_DIR_LINK="./${VENV_NAME}"
    BIN_DIR="${VENV_DIR_REAL}/bin"
    SITE_PACKAGES="${VENV_DIR_REAL}/lib/python${PY_VER_MAJOR}.${PY_VER_MINOR}/site-packages"
endif

    GLOBAL_PYTHON="python${PY_VER_MAJOR}.${PY_VER_MINOR}"
    OPEN_COMMAND="open"
endif


# Linux
ifeq (${DETECTED_OS}, Linux)
    USE_PYENV="N"

    VENV_DIR_REAL="${CURRENT_DIR}/${VENV_NAME}"
    VENV_DIR_LINK="${CURRENT_DIR}/${VENV_NAME}"
    BIN_DIR="${VENV_DIR_REAL}/bin"
    SITE_PACKAGES="${VENV_DIR_REAL}/lib/python${PY_VER_MAJOR}.${PY_VER_MINOR}/site-packages"

    GLOBAL_PYTHON="python${PY_VER_MAJOR}.${PY_VER_MINOR}"
    OPEN_COMMAND="open"
endif


BIN_ACTIVATE="${BIN_DIR}/activate"
BIN_PYTHON="${BIN_DIR}/python"
BIN_PIP="${BIN_DIR}/pip"
BIN_PYTEST="${BIN_DIR}/pytest"
BIN_SPHINX_START="${BIN_DIR}/sphinx-quickstart"
BIN_TWINE="${BIN_DIR}/twine"

S3_PREFIX="s3://${BUCKET_NAME}/${PACKAGE_NAME}"
DOC_URL="http://${BUCKET_NAME}.s3.amazonaws.com/${PACKAGE_NAME}/index.html"

PY_VERSION="${PY_VER_MAJOR}.${PY_VER_MINOR}.${PY_VER_MICRO}"


.PHONY: help
help: ## Show this help message
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


#--- Make Commands ---
.PHONY: info
info: ## Show information about python, pip in this environment
	@echo - venv: ${VENV_DIR_REAL} "\n"
	@echo - python executable: ${BIN_PYTHON} "\n"
	@echo - pip executable: ${BIN_PIP} "\n"
	@echo - document: ${DOC_URL} "\n"
	@echo - site-packages: ${SITE_PACKAGES} "\n"


#--- Virtualenv ---
.PHONY: brew_install_pyenv
brew_install_pyenv: ## Install pyenv and pyenv-virtualenv
	brew install pyenv
	brew install pyenv-virtualenv


.PHONY: setup_pyenv
setup_pyenv: brew_install_pyenv ## Do some pre-setup for pyenv and pyenv-virtualenv
	-rm ~/.bash_profile
	echo 'export PYENV_ROOT="$$HOME/.pyenv"' >> ~/.bash_profile
	echo 'export PATH="$$PYENV_ROOT/bin:$$PATH"' >> ~/.bash_profile
	echo 'eval "$$(pyenv init -)"' >> ~/.bash_profile
	echo 'eval "$$(pyenv virtualenv-init -)"' >> ~/.bash_profile

	pyenv install ${PY_VERSION} -s
	pyenv rehash


.PHONY: init_venv
init_venv: ## Initiate Virtual Environment
ifeq (${USE_PYENV}, "Y")
	# Install pyenv
	-brew install pyenv
	-brew install pyenv-virtualenv

	# Initiate Config File
	-rm ~/.bash_profile
	echo 'export PYENV_ROOT="$$HOME/.pyenv"' >> ~/.bash_profile
	echo 'export PATH="$$PYENV_ROOT/bin:$$PATH"' >> ~/.bash_profile
	echo 'eval "$$(pyenv init -)"' >> ~/.bash_profile
	echo 'eval "$$(pyenv virtualenv-init -)"' >> ~/.bash_profile

	pyenv install ${PY_VERSION} -s
	pyenv rehash

	-pyenv virtualenv ${VENV_NAME}
else
	virtualenv -p ${GLOBAL_PYTHON} ${VENV_NAME}
endif


.PHONY: up
up: init_venv ## Set Up the Virtual Environment


.PHONY: clean
clean: ## Clean Up Virtual Environment
ifeq (${USE_PYENV}, "Y")
	-pyenv uninstall -f ${VENV_NAME}
else
	-rm -r ${VENV_DIR_REAL}
endif


#--- Install ---
.PHONY: uninstall
uninstall: ## Uninstall This Package
	-${BIN_PIP} uninstall -y ${PACKAGE_NAME}


.PHONY: install
install: uninstall ## Install This Package via setup.py
	${BIN_PIP} install .


.PHONY: dev_install
dev_install: uninstall ## Install This Package in Editable Mode
	${BIN_PIP} install --editable .


#--- Test ---
.PHONY: test
test: dev_install ## Run test
	${BIN_PIP} install pytest
	${BIN_PYTEST} tests -s


.PHONY: cov
cov: dev_install ## Run Code Coverage test
	${BIN_PIP} install pytest-cov
	${BIN_PYTEST} tests -s --cov=${PACKAGE_NAME} --cov-report term --cov-report annotate:.coverage.annotate


.PHONY: tox
tox: ## Run tox
	pip install tox
	( \
		pyenv local ${PY_VERSION} ${TEST_PY_VER2} ${TEST_PY_VER3} ${TEST_PY_VER4} ${TEST_PY_VER5}; \
		tox; \
	)


#--- Sphinx Doc ---
.PHONY: install_doc_deps
install_doc_deps: ## Install Library for building Docs
	${BIN_PIP} install sphinx==1.6.3
	${BIN_PIP} install --upgrade docfly


.PHONY: init_doc
init_doc: install_doc_deps ## Initialize Sphinx Documentation Library
	{ \
		cd docs; \
		${BIN_SPHINX_START}; \
	}


.PHONY: build_doc
build_doc: install_doc_deps dev_install ## Build Documents, force Update
	${BIN_PYTHON} ./docs/create_doctree.py
	( \
		source ${BIN_ACTIVATE}; \
		cd docs; \
		make html; \
	)


.PHONY: build_doc_again
build_doc_again: dev_install ## Build Documents, Don't Check Dependencies
	${BIN_PYTHON} ./docs/create_doctree.py
	( \
		source ${BIN_ACTIVATE}; \
		cd docs; \
		make html; \
	)


.PHONY: view_doc
view_doc: ## Open Documents
	${OPEN_COMMAND} ./docs/build/html/index.html


.PHONY: deploy_doc
deploy_doc: ##
	aws s3 rm ${S3_PREFIX} --recursive
	aws s3 sync ./docs/build/html ${S3_PREFIX}


.PHONY: clean_doc
clean_doc: ## Clean Existing Documents
	rm -r ./docs/build


.PHONY: reformat
reformat: ## Pep8 Format Source Code
	${BIN_PIP} install --upgrade pathlib_mate
	${BIN_PIP} install autopep8
	${BIN_PYTHON} fixcode.py


.PHONY: publish
publish: ## Publish This Library to PyPI
	${BIN_PIP} install 'twine>=1.5.0'
	${BIN_PYTHON} setup.py sdist bdist_wheel
	${BIN_TWINE} upload dist/*
	-rm -rf build dist .egg ${PACKAGE_NAME}.egg-info