#!/bin/bash

__sham__util__do() {
  cd "${__v__dir}"

  if ! eval "${__v__do}" >&2
  then
    echo 4
    return
  fi

  cd -
  echo 0
  return
}
