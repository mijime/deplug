#!/bin/bash

declare -a SHAM_PLUGS=()

sham() {
  local \
    __g__home=${SHAM_HOME:-~/.sham} \
    __g__bin= \
    __g__cache= \
    __g__repos= \
    __g__state= \
    __g__cmd= \
    __v__plug= \
    __v__no=0 \
    __v__as= \
    __v__at= \
    __v__dir= \
    __v__from= \
    __v__of= \
    __v__use= \
    __v__do= \
    __v__verbose=

  local -a \
    __g__colo=()

  __g__bin=${SHAM_BIN:-${__g__home}/bin}
  __g__cache=${SHAM_CACHE:-${__g__home}/cache}
  __g__repos=${SHAM_REPO:-${__g__home}/repos}
  __g__state=${SHAM_STATE:-${__g__home}/state}

  while [[ $# -gt 0 ]]
  do
    local __v__tmp=

    case $1 in
      --verbose|-v)
        __v__verbose=1
        shift || break
        ;;

      --as|--at|--dir|--from|--of|--use|--do)
        eval "__v__${1#--}=\"$2\""
        shift 2 || break
        ;;

      as:|at:|dir:|from:|of:|use:|do:)
        eval "__v__${1%%:*}=\"$2\""
        shift 2 || break
        ;;

      --as=*|--at=*|--dir=*|--from=*|--of=*|--use=*|--do=*)
        __v__tmp=${1%%=*}
        eval "__v__${__v__tmp#--}=\"${1#*=}\""
        shift || break
        ;;

      as:*|at:*|dir:*|from:*|of:*|use:*|do:*)
        eval "__v__${1%%:*}=\"${1#*:}\""
        shift || break
        ;;

      *://*/*)
        __g__cmd=append
        __v__from=$1
        __v__plug=${1#*://}
        shift || break
        ;;

      */*)
        __g__cmd=append
        __v__plug=$1
        shift || break
        ;;

      *)
        __g__cmd=$1
        shift || break
        ;;
    esac
  done

  if [[ -z ${__g__cmd} ]]
  then
    return
  elif hash "__sham__cmd__${__g__cmd}" >/dev/null 2>/dev/null
  then
    "__sham__cmd__${__g__cmd}" "$@"
  else
    __sham__util__error "No specified command: ${__g__cmd}"
    return 1
  fi
}
