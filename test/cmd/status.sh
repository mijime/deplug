#!/bin/bash

source dist/sham.sh;

setup() {
  unset SHAM_PLUGS;
  export SHAM_HOME="/tmp/sham-${UNITTEST_NO}";
  [[ ! -d "${SHAM_HOME}" ]] || rm -rf "${SHAM_HOME}";
  source dist/sham.sh;
}

teardown() {
  unset SHAM_PLUGS;
  export SHAM_HOME="/tmp/sham-${UNITTEST_NO}";
  [[ ! -d "${SHAM_HOME}" ]] || rm -rf "${SHAM_HOME}";
}

__test__status_01() {
  sham mijime/sham;

  sham status;
  sham status | grep -c "NoInstall * mijime/sham";
}

__test__status_02() {
  sham mijime/sham --from file://.;
  sham install;

  sham status;
  sham status | grep -c "Installed * mijime/sham";
}
