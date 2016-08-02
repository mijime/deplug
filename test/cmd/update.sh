#!/bin/bash

source dist/sham.sh;

setup() {
  unset SHAM_PLUGS;
  export SHAM_HOME="/tmp/sham-${UNITTEST_NO}";
  [[ ! -d "${SHAM_HOME}" ]] || rm -rf "${SHAM_HOME}";
}

teardown() {
  unset SHAM_PLUGS;
  export SHAM_HOME="/tmp/sham-${UNITTEST_NO}";
  [[ ! -d "${SHAM_HOME}" ]] || rm -rf "${SHAM_HOME}";
}

__test__update_01() {
  sham mijime/sham --from=file://. --at=HEAD^^;
  sham install;

  sham mijime/sham --from=file://.;
  sham update;

  [[ -d "${SHAM_HOME}/repos/mijime/sham" ]];
}

__test__update_02_noinstall() {
  sham mijime/sham --from=file://.;
  sham update;

  [[ ! -d "${SHAM_HOME}/repos/mijime/sham" ]];
}
