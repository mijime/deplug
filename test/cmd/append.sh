#!/bin/bash

setup() {
  export SHAM_HOME=/tmp/sham;
  source bin/sham.sh;

  [[ ! -d ${SHAM_HOME} ]] || rm -r "${SHAM_HOME}";
  unset SHAM_PLUGS;
}

teardown() {
  [[ ! -d ${SHAM_HOME} ]] || rm -r "${SHAM_HOME}";
  unset SHAM_PLUGS;
}

__test__append_01() {
  sham mijime/sham;

  echo ${SHAM_PLUGS[@]};
  echo ${SHAM_PLUGS[@]} | grep -c "@@#as=mijime/sham#at=#dir=/tmp/sham/repos/mijime/sham#from=github://mijime/sham#of=#use=#do=#stat=1";
}

__test__append_02() {
  sham mijime/sham --from=file://.;

  echo ${SHAM_PLUGS[@]} | grep -c "#from=file://.#";
}

__test__append_03() {
  sham mijime/sham --as=sham;

  echo ${SHAM_PLUGS[@]} | grep -c "#as=sham#";
}

__test__append_04() {
  sham mijime/sham at: master;

  echo ${SHAM_PLUGS[@]};
  echo ${SHAM_PLUGS[@]} | grep -c "#at=master#";
}

__test__append_05() {
  sham mijime/sham use:*.sh;

  echo ${SHAM_PLUGS[@]} | grep -c "#use=\*.sh#";
}

__test__append_06() {
  sham mijime/sham of:*.sh --dir "${SHAM_HOME}/repos/sham";

  echo ${SHAM_PLUGS[@]} | grep -c "#of=\*.sh#";
  echo ${SHAM_PLUGS[@]} | grep -c "#dir=${SHAM_HOME}/repos/sham#";
}

__test__append_07() {
  sham mijime/sham --do "echo helloworld";

  echo ${SHAM_PLUGS[@]} | grep -c "#do=echo helloworld";
}