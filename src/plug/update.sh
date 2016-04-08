#!/bin/bash

__sham__plug__install() {
  case ${__v__stat} in
    [024])
      ;;

    *)
      return
      ;;
  esac

  local __v__scheme=${__v__from%%://*}

  if ! hash __sham__repo__"${__v__scheme}" >/dev/null 2>/dev/null
  then
    printf "%10s %s: %s\n" "[ERROR]" "No specified command" "${__v__scheme}" 1>&2
    __v__stat=4
    return
  fi

  __sham__repo__"${__v__scheme}" 1>&2

  if [[ $? -gt 0 ]]
  then
    __v__stat=4
    return
  fi

  __v__stat=0
}
