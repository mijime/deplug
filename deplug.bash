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
__dplg_f_main() {
  local __dplg_v_errcode=0 __dplg_v_debug=0 __dplg_v_verbose=0
  local __dplg_v_plugin __dplg_v_pwd __dplg_v_cmd __dplg_v_tag __dplg_v_dir __dplg_v_post __dplg_v_name __dplg_v_of __dplg_v_use
  while [[ $# -gt 0 ]]
  do
    case $1 in
      --post|post:)
        __dplg_v_post=$2
        shift 2 || echo 'post is need a attribute' | __dplg_f_error || return 1
        ;;
      --tag|tag:)
        __dplg_v_tag=$2
        shift 2 || echo 'tag is need a attribute' | __dplg_f_error || return 1
        ;;
      --of|of:)
        __dplg_v_of=$2
        shift 2 || echo 'of is need a attribute' | __dplg_f_error || return 1
        ;;
      --use|use:)
        __dplg_v_use=$2
        shift 2 || echo 'use is need a attribute' | __dplg_f_error || return 1
        ;;
      --dir|dir:)
        __dplg_v_dir=$2
        shift 2 || echo 'dir is need a attribute' | __dplg_f_error || return 1
        ;;
      --name|name:)
        __dplg_v_name=$2
        shift 2 || echo 'name is need a attribute' | __dplg_f_error || return 1
        ;;
      --debug)
        __dplg_v_debug=1
        shift || break
        ;;
      --verbose|-v)
        __dplg_v_verbose=1
        shift || break
        ;;
      -*)
        echo "undefined option is $1" | __dplg_f_error || return 1
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
  if [[ -z "${__dplg_v_name}" ]]
  then __dplg_v_name=${__dplg_v_plugin##*/}
  fi
  if [[ -z "${__dplg_v_dir}"  ]]
  then __dplg_v_dir=${DEPLUG_REPO}/${__dplg_v_name}
  fi
  if [[ -z "${__dplg_v_cmd}" ]]
  then
    __dplg_f_help
    return 1
  fi
  "__dplg_f_${__dplg_v_cmd}"
}
__dplg_f_load() {
  echo ${DEPLUG_SRC} | __dplg_f_verbose 'Loading..'
  source "${DEPLUG_SRC}"
}
__dplg_f_install() {
  [[ -z "${__dplg_v_plugins[@]}" ]] && return
  __dplg_f_init
  echo > ${DEPLUG_SRC}
  for plug in "${__dplg_v_plugins[@]}"
  do
    __dplg_f_parse "${plug}"
    {
      echo "${__dplg_v_plugin}" | __dplg_f_verbose 'Install..'
      __dplg_f_download
      __dplg_f_of
      __dplg_f_post
      __dplg_f_use
      echo "${__dplg_v_plugin}" | __dplg_f_verbose 'Installed'
    } &
  done | cat
  __dplg_f_freeze
}
__dplg_f_defrost() {
  __dplg_f_init
  while read plug
  do
    __dplg_f_parse "${plug}"
    echo "${__dplg_v_plugin}" | __dplg_f_verbose 'Append..'
    __dplg_f_stat | __dplg_f_debug 'defrost'
    __dplg_f_append
  done < ${DEPLUG_STAT}
}
__dplg_f_freeze() {
  __dplg_f_init
  for plug in "${__dplg_v_plugins[@]}"
  do
    echo "${plug}" | __dplg_f_debug 'freeze'
    echo "${plug}"
  done > ${DEPLUG_STAT}
}
__dplg_f_upgrade() {
  [[ -z "${__dplg_v_plugins[@]}" ]] && return
  __dplg_f_init
  echo > ${DEPLUG_SRC}
  for plug in "${__dplg_v_plugins[@]}"
  do
    __dplg_f_parse "${plug}"
    {
      echo "${__dplg_v_plugin}" | __dplg_f_verbose 'Update..'
      __dplg_f_update
      __dplg_f_of
      __dplg_f_post
      __dplg_f_use
      echo "${__dplg_v_plugin}" | __dplg_f_verbose 'Updated'
    } &
  done | cat
}
__dplg_f_check() {
  for plug in "${__dplg_v_plugins[@]}"
  do
    __dplg_f_parse "${plug}"
    echo "${__dplg_v_plugin}" | __dplg_f_verbose 'Checking..'
    [[ ! -d "${__dplg_v_dir}" ]] && return 1
  done
  return 0
}
__dplg_f_status() {
  local __dplg_v_isdir __dplg_v_iserr
  __dplg_v_iserr=0
  for plug in "${__dplg_v_plugins[@]}"
  do
    __dplg_f_parse "${plug}"
    if [[ -d "${__dplg_v_dir}" ]]
    then
      __dplg_v_isdir='Installed'
    else
      __dplg_v_isdir='NoInstall'
      __dplg_v_iserr=1
    fi
    echo "${__dplg_v_plugin} (name:${__dplg_v_name}, dir:${__dplg_v_dir})" | __dplg_f_message "${__dplg_v_isdir}"
  done
  if [[ 0 -eq ${__dplg_v_verbose} ]]
  then return ${__dplg_v_iserr}
  fi
  __dplg_f_init
  while read plug
  do
    __dplg_f_parse "${plug}"
    if [[ -z "${__dplg_v_plugins[${__dplg_v_name}]}" ]]
    then
      echo "${__dplg_v_plugin} (name: ${__dplg_v_name}, dir: ${__dplg_v_dir}})" | __dplg_f_message 'Cached'
      __dplg_v_iserr=1
    fi
  done < ${DEPLUG_STAT}
  return ${__dplg_v_iserr}
}
__dplg_f_append() {
  __dplg_f_stat | __dplg_f_debug 'append'
  __dplg_v_plugins[${__dplg_v_name}]="$(__dplg_f_stat)"
}
__dplg_f_post() {
  __dplg_f_stat | __dplg_f_debug 'post'
  [[ ! -d "${__dplg_v_dir}" ]] && return 1
  [[ -z "${__dplg_v_post}" ]] && return 1
  __dplg_v_pwd=$(pwd)
  cd "${__dplg_v_dir}"
  eval ${__dplg_v_post} 2>&1 | __dplg_f_verbose 'Doing..'
  cd "${__dplg_v_pwd}"
}
__dplg_f_remove() {
  __dplg_f_stat | __dplg_f_debug 'remove'
  unset __dplg_v_plugins[${__dplg_v_name}]
}
__dplg_f_clean() {
  __dplg_f_init
  echo > ${DEPLUG_SRC}
  declare -a __dplg_v_trash=()
  while read plug
  do
    __dplg_f_parse "${plug}"
    __dplg_f_stat | __dplg_f_debug 'clean'
    if [[ -z "${__dplg_v_plugins[${__dplg_v_name}]}" ]]
    then
      echo "${__dplg_v_dir}" | __dplg_f_verbose 'Removed'
      __dplg_v_trash=("${__dplg_v_trash[@]}" "${__dplg_v_dir}")
    fi
  done < ${DEPLUG_STAT}
  if [[ ! -z "${__dplg_v_trash[@]}" ]]
  then
    \\rm -r "${__dplg_v_trash[@]}"
  fi
  __dplg_f_freeze
}
__dplg_f_download() {
  __dplg_f_stat | __dplg_f_debug 'download'
  __dplg_v_pwd=$(pwd)
  case ${__dplg_v_plugin} in
    *)
      if [[ ! -d "${__dplg_v_dir}" ]]
      then
        git clone "https://github.com/${__dplg_v_plugin}" "${__dplg_v_dir}" 2>&1 | __dplg_f_verbose 'Download'
      fi
      if [[ ! -z "${__dplg_v_tag}" ]]
      then
        {
          cd ${__dplg_v_dir}
          git checkout ${__dplg_v_tag} 2>&1 | __dplg_f_verbose 'Download'
          cd ${__dplg_v_pwd}
        }
      fi
      ;;
  esac
}
__dplg_f_update() {
  __dplg_f_stat | __dplg_f_debug 'update'
  [[ -d "${__dplg_v_dir}" ]] || echo "${__dplg_v_plugin} is not installed" | __dplg_f_error 'WARNING' || return 1
  __dplg_v_pwd=$(pwd)
  cd ${__dplg_v_dir}
  case ${__dplg_v_plugin} in
    *)
      git pull 2>&1 | __dplg_f_verbose 'Update..'
      [[ -z "${__dplg_v_tag}" ]] || git checkout ${__dplg_v_tag} 2>&1 | __dplg_f_verbose 'Update..'
      ;;
  esac
  cd ${__dplg_v_pwd}
}
__dplg_f_of() {
  __dplg_f_stat | __dplg_f_debug 'of'
  [[ -z "${__dplg_v_of}" ]] && return
  __dplg_f_glob "${__dplg_v_dir}/${__dplg_v_of}" | while read srcfile
  do
    [[ -z "{srcfile}" ]] && continue
    echo "${srcfile}" | __dplg_f_verbose 'Source'
    echo "source '${srcfile}'"
  done >> "${DEPLUG_SRC}"
}
__dplg_f_use() {
  __dplg_f_stat | __dplg_f_debug 'use'
  [[ -z ${__dplg_v_use} ]] && return
  __dplg_f_glob "${__dplg_v_dir}/${__dplg_v_use}" | while read usefile
  do
    [[ -z "${usefile}" ]] && continue
    echo "${usefile}" | __dplg_f_verbose 'Using'
    ln -sf "${usefile}" ${DEPLUG_BIN} 2>&1
  done | __dplg_f_verbose 'Using'
}
__dplg_f_help() {
  echo
}
__dplg_f_stat() {
  echo "name:${__dplg_v_name}#plugin:${__dplg_v_plugin}#dir:${__dplg_v_dir}#tag:${__dplg_v_tag}#post:${__dplg_v_post}#of:${__dplg_v_of}#use:${__dplg_v_use}"
}
__dplg_f_error() {
  __dplg_f_message 'ERROR'
  return 1
}
__dplg_f_debug() {
  [[ 0 -eq ${__dplg_v_debug} ]] && return
  local __dplg_v_message="${1:-${__dplg_v_name}}"
  __dplg_f_message "DEBUG:${__dplg_v_message}"
}
__dplg_f_verbose() {
  [[ 0 -eq ${__dplg_v_verbose} ]] && return
  local __dplg_v_message="${1:-INFO}"
  __dplg_f_message "${__dplg_v_message}"
}
__dplg_f_message() {
  while read line
  do
    printf "%-12s %s\n" "[${@:-INFO}]" "${line}" >&2
  done
}
__dplg_f_glob() {
  echo "$@" | __dplg_f_debug 'glob'
  eval \\ls -1pd "$@"
}
__dplg_f_parse() {
  local __dplg_v_args=()
  IFS='#' read -ra __dplg_v_args <<< "$@"
  __dplg_v_name=${__dplg_v_args[0]#name:}
  __dplg_v_plugin=${__dplg_v_args[1]#plugin:}
  __dplg_v_dir=${__dplg_v_args[2]#dir:}
  __dplg_v_tag=${__dplg_v_args[3]#tag:}
  __dplg_v_post=${__dplg_v_args[4]#post:}
  __dplg_v_of=${__dplg_v_args[5]#of:}
  __dplg_v_use=${__dplg_v_args[6]#use:}
}
