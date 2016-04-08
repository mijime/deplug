#!/bin/bash

source dist/sham.sh;

setup() {
  unset SHAM_PLUGS;
  export SHAM_HOME="/tmp/sham-${UNITTEST_NO}";
  [[ ! -d "${SHAM_HOME}" ]] || rm -r "${SHAM_HOME}";
}

teardown() {
  unset SHAM_PLUGS;
  export SHAM_HOME="/tmp/sham-${UNITTEST_NO}";
  [[ ! -d "${SHAM_HOME}" ]] || rm -r "${SHAM_HOME}";
}

__test__clean_01 () {
  sham mijime/sham00 --from=file://.;
  sham mijime/sham01 --from=file://.;
  sham install;

  sham mijime/sham01 --from=file://.;
  sham install;

  sham clean;

  [[ ! -d "${SHAM_HOME}/repos/mijime/sham00" ]] \
    && [[ -d "${SHAM_HOME}/repos/mijime/sham01" ]];
}

__test__clean_02 () {
  sham mijime/sham00 --from=file://.;
  sham mijime/sham01 --from=file://. --use=dist/*.sh --of=src/*.sh --do=echo;
  sham install;

  sham mijime/sham01 --from=file://. --use=dist/*.sh --of=src/*.sh --do=echo;
  sham install --color --logger=2;

  sham clean --color --logger=2;

  grep -c "src/sham.sh" "${SHAM_HOME}/cache" \
    && [[ -L ${SHAM_HOME}/bin/unitesh.sh ]];
}
