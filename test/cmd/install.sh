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

__test__install_01 () {
  sham mijime/sham --from=file://.;
  sham install;

  [[ -d "${SHAM_HOME}/repos/mijime/sham" ]];
}

__test__install_01_failed() {
  sham mijime/sham --from=file://..;
  sham install;

  [[ ! -d "${SHAM_HOME}/repos/mijime/sham" ]] \
    && sham status | grep "Failed";
}

__test__install_01_throw_samesettings() {
  sham mijime/sham --from=file://.;
  sham install;

  sham mijime/sham --from=file://.;
  rm -rf "${SHAM_HOME}/repos/mijime/sham";
  sham install;

  [[ ! -d "${SHAM_HOME}/repos/mijime/sham" ]] \
    && sham status | grep "Installed";
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

  grep -c "src/sham.sh" "${SHAM_HOME}/cache";
}

__test__install_04_using() {
  sham mijime/sham --from=file://. --use=dist/*.sh;
  sham install;

  [[ -L ${SHAM_HOME}/bin/unitesh.sh ]];
}

__test__install_05_heavy() {
  sham mijime/sham00 --from=file://. --of=src/*.sh --use=dist/*.sh --do="sleep 5";
  sham mijime/sham01 --from=file://. --of=src/*.sh --use=dist/*.sh --do="sleep 5";
  sham mijime/sham02 --from=file://. --of=src/*.sh --use=dist/*.sh --do="sleep 5";
  sham mijime/sham03 --from=file://. --of=src/*.sh --use=dist/*.sh --do="sleep 5";
  sham mijime/sham04 --from=file://. --of=src/*.sh --use=dist/*.sh --do="sleep 5";
  sham install;

  sham status | grep -c "Installed" | xargs test 5 -eq;
}
