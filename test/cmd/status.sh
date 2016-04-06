#!/bin/bash

source bin/sham.sh;

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

__test__status_01() {
  sham mijime/sham;

  sham status | grep -c "NoInstall * mijime/sham";
}

__test__status_02() {
  sham mijime/sham --from file://.;
  sham install;

  cat ${SHAM_HOME}/state;
  __sham__util__plugs;
  sham status;
  sham status | grep -c "Installed * mijime/sham";
}
