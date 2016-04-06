#!/bin/bash

__sham__repo__github() {
  case "${__g__cmd}" in
    install)
      if [[ ! -d "${__v__dir}" ]] && ! git clone "https://github.com/${__v__from#*://}" "${__v__dir}" >&2
      then
        echo 4
        return 1
      fi

      local __v__dir_curr=$(pwd)

      cd "${__v__dir}"

      if [[ ! -z "${__v__at}" ]] && ! git checkout "${__v__at}" >&2
      then
        cd "${__v__dir_curr}"

        echo 4
        return 1
      fi

      cd "${__v__dir_curr}"
      ;;

    update)
      if [[ ! -d "${__v__dir}" ]]
      then
        echo 1
        return 1
      fi

      local __v__dir_curr=$(pwd)

      cd "${__v__dir}"

      if ! git fetch >&2
      then
        cd "${__v__dir_curr}"

        echo 4
        return 1
      fi

      if [[ ! -z "${__v__at}" ]] && ! git checkout "${__v__at}" >&2
      then
        cd "${__v__dir_curr}"

        echo 4
        return 1
      fi

      if ! git pull >&2
      then
        cd "${__v__dir_curr}"

        echo 4
        return 1
      fi

      cd "${__v__dir_curr}"
      ;;

    *)
      ;;
  esac

  echo 0
  return
}
