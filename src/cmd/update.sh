#!/bin/bash

__sham__cmd__update() {
  mkdir -p "${__g__home}" "${__g__bin}"

  local __v__tmp=

  __sham__util__disp_stat \
    | while read __v__tmp
      do
        __sham__util__parse

        case "${__v__stat}" in
          [13])
            __sham__util__stringify
            continue
            ;;
        esac

        __sham__util__sync &
      done \
    | while read __v__tmp
      do
        __sham__util__parse

        __sham__util__disp_status >&2

        case "${__v__stat}" in
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
