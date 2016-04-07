#!/bin/bash

__sham__util__repo_git() {
  local __v__git_url=$1
  shift

  case "${__g__cmd}" in
    install)
      if [[ ! -d "${__v__dir}" ]] && ! git clone "${__v__git_url}" "${__v__dir}"
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
