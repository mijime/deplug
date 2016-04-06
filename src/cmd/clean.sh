#!/bin/bash

__sham__cmd__clean() {
  local __v__tmp=

  __sham__util__disp_stat \
    | while read __v__tmp
      do
        __sham__util__parse

        case ${__v__stat} in
          0|1|2)
            __sham__util__stringify
            continue
            ;;
        esac

        if [[ -d "${__v__dir}" ]]
        then
          rm -rf "${__v__dir}"
        fi

      done > "${__g__state}".tmp
  mv "${__g__state}"{.tmp,}

  if [[ -f "${__g__cache}".tmp ]]
  then
    mv "${__g__cache}"{.tmp,}
  fi

  unset SHAM_PLUGS
}
