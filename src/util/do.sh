#!/bin/bash

__sham__util__do() {
  local \
    __v__dir_curr=$(pwd)

  if [[ ! -d "${__v__dir}" ]]
  then
    echo 4
    return
  fi

  cd "${__v__dir}"

  if ! eval "${__v__do}"
  then
    cd "${__v__dir_curr}"
    echo 4
    return
  fi

  cd "${__v__dir_curr}"
  echo 0
  return
}
