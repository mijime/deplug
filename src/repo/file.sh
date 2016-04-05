#!/bin/bash

__sham__repo__file() {
  case "${__g__cmd}" in
    install)
      if [[ ! -d "${__v__dir}" ]] && ! git clone "${__v__from#*://}" "${__v__dir}" >&2
      then
        echo 4
        return 1
      fi

      local __v__curr_dir=$(pwd)

      cd "${__v__dir}"

      if [[ ! -z "${__v__at}" ]] && ! git checkout "${__v__at}" >&2
      then
        cd "${__v__curr_dir}"

        echo 4
        return 1
      fi

      cd "${__v__curr_dir}"
      ;;

    *)
      ;;
  esac

  echo 0
  return
}
