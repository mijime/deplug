#!/bin/bash

__sham__cmd__install() {
  mkdir -p "${__g__home}" "${__g__bin}"

  local __v__tmp=

  __sham__util__plugs \
    | while read __v__tmp
      do
        __sham__util__parse

        case ${__v__stat} in
          0|3|4)
            __sham__util__stringify
            continue
            ;;
        esac

        local __v__scheme=${__v__from%%://*}

        if hash __sham__repo__"${__v__scheme}" >/dev/null 2>/dev/null
        then
          __v__stat=$(__sham__repo__"${__v__scheme}")
        else
          __sham__util__error "No specified scheme: ${__v__scheme}"
          __v__stat=4
        fi

        if [[ ${__v__stat} -eq 0 ]] && [[ ! -z ${__v__of} ]]
        then
          __sham__util__of >> "${__g__cache}".tmp

          if [[ $? -gt 0 ]]
          then __v__stat=4
          fi
        fi

        if [[ ${__v__stat} -eq 0 ]] && [[ ! -z ${__v__use} ]]
        then
          __sham__util__use

          if [[ $? -gt 0 ]]
          then __v__stat=4
          fi
        fi

        if [[ ${__v__stat} -eq 0 ]] && [[ ! -z ${__v__do} ]]
        then
          __v__stat=$(__sham__util__do)
        fi

        __sham__util__stringify

      done > "${__g__state}".tmp
  mv "${__g__state}"{.tmp,}

  if [[ -f "${__g__cache}".tmp ]]
  then
    mv "${__g__cache}"{.tmp,}
  fi

  unset SHAM_PLUGS
}