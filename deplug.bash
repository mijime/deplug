#!/bin/bash
unset __dplg_v_plugins
declare -A __dplg_v_plugins=()
deplug() {
  local __dplg_v_errcode=0 __dplg_v_debug=0 __dplg_v_verbose=0 __dplg_v_yes=0
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
    echo "${__dplg_v_plugin}" | __dplg_f_logger 'Append..' | __dplg_f_verbose
    __dplg_c_append
  done < ${__dplg_v_stat}
}
__dplg_c_freeze() {
  __dplg_f_init
  for plug in "${__dplg_v_plugins[@]}"
  do
    echo "${plug}"
  done > ${__dplg_v_stat}
}
__dplg_c_reload() {
  [[ -z "${__dplg_v_plugins[@]}" ]] && return
  __dplg_f_init
  echo "export PATH=\${PATH}:\"${__dplg_v_bin}\"" > ${__dplg_v_src}
  for plug in "${__dplg_v_plugins[@]}"
  do
    __dplg_f_parse "${plug}"
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
    if [[ -z "${__dplg_v_plugins[${__dplg_v_as}]}" ]]
    then
      echo "${__dplg_v_dir}" | __dplg_f_logger 'Cleaning..' | __dplg_f_info
      __dplg_v_trash=("${__dplg_v_trash[@]}" "${__dplg_v_dir}")
    fi
  done < ${__dplg_v_stat}
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
    echo "Checking.. ${__dplg_v_plugin}" | __dplg_f_verbose
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
    [[ ! -z "${__dplg_v_plugins[${__dplg_v_as}]}" ]] && continue
    if [[ 0 -eq ${__dplg_v_verbose} ]]
    then
      __dplg_v_status="${__dplg_v_plugin}"
    else
      __dplg_v_status="${__dplg_v_plugin} (as:${__dplg_v_as}, dir:${__dplg_v_dir})"
    fi
    echo "Cached    ${__dplg_v_status}"
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
__dplg_f_init() {
  mkdir -p ${__dplg_v_home} ${__dplg_v_repo} ${__dplg_v_bin}
  touch ${__dplg_v_stat}
}
__dplg_f_parseArgs() {
  while [[ $# -gt 0 ]]
  do
    case $1 in
      --debug)
        __dplg_v_debug=1
        shift || break
        ;;
      --yes|-y)
        __dplg_v_yes=1
        shift || break
        ;;
      --verbose|-v)
        __dplg_v_verbose=1
        shift || break
        ;;
      *:)
        eval "__dplg_v_${1%%:*}='$2'" || return 1
        shift 2 || break
        ;;
      *:*)
        eval "__dplg_v_${1%%:*}='${1#*:}'" || return 1
        shift || break
        ;;
      --*=*)
        __dplg_v_key=${1#--}
        __dplg_v_key=${__dplg_v_key%%=*}
        eval "__dplg_v_${__dplg_v_key}='${1#*=}'" || return 1
        shift || break
        ;;
      --*)
        eval "__dplg_v_${1#--}='$2'" || return 1
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
  then __dplg_v_dir="${__dplg_v_repo}/${__dplg_v_as}"
  fi
}
__dplg_f_post() {
  [[ -d "${__dplg_v_dir}"  ]] || return 1
  [[ ! -z "${__dplg_v_post}" ]] || return 1
  __dplg_v_pwd=$(pwd)
  cd "${__dplg_v_dir}"
  eval ${__dplg_v_post} 2>&1
  cd "${__dplg_v_pwd}"
}
__dplg_f_download() {
  __dplg_v_pwd=$(pwd)
  case ${__dplg_v_from} in
    *)
      if [[ ! -d "${__dplg_v_dir}" ]]
      then
        git clone "${__dplg_v_from}/${__dplg_v_plugin}" "${__dplg_v_dir}" 2>&1
      fi
      if [[ ! -z "${__dplg_v_tag}" ]]
      then
        cd ${__dplg_v_dir}
        git checkout ${__dplg_v_tag}
        cd ${__dplg_v_pwd}
      fi
      ;;
  esac
}
__dplg_f_update() {
  if [[ ! -d "${__dplg_v_dir}" ]]
  then
    echo "[E] isn't installed"
    return 1
  fi
  __dplg_v_pwd=$(pwd)
  cd ${__dplg_v_dir}
  case ${__dplg_v_from} in
    *)
      git pull
      if [[ ! -z "${__dplg_v_tag}" ]]
      then
        git checkout ${__dplg_v_tag}
      fi
      ;;
  esac
  cd ${__dplg_v_pwd}
}
__dplg_f_of() {
  [[ ! -z "${__dplg_v_of}" ]] || return
  __dplg_f_glob "${__dplg_v_dir}/${__dplg_v_of}" | while read srcfile
  do
    [[ -z "{srcfile}" ]] && continue
    echo "source '${srcfile}'" | tee -a "${__dplg_v_src}"
  done | __dplg_f_logger 'Include..' | __dplg_f_verbose
}
__dplg_f_use() {
  [[ ! -z ${__dplg_v_use} ]] || return
  __dplg_f_glob "${__dplg_v_dir}/${__dplg_v_use}" | while read usefile
  do
    [[ -z "${usefile}" ]] && continue
    echo "${usefile} => ${__dplg_v_bin}"
    ln -sf "${usefile}" "${__dplg_v_bin}" 2>&1 | __dplg_f_logger ${usefile}
  done | __dplg_f_logger 'Using..' | __dplg_f_verbose
}
__dplg_f_stat() {
  echo "as:${__dplg_v_as}#plugin:${__dplg_v_plugin}#dir:${__dplg_v_dir}#tag:${__dplg_v_tag}#of:${__dplg_v_of}#use:${__dplg_v_use}#post:${__dplg_v_post}#from:${__dplg_v_from}"
}
__dplg_f_error() {
  sed -e 's#^#[ERROR] #g' >&2
  return 1
}
__dplg_f_debug() {
  [[ 0 -eq ${__dplg_v_debug} ]] && return
  sed -e 's#^#[DEBUG] #g' >&2
}
__dplg_f_verbose() {
  [[ 0 -eq ${__dplg_v_verbose} ]] && return
  cat >&2
}
__dplg_f_info() {
  cat >&2
}
__dplg_f_logger() {
  sed -e "s#^#$1 #g"
}
__dplg_f_glob() {
  eval \\ls -1pd "$@"
}
__dplg_f_parse() {
  local __dplg_v_args=()
  IFS='#' read -ra __dplg_v_args <<< "$@"
  __dplg_v_as=${__dplg_v_args[0]#as:}
  __dplg_v_plugin=${__dplg_v_args[1]#plugin:}
  __dplg_v_dir=${__dplg_v_args[2]#dir:}
  __dplg_v_tag=${__dplg_v_args[3]#tag:}
  __dplg_v_of=${__dplg_v_args[4]#of:}
  __dplg_v_use=${__dplg_v_args[5]#use:}
  __dplg_v_post=${__dplg_v_args[6]#post:}
  __dplg_v_from=${__dplg_v_args[7]#from:}
}
