#!/bin/bash

__sham__cmd__clean() {
  local __v__tmp=

  __sham__util__disp_stat \
    | while read __v__tmp
      do
        __sham__util__parse

        case ${__v__stat} in
          [0-2])
            __sham__util__stringify
            ;;

          *)
            if [[ ! -d "${__v__dir}" ]]
            then continue
            fi

            {
              __sham__util__stringify 10
              rm -rf "${__v__dir}"
              __sham__util__stringify 11
            } &
            ;;
        esac
      done \
    | while read __v__tmp
      do
        __sham__util__parse
        __sham__util__disp_status >&2
        case ${__v__stat} in
          [0-4])
            echo "${__v__tmp}"
            ;;
        esac
      done \
    > "${__g__state}".tmp
  mv "${__g__state}"{.tmp,}

  if [[ -f "${__g__cache}".tmp ]]
  then
    mv "${__g__cache}"{.tmp,}
  fi

  unset SHAM_PLUGS
}
