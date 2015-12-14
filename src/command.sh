#!/bin/bash

unset __dplg_v_plugins
declare -A __dplg_v_plugins=()

deplug() {
  local -A __dplg_v_colo=()
  local __dplg_v_errcode=0 __dplg_v_verbose=0 __dplg_v_yes=0 __dplg_v_usecolo=1
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
    __dplg_v_from='https://github.com' \
    __dplg_v_home=${DEPLUG_HOME:-~/.deplug} \
    __dplg_v_stat= \
    __dplg_v_repo= \
    __dplg_v_bin= \
    __dplg_v_src=

  __dplg_v_repo=${DEPLUG_REPO:-${__dplg_v_home}/repos}
  __dplg_v_stat=${DEPLUG_STAT:-${__dplg_v_home}/state}
  __dplg_v_bin=${DEPLUG_BIN:-${__dplg_v_home}/bin}
  __dplg_v_src=${DEPLUG_SRC:-${__dplg_v_home}/source}

  __dplg_f_parseArgs "$@"

  if [[ -z "${__dplg_v_cmd}" ]]
  then
    __dplg_c_help
    return 1
  fi

  "__dplg_c_${__dplg_v_cmd}"
}

__dplg_c_include() {
  [[ -f ${__dplg_v_src} ]] || __dplg_c_reload

  echo Included.. ${__dplg_v_src} | __dplg_f_verbose
  source "${__dplg_v_src}"
}

__dplg_c_defrost() {
  __dplg_f_init

  while read plug
  do
    __dplg_f_parse "${plug}"
    echo "Append.. ${__dplg_v_plugin}" | __dplg_f_verbose
    __dplg_c_append
  done < ${__dplg_v_stat}
}

__dplg_c_freeze() {
  __dplg_f_init

  for plug in "${__dplg_v_plugins[@]}"
  do echo "${plug}"
  done > ${__dplg_v_stat}
}

__dplg_c_check() {
  __dplg_f_init

  while read plug
  do
    __dplg_f_parse "${plug}"
    [[ ! -z "${__dplg_v_plugins[${__dplg_v_as}]}" ]] || return 1
  done < ${__dplg_v_stat}
}

__dplg_c_reload() {
  [[ -z "${__dplg_v_plugins[@]}" ]] && return

  __dplg_f_init
  echo "export PATH=\${PATH}:\"${__dplg_v_bin}\"" > ${__dplg_v_src}

  for plug in "${__dplg_v_plugins[@]}"
  do
    __dplg_f_parse "${plug}"
    __dplg_f_of
    __dplg_f_use
  done
}

__dplg_c_install() {
  [[ -z "${__dplg_v_plugins[@]}" ]] && return

  __dplg_f_init

  for plug in "${__dplg_v_plugins[@]}"
  do
    __dplg_f_parse "${plug}"

    {
      echo -e "${__dplg_v_colo[gre]}Install.. ${__dplg_v_plugin}${__dplg_v_colo[res]}"
      __dplg_f_download 2>&1 | __dplg_f_logger "Install.. ${__dplg_v_plugin}" | __dplg_f_verbose
      __dplg_f_post     2>&1 | __dplg_f_logger "Install.. ${__dplg_v_plugin}" | __dplg_f_verbose
      echo -e "${__dplg_v_colo[cya]}Installed ${__dplg_v_plugin}${__dplg_v_colo[res]}"
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

    {
      echo -e "${__dplg_v_colo[gre]}Update.. ${__dplg_v_plugin}${__dplg_v_colo[res]}"
      __dplg_f_update 2>&1 | __dplg_f_logger "Update.. ${__dplg_v_plugin}" | __dplg_f_verbose
      __dplg_f_post   2>&1 | __dplg_f_logger "Update.. ${__dplg_v_plugin}" | __dplg_f_verbose
      echo -e "${__dplg_v_colo[cya]}Updated  ${__dplg_v_plugin}${__dplg_v_colo[res]}"
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

    if [[ -z "${__dplg_v_plugins[${__dplg_v_as}]}" ]]
    then
      echo -e "${__dplg_v_colo[gre]}Cleaning.. ${__dplg_v_dir}${__dplg_v_colo[res]}"
      __dplg_v_trash=("${__dplg_v_trash[@]}" "${__dplg_v_dir}")
    fi
  done < ${__dplg_v_stat}

  if [[ ! -z "${__dplg_v_trash[@]}" ]]
  then
    local __dplug_v_ans

    if [[ 0 -eq ${__dplg_v_yes} ]]
    then
      echo -n -e "${__dplg_v_colo[red]}Do you really want to clean? [y/N]: ${__dplg_v_colo[res]}"
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

__dplg_c_status() {
  local __dplg_v_status __dplg_v_iserr
  __dplg_v_iserr=0

  __dplg_f_init

  for plug in "${__dplg_v_plugins[@]}"
  do
    __dplg_f_parse "${plug}"

    if [[ 0 -eq ${__dplg_v_verbose} ]]
    then
      __dplg_v_status="${__dplg_v_plugin}"
    else
      __dplg_v_status="${__dplg_v_plugin} (as:${__dplg_v_as}, dir:${__dplg_v_dir})"
    fi

    if [[ -d "${__dplg_v_dir}" ]]
    then
      echo -e "${__dplg_v_colo[cya]}Installed ${__dplg_v_status}${__dplg_v_colo[res]}"
    else
      echo -e "${__dplg_v_colo[red]}NoInstall ${__dplg_v_status}${__dplg_v_colo[res]}"
      __dplg_v_iserr=1
    fi
  done

  while read plug
  do
    __dplg_f_parse "${plug}"

    [[ ! -z "${__dplg_v_plugins[${__dplg_v_as}]}" ]] && continue

    if [[ 0 -eq ${__dplg_v_verbose} ]]
    then
      __dplg_v_status="${__dplg_v_plugin}"
    else
      __dplg_v_status="${__dplg_v_plugin} (as:${__dplg_v_as}, dir:${__dplg_v_dir})"
    fi

    echo -e "${__dplg_v_colo[yel]}Cached    ${__dplg_v_status}${__dplg_v_colo[res]}"
    __dplg_v_iserr=1
  done < ${__dplg_v_stat}

  return ${__dplg_v_iserr}
}

__dplg_c_append() {
  __dplg_v_plugins[${__dplg_v_as}]="as:${__dplg_v_as}#plugin:${__dplg_v_plugin}#dir:${__dplg_v_dir}#tag:${__dplg_v_tag}#of:${__dplg_v_of}#use:${__dplg_v_use}#post:${__dplg_v_post}#from:${__dplg_v_from}"
}

__dplg_c_remove() {
  unset __dplg_v_plugins[${__dplg_v_as}]
}

__dplg_c_help() {
  echo
}
