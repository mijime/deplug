#!/bin/bash

source src/util/disp_stat.sh;

setup() {
  export __g__home=/tmp/sham-${UNITTEST_NO};
  export __g__state=${__g__home}/cache;

  mkdir -p "${__g__home}";
  cat << EOF > "${__g__home}/cache";
@@#no=0#as=mijime/sham00#at=#dir=/tmp/sham/repos/mijime/sham00#from=file://.#of=#use=#do=#stat=0
@@#no=1#as=mijime/sham01#at=#dir=/tmp/sham/repos/mijime/sham01#from=file://.#of=#use=#do=#stat=0
@@#no=2#as=mijime/sham02#at=#dir=/tmp/sham/repos/mijime/sham02#from=file://.#of=#use=#do=#stat=0
@@#no=3#as=mijime/sham03#at=#dir=/tmp/sham/repos/mijime/sham03#from=file://.#of=#use=#do=#stat=3
@@#no=4#as=mijime/sham04#at=#dir=/tmp/sham/repos/mijime/sham04#from=file://.#of=#use=#do=#stat=4
EOF
}

teardown() {
  [[ ! -d ${__g__home} ]] || rm -r "${__g__home}";

  unset SHAM_PLUGS;
  unset __g__home __g__state;
}

__test__disp_stat_01() {
  local SHAM_PLUGS=("@@#no=0#as=mijime/sham00#at=#dir=/tmp/sham/repos/mijime/sham00#from=file://.#of=#use=#do=#stat=1");

  __sham__util__disp_stat;
  __sham__util__disp_stat|grep -c "#as=mijime/sham00#.*#stat=1";
}

__test__disp_stat_01_noupdate() {
  local SHAM_PLUGS=("@@#no=0#as=mijime/sham00#at=#dir=/tmp/sham/repos/mijime/sham00#from=file://.#of=#use=#do=#stat=2");

  __sham__util__disp_stat;
  __sham__util__disp_stat|grep -c "#as=mijime/sham00#.*#stat=0";
}

__test__disp_stat_01_update() {
  local SHAM_PLUGS=("@@#no=0#as=mijime/sham00#at=#dir=/tmp/sham/repos/mijime/sham00#from=file://.#of=*.sh#use=#do=#stat=2");

  __sham__util__disp_stat;
  __sham__util__disp_stat|grep -c "#as=mijime/sham00#.*#stat=2";
}

__test__disp_stat_02() {
  __sham__util__disp_stat;
  __sham__util__disp_stat|grep -c "#as=mijime/sham02#.*#stat=0";
}

__test__disp_stat_03() {
  local SHAM_PLUGS=("@@#no=0#as=mijime/sham01#at=#dir=/tmp/sham/repos/mijime/sham00#from=file://.#of=#use=#do=#stat=1");

  __sham__util__disp_stat;
  __sham__util__disp_stat|grep -c "#as=mijime/sham02#.*#stat=3";
}

__test__disp_stat_04() {
  local SHAM_PLUGS=("@@#no=0#as=mijime/sham01#at=#dir=/tmp/sham/repos/mijime/sham00#from=file://.#of=#use=#do=#stat=1");

  __sham__util__disp_stat;
  __sham__util__disp_stat|grep -c "#as=mijime/sham04#.*#stat=4";
}
