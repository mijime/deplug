#!/bin/bash

__sham__util__do() {
  local \
    __v__dir_curr=$(pwd)

  cd "${__v__dir}"

  if ! eval "${__v__do}" >&2
  then
    cd "${__v__dir_curr}"
    echo 4
    return
  fi

  cd "${__v__dir_curr}"
  echo 0
  return
}
