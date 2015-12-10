#!/bin/bash
unset __dplg_v_plugins
declare -A __dplg_v_plugins=()
deplug() {
  DEPLUG_HOME=${DEPLUG_HOME:-~/.deplug}
  DEPLUG_STAT=${DEPLUG_STAT:-${DEPLUG_HOME}/state}
  DEPLUG_REPO=${DEPLUG_REPO:-${DEPLUG_HOME}/repos}
  DEPLUG_BIN=${DEPLUG_BIN:-${DEPLUG_HOME}/bin}
  DEPLUG_SRC=${DEPLUG_SRC:-${DEPLUG_HOME}/source}
  __dplg_f_main "$@"
}
__dplg_f_init() {
  mkdir -p ${DEPLUG_HOME} ${DEPLUG_REPO} ${DEPLUG_BIN}
  touch ${DEPLUG_STAT}
}
__dplg_f_setval() {
  echo $1 $2 | __dplg_f_logger 'setval' | __dplg_f_debug
  case $1 in
    as|dir|of|use|tag|post|from)
      if [[ -z $2 ]]
      then
        echo "'$1' is need a attribute" | __dplg_f_error
        return 1
      fi
      eval "__dplg_v_$1='$2'"
      ;;
    *)
      echo "Undefined option is '$1'" | __dplg_f_error
      return 1
  esac
  return 0
}
__dplg_f_parseArgs() {
  while [[ $# -gt 0 ]]
  do
    case $1 in
      --debug)
        __dplg_v_debug=1
        shift || break
        ;;
      --verbose|-v)
        __dplg_v_verbose=1
        shift || break
        ;;
      *:)
        __dplg_f_setval "${1%%:*}" "$2" || return 1
        shift 2 || break
        ;;
      *:*)
        __dplg_f_setval "${1%%:*}" "${1#*:}" || return 1
        shift || break
        ;;
      --*=*)
        __dplg_v_key=${1#--}
        __dplg_v_key=${__dplg_v_key%%=*}
        __dplg_f_setval "${__dplg_v_key}" "${1#*=}" || return 1
        shift || break
        ;;
      --*)
        __dplg_f_setval "${1#--}" "$2" || return 1
        shift 2 || break
        ;;
      */*)
        [[ -z "${__dplg_v_cmd}" ]] && __dplg_v_cmd=append
        __dplg_v_plugin=$1
        shift || break
        ;;
      *)
        __dplg_v_cmd=$1
        shift || break
        ;;
    esac
  done
  if [[ -z "${__dplg_v_as}" ]]
  then __dplg_v_as=${__dplg_v_plugin##*/}
  fi
  if [[ -z "${__dplg_v_dir}"  ]]
  then __dplg_v_dir="${DEPLUG_REPO}/${__dplg_v_as}"
  fi
}
__dplg_f_main() {
  local __dplg_v_errcode=0 __dplg_v_debug=0 __dplg_v_verbose=0
  local __dplg_v_key= \
    __dplg_v_pwd= \
    __dplg_v_cmd= \
    __dplg_v_plugin= \
    __dplg_v_as= \
    __dplg_v_dir= \
    __dplg_v_of= \
    __dplg_v_use= \
    __dplg_v_tag= \
    __dplg_v_post= \
    __dplg_v_from='https://github.com'
  __dplg_f_parseArgs "$@"
  if [[ -z "${__dplg_v_cmd}" ]]
  then
    __dplg_f_help
    return 1
  fi
  "__dplg_f_${__dplg_v_cmd}"
}
__dplg_f_include() {
  [[ -f ${DEPLUG_SRC} ]] || __dplg_f_reload
  echo ${DEPLUG_SRC} | __dplg_f_logger 'Included' | __dplg_f_verbose
  source "${DEPLUG_SRC}"
}
__dplg_f_defrost() {
  __dplg_f_init
  while read plug
  do
    __dplg_f_parse "${plug}"
    __dplg_f_stat | __dplg_f_logger 'defrost' | __dplg_f_debug
    echo "${__dplg_v_plugin}" | __dplg_f_logger 'Append..' | __dplg_f_verbose
    __dplg_f_append
  done < ${DEPLUG_STAT}
}
__dplg_f_freeze() {
  __dplg_f_init
  for plug in "${__dplg_v_plugins[@]}"
  do
    echo "${plug}" | __dplg_f_logger 'freeze' | __dplg_f_debug
    echo "${plug}"
  done > ${DEPLUG_STAT}
}
__dplg_f_reload() {
  [[ -z "${__dplg_v_plugins[@]}" ]] && return
  __dplg_f_init
  echo "export PATH=\${PATH}:${DEPLUG_BIN}" > ${DEPLUG_SRC}
  for plug in "${__dplg_v_plugins[@]}"
  do
    __dplg_f_parse "${plug}"
    __dplg_f_stat | __dplg_f_logger 'reload' | __dplg_f_debug
    {
      __dplg_f_of
      __dplg_f_use
    } &
  done | cat
}
__dplg_f_install() {
  [[ -z "${__dplg_v_plugins[@]}" ]] && return
  __dplg_f_init
  for plug in "${__dplg_v_plugins[@]}"
  do
    __dplg_f_parse "${plug}"
    __dplg_f_stat | __dplg_f_logger 'install' | __dplg_f_debug
    {
      echo "${__dplg_v_plugin}" | __dplg_f_logger 'Install..' | __dplg_f_info
      __dplg_f_download
      __dplg_f_post
      echo "${__dplg_v_plugin}" | __dplg_f_logger 'Installed' | __dplg_f_info
    } &
  done | cat
  __dplg_f_freeze
  __dplg_f_reload
}
__dplg_f_upgrade() {
  [[ -z "${__dplg_v_plugins[@]}" ]] && return
  __dplg_f_init
  for plug in "${__dplg_v_plugins[@]}"
  do
    __dplg_f_parse "${plug}"
    __dplg_f_stat | __dplg_f_logger 'upgrade' | __dplg_f_debug
    {
      echo "${__dplg_v_plugin}" | __dplg_f_logger 'Update..' | __dplg_f_info
      __dplg_f_update
      __dplg_f_post
      echo "${__dplg_v_plugin}" | __dplg_f_logger 'Updated'  | __dplg_f_info
    } &
  done | cat
  __dplg_f_freeze
  __dplg_f_reload
}
__dplg_f_clean() {
  __dplg_f_init
  declare -a __dplg_v_trash=()
  while read plug
  do
    __dplg_f_parse "${plug}"
    __dplg_f_stat | __dplg_f_logger 'clean' | __dplg_f_debug
    if [[ -z "${__dplg_v_plugins[${__dplg_v_as}]}" ]]
    then
      echo "${__dplg_v_dir}" | __dplg_f_logger 'Cleaning..' | __dplg_f_info
      __dplg_v_trash=("${__dplg_v_trash[@]}" "${__dplg_v_dir}")
    fi
  done < ${DEPLUG_STAT}
  if [[ ! -z "${__dplg_v_trash[@]}" ]]
  then
    \\rm -r "${__dplg_v_trash[@]}"
  fi
  __dplg_f_freeze
  __dplg_f_reload
}
__dplg_f_check() {
  for plug in "${__dplg_v_plugins[@]}"
  do
    __dplg_f_parse "${plug}"
    __dplg_f_stat | __dplg_f_logger 'check' | __dplg_f_debug
    echo "${__dplg_v_plugin}" | __dplg_f_logger 'Checking..' | __dplg_f_verbose
    [[ -d "${__dplg_v_dir}" ]] || return 1
  done
  return 0
}
__dplg_f_status() {
  local __dplg_v_isdir __dplg_v_iserr
  __dplg_v_iserr=0
  for plug in "${__dplg_v_plugins[@]}"
  do
    __dplg_f_parse "${plug}"
    __dplg_f_stat | __dplg_f_logger 'status' | __dplg_f_debug
    if [[ -d "${__dplg_v_dir}" ]]
    then
      __dplg_v_isdir='Installed'
    else
      __dplg_v_isdir='NoInstall'
      __dplg_v_iserr=1
    fi
    echo "${__dplg_v_plugin} (as:${__dplg_v_as}, dir:${__dplg_v_dir})" |
    __dplg_f_logger "${__dplg_v_isdir}" | __dplg_f_info
  done
  if [[ 0 -eq ${__dplg_v_verbose} ]]
  then return ${__dplg_v_iserr}
  fi
  __dplg_f_init
  while read plug
  do
    __dplg_f_parse "${plug}"
    __dplg_f_stat | __dplg_f_logger 'status' | __dplg_f_debug
    if [[ -z "${__dplg_v_plugins[${__dplg_v_as}]}" ]]
    then
      echo "${__dplg_v_plugin} (as:${__dplg_v_as}, dir:${__dplg_v_dir})" |
      __dplg_f_logger 'Cached' | __dplg_f_info
      __dplg_v_iserr=1
    fi
  done < ${DEPLUG_STAT}
  return ${__dplg_v_iserr}
}
__dplg_f_post() {
  [[ -d "${__dplg_v_dir}"  ]] || return 1
  [[ ! -z "${__dplg_v_post}" ]] || return 1
  __dplg_f_stat | __dplg_f_logger 'post' | __dplg_f_debug
  __dplg_v_pwd=$(pwd)
  cd "${__dplg_v_dir}"
  eval ${__dplg_v_post} 2>&1 |
  __dplg_f_logger ${__dplg_v_plugin} | __dplg_f_logger 'Doing..' | __dplg_f_verbose
  cd "${__dplg_v_pwd}"
}
__dplg_f_append() {
  __dplg_f_stat | __dplg_f_logger 'append' | __dplg_f_debug
  __dplg_v_plugins[${__dplg_v_as}]="$(__dplg_f_stat)"
}
__dplg_f_remove() {
  __dplg_f_stat | __dplg_f_logger 'remove' | __dplg_f_debug
  unset __dplg_v_plugins[${__dplg_v_as}]
}
__dplg_f_download() {
  __dplg_f_stat | __dplg_f_logger 'download' | __dplg_f_debug
  __dplg_v_pwd=$(pwd)
  case ${__dplg_v_from} in
    *)
      {
        if [[ ! -d "${__dplg_v_dir}" ]]
        then
          git clone "${__dplg_v_from}/${__dplg_v_plugin}" "${__dplg_v_dir}" 2>&1
        fi
        if [[ ! -z "${__dplg_v_tag}" ]]
        then
          {
            cd ${__dplg_v_dir}
            git checkout ${__dplg_v_tag} 2>&1
            cd ${__dplg_v_pwd}
          }
        fi
      } | __dplg_f_logger ${__dplg_v_plugin} | __dplg_f_logger 'Install..' | __dplg_f_verbose
      ;;
  esac
}
__dplg_f_update() {
  if [[ ! -d "${__dplg_v_dir}" ]]
  then
    echo "${__dplg_v_plugin} is not installed" | __dplg_f_logger 'Update..' | __dplg_f_verbose
    return 1
  fi
  __dplg_f_stat | __dplg_f_logger 'update' | __dplg_f_debug
  __dplg_v_pwd=$(pwd)
  cd ${__dplg_v_dir}
  case ${__dplg_v_from} in
    *)
      {
        git pull 2>&1
        [[ -z "${__dplg_v_tag}" ]] || git checkout ${__dplg_v_tag} 2>&1
      } | __dplg_f_logger ${__dplg_v_plugin} | __dplg_f_logger 'Update..' | __dplg_f_verbose
      ;;
  esac
  cd ${__dplg_v_pwd}
}
__dplg_f_of() {
  [[ ! -z "${__dplg_v_of}" ]] || return
  __dplg_f_stat | __dplg_f_logger 'of' | __dplg_f_debug
  __dplg_f_glob "${__dplg_v_dir}/${__dplg_v_of}" | while read srcfile
  do
    [[ -z "{srcfile}" ]] && continue
    echo "source '${srcfile}'"
  done | tee -a "${DEPLUG_SRC}" | __dplg_f_logger 'Include..' | __dplg_f_verbose
}
__dplg_f_use() {
  [[ ! -z ${__dplg_v_use} ]] || return
  __dplg_f_stat | __dplg_f_logger 'use' | __dplg_f_debug
  __dplg_f_glob "${__dplg_v_dir}/${__dplg_v_use}" | while read usefile
  do
    [[ -z "${usefile}" ]] && continue
    echo "${usefile}"
    ln -sf "${usefile}" ${DEPLUG_BIN} 2>&1 |
    __dplg_f_logger ${usefile} | __dplg_f_logger 'Using..' | __dplg_f_verbose
  done | __dplg_f_logger 'Using..' | __dplg_f_verbose
}
__dplg_f_help() {
  echo
}
__dplg_f_stat() {
  echo "as:${__dplg_v_as}#plugin:${__dplg_v_plugin}#dir:${__dplg_v_dir}#tag:${__dplg_v_tag}#of:${__dplg_v_of}#use:${__dplg_v_use}#post:${__dplg_v_post}#from:${__dplg_v_from}"
}
__dplg_f_error() {
  __dplg_f_logger '[ERROR]' | __dplg_f_info
  return 1
}
__dplg_f_debug() {
  [[ 0 -eq ${__dplg_v_debug} ]] && return
  __dplg_f_logger '[DEBUG]' | __dplg_f_info
}
__dplg_f_verbose() {
  [[ 0 -eq ${__dplg_v_verbose} ]] && return
  __dplg_f_info
}
__dplg_f_info() {
  while read line
  do echo "$line" >&2
  done
}
__dplg_f_logger() {
  while read line
  do echo "$(printf "%-10s" $1) $line"
  done
}
__dplg_f_glob() {
  echo "$@" | __dplg_f_logger 'glob' | __dplg_f_debug
  eval \\ls -1pd "$@"
}
__dplg_f_parse() {
  local __dplg_v_args=()
  __dplg_v_args=("${(s/#/)@}")
  __dplg_v_as=${__dplg_v_args[1]#as:}
  __dplg_v_plugin=${__dplg_v_args[2]#plugin:}
  __dplg_v_dir=${__dplg_v_args[3]#dir:}
  __dplg_v_tag=${__dplg_v_args[4]#tag:}
  __dplg_v_of=${__dplg_v_args[5]#of:}
  __dplg_v_use=${__dplg_v_args[6]#use:}
  __dplg_v_post=${__dplg_v_args[7]#post:}
  __dplg_v_from=${__dplg_v_args[8]#from:}
}
