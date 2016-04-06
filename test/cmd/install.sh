#!/bin/bash

setup() {
  unset SHAM_PLUGS;
  export SHAM_HOME="/tmp/sham/${UNITTEST_NO}";
  [[ ! -d "${SHAM_HOME}" ]] || rm -r "${SHAM_HOME}";
  source bin/sham.sh;
}

teardown() {
  unset SHAM_PLUGS;
  export SHAM_HOME="/tmp/sham/${UNITTEST_NO}";
  [[ ! -d "${SHAM_HOME}" ]] || rm -r "${SHAM_HOME}";
}

__test__install_01 () {
  sham mijime/sham --from=file://.;
  sham install;

  [[ -d "${SHAM_HOME}/repos/mijime/sham" ]];
}

__test__install_02_doing() {
  sham mijime/sham --dir="${SHAM_HOME}/repo" --from=file://. --do="touch ../helloworld";
  sham install;

  [[ -d "${SHAM_HOME}/repo" ]] \
    && [[ -f "${SHAM_HOME}/helloworld" ]];
}

__test__install_03_included() {
  sham mijime/sham --from=file://. --of=src/*.sh;
  sham install;

  grep -c src/*.sh "${SHAM_HOME}/cache";
}

__test__install_04_using() {
  sham mijime/sham --from=file://. --use=test/*.sh;
  sham install;

  [[ -L ${SHAM_HOME}/bin/unitesh.sh ]];
}
