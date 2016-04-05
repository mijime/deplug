#!/bin/bash

source src/util/plugs.sh;

setup() {
  export __g__state=/tmp/sham/cache;
  mkdir -p /tmp/sham;
  cat << EOF > /tmp/sham/cache;
@@#as=mijime/sham01#at=#dir=/mijime/sham#from=github://mijime/sham#of=#use=#do=#stat=0
@@#as=mijime/sham02#at=#dir=/mijime/sham#from=github://mijime/sham#of=#use=#do=#stat=0
@@#as=mijime/sham03#at=#dir=/mijime/sham#from=github://mijime/sham#of=#use=#do=#stat=3
@@#as=mijime/sham04#at=#dir=/mijime/sham#from=github://mijime/sham#of=#use=#do=#stat=4
EOF
}

teardown() {
  unset SHAM_PLUGS;
}

__test__plugs_01() {
  local SHAM_PLUGS=("@@#as=mijime/sham00#at=#dir=/mijime/sham#from=github://mijime/sham#of=#use=#do=#stat=1")

  __sham__util__plugs|grep -c "#as=mijime/sham00#.*#stat=1";
}

__test__plugs_02() {
  __sham__util__plugs|grep -c "#as=mijime/sham02#.*#stat=0";
}

__test__plugs_03() {
  local SHAM_PLUGS=("@@#as=mijime/sham01#at=#dir=/mijime/sham#from=github://mijime/sham#of=#use=#do=#stat=1")

  __sham__util__plugs|grep -c "#as=mijime/sham02#.*#stat=3";
}

__test__plugs_04() {
  local SHAM_PLUGS=("@@#as=mijime/sham01#at=#dir=/mijime/sham#from=github://mijime/sham#of=#use=#do=#stat=1")

  __sham__util__plugs;
  __sham__util__plugs|grep -c "#as=mijime/sham04#.*#stat=4";
}
