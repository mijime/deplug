#!/bin/bash

unset __dplg__plugins
declare -A __dplg__plugins=()

deplug() {
  DEPLUG_HOME=${DEPLUG_HOME:-~/.deplug}
  DEPLUG_STAT=${DEPLUG_STAT:-${DEPLUG_HOME}/state}
  DEPLUG_REPO=${DEPLUG_REPO:-${DEPLUG_HOME}/repos}
  DEPLUG_BIN=${DEPLUG_BIN:-${DEPLUG_HOME}/bin}

  __dplg__main "$@"
}

__dplg__init() {
  mkdir -p ${DEPLUG_HOME} ${DEPLUG_REPO} ${DEPLUG_BIN}
  touch ${DEPLUG_STAT}
}

__dplg__main() {
  local __dplg__errcode=0 __dplg__debug=0 __dplg__verbose=0
  local __dplg__plugin __dplg__pwd __dplg__cmd __dplg__tag __dplg__dir __dplg__post __dplg__name __dplg__of __dplg__use

  while [[ $# -gt 0 ]]
  do
    case $1 in
      --post|post:)
        __dplg__post=$2
        shift 2 || echo 'post is need a attribute' | __dplg__error || return 1
        ;;

      --tag|tag:)
        __dplg__tag=$2
        shift 2 || echo 'tag is need a attribute' | __dplg__error || return 1
        ;;

      --of|of:)
        __dplg__of=$2
        shift 2 || echo 'of is need a attribute' | __dplg__error || return 1
        ;;

      --use|use:)
        __dplg__use=$2
        shift 2 || echo 'use is need a attribute' | __dplg__error || return 1
        ;;

      --dir|dir:)
        __dplg__dir=$2
        shift 2 || echo 'dir is need a attribute' | __dplg__error || return 1
        ;;

      --name|name:)
        __dplg__name=$2
        shift 2 || echo 'name is need a attribute' | __dplg__error || return 1
        ;;

      --debug)
        __dplg__debug=1
        shift || break
        ;;

      --verbose|-v)
        __dplg__verbose=1
        shift || break
        ;;

      -*)
        echo "undefined option is $1" | __dplg__error || return 1
        ;;

      */*)
        [[ -z "${__dplg__cmd}" ]] && __dplg__cmd=append
        __dplg__plugin=$1
        shift || break
        ;;

      *)
        __dplg__cmd=$1
        shift || break
        ;;
    esac
  done

  if [[ -z "${__dplg__name}" ]]
  then __dplg__name=${__dplg__plugin##*/}
  fi

  if [[ -z "${__dplg__dir}"  ]]
  then __dplg__dir=${DEPLUG_REPO}/${__dplg__name}
  fi

  if [[ -z "${__dplg__cmd}" ]]
  then
    __dplg__help
    return 1
  fi

  "__dplg__${__dplg__cmd}"
}

__dplg__load() {
  [[ -z "${__dplg__plugins[@]}" ]] && return

  for plug in "${__dplg__plugins[@]}"
  do
    __dplg__parse "${plug}"
    __dplg__stat | __dplg__debug 'load'
    __dplg__of
  done | cat
}

__dplg__install() {
  [[ -z "${__dplg__plugins[@]}" ]] && return

  __dplg__init

  for plug in "${__dplg__plugins[@]}"
  do
    __dplg__parse "${plug}"
    {
      echo "${__dplg__plugin}" | __dplg__verbose 'Install..'
      __dplg__download
      __dplg__post
      __dplg__use
      echo "${__dplg__plugin}" | __dplg__verbose 'Installed'
    } &
  done | cat

  __dplg__freeze
}

__dplg__defrost() {

  while read plug
  do
    __dplg__parse "${plug}"

    echo "${__dplg__plugin}" | __dplg__verbose 'Defrost'
    __dplg__stat | __dplg__debug 'defrost'
    __dplg__append
  done < ${DEPLUG_STAT}
}

__dplg__freeze() {
  for plug in "${__dplg__plugins[@]}"
  do
    echo "${plug}" | __dplg__debug 'freeze'
    echo "${plug}"
  done > ${DEPLUG_STAT}
}

__dplg__upgrade() {
  [[ -z "${__dplg__plugins[@]}" ]] && return

  __dplg__init

  for plug in "${__dplg__plugins[@]}"
  do
    __dplg__parse "${plug}"
    {
      __dplg__update
      __dplg__post
      __dplg__use
    } &
  done | cat
}

__dplg__status() {
  local __dplg__isdir __dplg__res=0

  for plug in "${__dplg__plugins[@]}"
  do
    __dplg__parse "${plug}"

    if [[ -d "${__dplg__dir}" ]]
    then
      __dplg__isdir='Installed'
    else
      __dplg__isdir='NoInstall'
      __dplg__res=1
    fi

    echo "${__dplg__plugin}" | __dplg__message "${__dplg__isdir}"
  done | cat

  [[ 0 -eq ${__dplg__verbose} ]] && return ${__dplg__res}

  while read plug
  do
    __dplg__parse "${plug}"
    if [[ -z "${__dplg__plugins[${__dplg__name}]}" ]]
    then
      echo "${__dplg__plugin}" | __dplg__message 'Cached'
      __dplg__res=1
    fi
  done < ${DEPLUG_STAT}

  return ${__dplg__res}
}

