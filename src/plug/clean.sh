#!/bin/bash

__sham__plug__clean() {
  case ${__v__stat} in
    1|3)
      if [[ -d "${__v__dir}" ]]
      then rm -r "${__v__dir}"
      fi

      __v__stat=5
      ;;

    *)
      ;;
  esac
}
