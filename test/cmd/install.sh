#!/bin/bash

export SHAM_HOME="/tmp/sham/${UNITTEST_NUMBER}";
source sham.bash;

setup() {
  [[ ! -d "${SHAM_HOME}" ]] || rm -r "${SHAM_HOME}";
}

teardown() {
  [[ -d "${SHAM_HOME}" ]] || rm -r "${SHAM_HOME}";
}

__test__be_sure_installed_plugins () {
  sham mijime/sham --from=.;
  sham install;

  [[ -d "${SHAM_HOME}/repos/mijime/sham" ]];
}

__test__be_sure_installed_plugins_and_doing() {
  sham mijime/sham --from=. --do="touch '${SHAM_HOME}/helloworld'";
  sham install;

  [[ -d "${SHAM_HOME}/repos/mijime/sham" ]] \
    && [[ -f "${SHAM_HOME}/helloworld" ]];
}

__test__be_sure_installed_plugins_and_included() {
  sham mijime/sham --from=. --of=*.bash;
  sham install;

  grep -c sham.bash "${SHAM_HOME}/cache";
}

__test__be_sure_installed_plugins_and_using() {
  sham mijime/sham --from=. --use=*.bash;
  sham install;

  [[ -L ${SHAM_HOME}/bin/sham.bash ]];
}
