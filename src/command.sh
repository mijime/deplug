#!/bin/bash

unset __dplg_v_plugins
declare -A __dplg_v_plugins=()

deplug() {
  local __dplg_v_errcode=0 __dplg_v_debug=0 __dplg_v_verbose=0 __dplg_v_yes=0
  local __dplg_v_key= \
    __dplg_v_home=~/.deplug \
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

  DEPLUG_HOME=${DEPLUG_HOME:-${__dplg_v_home}}
  DEPLUG_STAT=${DEPLUG_STAT:-${DEPLUG_HOME}/state}
  DEPLUG_REPO=${DEPLUG_REPO:-${DEPLUG_HOME}/repos}
  DEPLUG_BIN=${DEPLUG_BIN:-${DEPLUG_HOME}/bin}
  DEPLUG_SRC=${DEPLUG_SRC:-${DEPLUG_HOME}/source}

  if [[ -z "${__dplg_v_cmd}" ]]
  then
    __dplg_c_help
    return 1
  fi

  "__dplg_c_${__dplg_v_cmd}"
}

__dplg_c_include() {
  [[ -f ${DEPLUG_SRC} ]] || __dplg_c_reload

  echo Included.. ${DEPLUG_SRC} | __dplg_f_verbose
  source "${DEPLUG_SRC}"
}

__dplg_c_defrost() {
  __dplg_f_init

  while read plug
  do
    __dplg_f_parse "${plug}"
    __dplg_f_stat | __dplg_f_logger 'defrost' | __dplg_f_debug

    echo "${__dplg_v_plugin}" | __dplg_f_logger 'Append..' | __dplg_f_verbose
    __dplg_c_append
  done < ${DEPLUG_STAT}
}

__dplg_c_freeze() {
  __dplg_f_init

  for plug in "${__dplg_v_plugins[@]}"
  do
    echo "${plug}" | __dplg_f_logger 'freeze' | __dplg_f_debug
    echo "${plug}"
  done > ${DEPLUG_STAT}
}

__dplg_c_reload() {
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

__dplg_c_install() {
  [[ -z "${__dplg_v_plugins[@]}" ]] && return

  __dplg_f_init

  for plug in "${__dplg_v_plugins[@]}"
  do
    __dplg_f_parse "${plug}"
    __dplg_f_stat | __dplg_f_logger 'install' | __dplg_f_debug

    {
      echo "Install.. ${__dplg_v_plugin}" | __dplg_f_info
      __dplg_f_download 2>&1 | __dplg_f_logger "Install.. ${__dplg_v_plugin}" | __dplg_f_verbose
      __dplg_f_post     2>&1 | __dplg_f_logger "Install.. ${__dplg_v_plugin}" | __dplg_f_verbose
      echo "Installed ${__dplg_v_plugin}" | __dplg_f_info
    } &
  done | cat

  __dplg_c_freeze
  __dplg_c_reload
}

__dplg_c_update() {
  [[ -z "${__dplg_v_plugins[@]}" ]] && return

  __dplg_f_init

  for plug in "${__dplg_v_plugins[@]}"
  do
    __dplg_f_parse "${plug}"
    __dplg_f_stat | __dplg_f_logger 'update' | __dplg_f_debug

    {
      echo "Update.. ${__dplg_v_plugin}" | __dplg_f_info
      __dplg_f_update 2>&1 | __dplg_f_logger "Update.. ${__dplg_v_plugin}" | __dplg_f_verbose
      __dplg_f_post   2>&1 | __dplg_f_logger "Update.. ${__dplg_v_plugin}" | __dplg_f_verbose
      echo "Updated  ${__dplg_v_plugin}" | __dplg_f_info
    } &
  done | cat

  __dplg_c_freeze
  __dplg_c_reload
}

__dplg_c_clean() {
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
    local __dplug_v_ans

    if [[ 0 -eq ${__dplg_v_yes} ]]
    then
      echo -n 'Do you really want to clean? [y/N]: '
      read __dplug_v_ans
      echo
    else
      __dplug_v_ans=y
    fi

    if [[ "${__dplug_v_ans}" =~ y ]] ; then
      rm -r "${__dplg_v_trash[@]}"

      __dplg_c_freeze
      __dplg_c_reload
    fi
  fi
}

__dplg_c_check() {
  for plug in "${__dplg_v_plugins[@]}"
  do
    __dplg_f_parse "${plug}"
    __dplg_f_stat | __dplg_f_logger 'check' | __dplg_f_debug

    echo "${__dplg_v_plugin}" | __dplg_f_logger 'Checking..' | __dplg_f_verbose
    [[ -d "${__dplg_v_dir}" ]] || return 1
  done

  return 0
}

__dplg_c_status() {
  local __dplg_v_status __dplg_v_iserr
  __dplg_v_iserr=0

  __dplg_f_init

  for plug in "${__dplg_v_plugins[@]}"
  do
    __dplg_f_parse "${plug}"
    __dplg_f_stat | __dplg_f_logger 'status' | __dplg_f_debug

    if [[ 0 -eq ${__dplg_v_verbose} ]]
    then
      __dplg_v_status="${__dplg_v_plugin}"
    else
      __dplg_v_status="${__dplg_v_plugin} (as:${__dplg_v_as}, dir:${__dplg_v_dir})"
    fi

    if [[ -d "${__dplg_v_dir}" ]]
    then
      echo "Installed ${__dplg_v_status}"
    else
      echo "NoInstall ${__dplg_v_status}"
      __dplg_v_iserr=1
    fi
  done

  while read plug
  do
    __dplg_f_parse "${plug}"
    __dplg_f_stat | __dplg_f_logger 'status' | __dplg_f_debug

    [[ ! -z "${__dplg_v_plugins[${__dplg_v_as}]}" ]] && continue

    if [[ 0 -eq ${__dplg_v_verbose} ]]
    then
      __dplg_v_status="${__dplg_v_plugin}"
    else
      __dplg_v_status="${__dplg_v_plugin} (as:${__dplg_v_as}, dir:${__dplg_v_dir})"
    fi

    echo "Cached    ${__dplg_v_status}"
    __dplg_v_iserr=1
  done < ${DEPLUG_STAT}

  return ${__dplg_v_iserr}
}

__dplg_c_append() {
  __dplg_f_stat | __dplg_f_logger 'append' | __dplg_f_debug

  __dplg_v_plugins[${__dplg_v_as}]="as:${__dplg_v_as}#plugin:${__dplg_v_plugin}#dir:${__dplg_v_dir}#tag:${__dplg_v_tag}#of:${__dplg_v_of}#use:${__dplg_v_use}#post:${__dplg_v_post}#from:${__dplg_v_from}"
}

__dplg_c_remove() {
  __dplg_f_stat | __dplg_f_logger 'remove' | __dplg_f_debug

  unset __dplg_v_plugins[${__dplg_v_as}]
}

__dplg_c_help() {
  echo
}