__dplg__append() {
  __dplg__stat | __dplg__debug 'append'

  __dplg__plugins[${__dplg__name}]="$(__dplg__stat)"
}

__dplg__post() {
  __dplg__stat | __dplg__debug 'post'

  [[ ! -d "${__dplg__dir}" ]] && return 1
  [[ -z "${__dplg__post}" ]] && return 1

  cd ${__dplg__dir}
  ${__dplg__post} 2>&1 | __dplg__logger 'post'
}

__dplg__remove() {
  __dplg__stat | __dplg__debug 'remove'

  unset __dplg__plugins[${__dplg__name}]
}

__dplg__clean() {
  [[ -z "${__dplg__plugins[@]}" ]] && return

  __dplg__init

  declare -a __dplg__trash=()

  while read plug
  do
    __dplg__parse "${plug}"
    __dplg__stat | __dplg__debug 'clean'
    if [[ -z "${__dplg__plugins[${__dplg__name}]}" ]]
    then
      echo "${__dplg__dir}" | __dplg__verbose 'Removed'
      __dplg__trash=("${__dplg__trash[@]}" "${__dplg__dir}")
    fi
  done < ${DEPLUG_STAT}

  if [[ ! -z "${__dplg__trash[@]}" ]]
  then
    \rm -r "${__dplg__trash[@]}"
  fi

  __dplg__freeze
}

__dplg__download() {
  __dplg__stat | __dplg__debug 'download'

  __dplg__pwd=$(pwd)
  case ${__dplg__plugin} in
    *)
      if [[ ! -d "${__dplg__dir}" ]]
      then
        git clone "https://github.com/${__dplg__plugin}" "${__dplg__dir}" 2>&1 | __dplg__logger 'Download'
      fi

      if [[ ! -z "${__dplg__tag}" ]]
      then
        {
          cd ${__dplg__dir}
          git checkout ${__dplg__tag} 2>&1 | __dplg__logger 'Download'
          cd ${__dplg__pwd}
        }
      fi
      ;;
  esac
}

__dplg__update() {
  __dplg__stat | __dplg__debug 'update'

  [[ -d "${__dplg__dir}" ]] || echo "${__dplg__plugin} is not installed" | __dplg__error 'WARNING' || return 1

  __dplg__pwd=$(pwd)
  cd ${__dplg__dir}
  case ${__dplg__plugin} in
    *)
      git pull 2>&1 | __dplg__logger 'Update'
      [[ -z "${__dplg__tag}" ]] || git checkout ${__dplg__tag} 2>&1 | __dplg__logger 'Update'
      ;;
  esac
  cd ${__dplg__pwd}
}

__dplg__of() {
  __dplg__stat | __dplg__debug 'of'

  [[ -z "${__dplg__of}" ]] && return

  echo "${__dplg__dir}/${__dplg__of}" | __dplg__verbose 'Loading..'
  source ${__dplg__dir}/${__dplg__of} 2>&1 | __dplg__logger 'Loading'
}

__dplg__use() {
  __dplg__stat | __dplg__debug 'use'

  [[ -z ${__dplg__use} ]] && return

  echo "${__dplg__dir}/${__dplg__use}" | __dplg__verbose 'Using'
  ln -sf ${__dplg__dir}/${__dplg__use} ${DEPLUG_BIN}
}

__dplg__help() {
  echo
}

__dplg__stat() {
  echo "name:${__dplg__name}#plugin:${__dplg__plugin}#dir:${__dplg__dir}#tag:${__dplg__tag}#post:${__dplg__post}#of:${__dplg__of}#use:${__dplg__use}"
}

__dplg__error() {
  __dplg__message 'ERROR'

  return 1
}

__dplg__debug() {
  [[ 0 -eq ${__dplg__debug} ]] && return

  local __dplg__message="${1:-${__dplg__name}}"
  __dplg__message "DEBUG:${__dplg__message}"
}

__dplg__logger() {
  [[ 0 -eq ${__dplg__verbose} ]] && return

  local __dplg__message="${1:-INFO}:${__dplg__name}"
  __dplg__message "${__dplg__message}"
}

__dplg__verbose() {
  [[ 0 -eq ${__dplg__verbose} ]] && return

  local __dplg__message="${1:-INFO}"
  __dplg__message "${__dplg__message}"
}

__dplg__message() {
  while read line
  do
    printf "%-12s %s\n" "[${@:-INFO}]" "${line}" >&2
  done
}
__dplg__parse() {
  local __dplg__args=()

  __dplg__args=("${(s/#/)@}")

  __dplg__name=${__dplg__args[1]#name:}
  __dplg__plugin=${__dplg__args[2]#plugin:}
  __dplg__dir=${__dplg__args[3]#dir:}
  __dplg__tag=${__dplg__args[4]#tag:}
  __dplg__post=${__dplg__args[5]#post:}
  __dplg__of=${__dplg__args[6]#of:}
  __dplg__use=${__dplg__args[7]#use:}
}
