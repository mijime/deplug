#!/bin/bash

__sham__repo__github() {
  case "${__g__cmd}" in
    install)
      if [[ ! -d "${__v__dir}" ]] && ! git clone "https://github.com/${__v__from#*://}" "${__v__dir}"
      then
        return 1
      fi

      local __v__dir_curr=$(pwd)

      cd "${__v__dir}"

      if [[ ! -z "${__v__at}" ]] && ! git checkout "${__v__at}"
      then
        cd "${__v__dir_curr}"

        return 1
      fi

      cd "${__v__dir_curr}"
      ;;

    update)
      if [[ ! -d ${__v__dir} ]]
      then
        return 1
      fi

      local __v__dir_curr=$(pwd)

      cd "${__v__dir}"

      if ! git fetch
      then
        cd "${__v__dir_curr}"

        return 1
      fi

      if [[ ! -z "${__v__at}" ]] && ! git checkout "${__v__at}"
      then
        cd "${__v__dir_curr}"

        return 1
      fi

      if ! git pull
      then
        cd "${__v__dir_curr}"

        return 1
      fi

      cd "${__v__dir_curr}"
      ;;

    *)
      ;;
  esac

  return
}
