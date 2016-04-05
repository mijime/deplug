#!/bin/bash

source src/util/of.sh;

setup() {
  mkdir -p /tmp/sham/repos/dir;
  touch /tmp/sham/repos/dir/file-{0,1,2,3};
}

teardown() {
  [[ ! -d /tmp/sham ]] || rm -r /tmp/sham;
}

__test__of() {
  local \
    __v__dir=/tmp/sham/repos/dir \
    __v__of=file-*

  __sham__util__of;
  __sham__util__of \
    | grep -c "source * '/tmp/sham/repos/dir/file-3'";
}
