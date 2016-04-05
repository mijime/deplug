#!/bin/bash


setup() {
  unset SHAM_PLUGS;
  export SHAM_HOME="/tmp/sham/${UNITTEST_NUMBER}";
  [[ ! -d "${SHAM_HOME}" ]] || rm -r "${SHAM_HOME}";
  source bin/sham.sh;
}

__test__be_sure_installed_plugins () {
  sham mijime/sham --from=file://.;
  sham install;

  [[ -d "${SHAM_HOME}/repos/mijime/sham" ]];
}

__test__be_sure_installed_plugins_and_doing() {
  sham mijime/sham --dir="${SHAM_HOME}/repo" --from=file://. --do="touch ../helloworld";
  sham install;

  [[ -d "${SHAM_HOME}/repo" ]] \
    && [[ -f "${SHAM_HOME}/helloworld" ]];
}

__test__be_sure_installed_plugins_and_included() {
  sham mijime/sham --from=file://. --of=src/*.sh;
  sham install;

  grep -c src/*.sh "${SHAM_HOME}/cache";
}

__test__be_sure_installed_plugins_and_using() {
  sham mijime/sham --from=file://. --use=test/*.sh;
  sham install;

  [[ -L ${SHAM_HOME}/bin/unitesh.sh ]];
}
