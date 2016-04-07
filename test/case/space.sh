#!/bin/bash

source dist/sham.sh;

setup() {
  unset SHAM_PLUGS;
  export SHAM_HOME="/tmp/sha m/${UNITTEST_NO}";
  [[ ! -d "${SHAM_HOME}" ]] || rm -r "${SHAM_HOME}";
}

teardown() {
  unset SHAM_PLUGS;
  [[ ! -d "${SHAM_HOME}" ]] || rm -r "${SHAM_HOME}";
}

__test__space_01 () {
  sham mijime/sham --from=file://.;
  sham install;

  [[ -d "${SHAM_HOME}/repos/mijime/sham" ]];
}
