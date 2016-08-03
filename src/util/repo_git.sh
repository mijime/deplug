#!/bin/bash

__sham__util__repo_git() {
  local __v__git_url=$1
  shift

  case "${__g__cmd}" in
    install)
      if ! git init "${__v__dir}"
      then
        return 1
      fi

      local __v__dir_curr=$(pwd)

      cd "${__v__dir}"

      if [[ "$(git config remote.origin.url)" = "${__v__git_url}" ]]
      then
        return 0
      fi

      if ! git config remote.origin.url "${__v__git_url}"
      then
        return 1
      fi

      if ! git fetch origin "${__v__at}" --depth 1 --progress
      then
        return 1
      fi

      if ! git checkout FETCH_HEAD
      then
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

      if ! git config remote.origin.url "${__v__git_url}"
      then
        return 1
      fi

      if ! git fetch origin "${__v__at}" --depth 1 --progress
      then
        return 1
      fi

      if ! git checkout FETCH_HEAD
      then
        return 1
      fi

      cd "${__v__dir_curr}"
      ;;

    *)
      ;;
  esac

  return
}
