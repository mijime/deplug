#!/bin/bash

__sham__plug__post() {
  case ${__v__stat} in
    0)
      ;;

    *)
      return
      ;;
  esac

  if [[ -z ${__v__do} ]]
  then return
  fi

  local __v__dir_curr=$(pwd)

  cd "${__v__dir}"

  if ! eval "${__v__do}" 1>&2
  then
    cd "${__v__dir_curr}"
    __v__stat=4
    return 1
  fi

  cd "${__v__dir_curr}"
  __v__stat=0
}
