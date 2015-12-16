declare -g -A __dplg_v_plugins
deplug() {
  local -A __dplg_v_colo=()
  local __dplg_v_errcode=0 __dplg_v_verbose=0 __dplg_v_yes=0 __dplg_v_usecolo=1
  local \
    __dplg_v_errmsg= \
    __dplg_v_key= \
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
    __dplg_v_status= \
    __dplg_v_home=${DEPLUG_HOME:-~/.deplug} \
    __dplg_v_state= \
    __dplg_v_repo= \
    __dplg_v_bin= \
    __dplg_v_cache=
  __dplg_v_repo=${DEPLUG_REPO:-${__dplg_v_home}/repos}
  __dplg_v_state=${DEPLUG_STATE:-${__dplg_v_home}/state}
  __dplg_v_bin=${DEPLUG_BIN:-${__dplg_v_home}/bin}
  __dplg_v_cache=${DEPLUG_CACHE:-${__dplg_v_home}/cache}
  __dplg_f_parseArgs "$@"
  if [[ -z ${__dplg_v_cmd} ]]
  then
    __dplg_c_help
    return 1
  fi
  "__dplg_c_${__dplg_v_cmd}"
}
__dplg_c_reset() {
  unset __dplg_v_plugins
  declare -g -A __dplg_v_plugins=()
}
__dplg_c_include() {
  [[ -f ${__dplg_v_cache} ]] || __dplg_c_reload
  source "${__dplg_v_cache}"
}
__dplg_c_check() {
  __dplg_f_init
  while read plug
  do
    __dplg_f_parse "${plug}"
    [[ ! -z "${__dplg_v_plugins[${__dplg_v_as}]}" ]] || return 1
  done < ${__dplg_v_state}
}
__dplg_c_reload() {
  [[ ! -z ${__dplg_v_plugins[@]} ]] || return
  __dplg_f_init
  for plug in "${__dplg_v_plugins[@]}"
  do
    __dplg_f_parse "${plug}"
    __dplg_f_of
    __dplg_f_use
  done
}
__dplg_c_install() {
  [[ ! -z ${__dplg_v_plugins[@]} ]] || return
  __dplg_f_init
  __dplg_f_defrost < ${__dplg_v_state}
  __dplg_f_plugins | __dplg_f_install | cat > ${__dplg_v_state}
  __dplg_f_defrost < ${__dplg_v_state}
  __dplg_f_plugins | __dplg_f_freeze  | cat > ${__dplg_v_cache}
  __dplg_f_include
}
__dplg_c_upgrade() {
  [[ ! -z ${__dplg_v_plugins[@]} ]] || return
  __dplg_f_init
  __dplg_f_defrost < ${__dplg_v_state}
  __dplg_f_plugins | __dplg_f_upgrade | cat > ${__dplg_v_state}
  __dplg_f_defrost < ${__dplg_v_state}
  __dplg_f_plugins | __dplg_f_freeze  | cat > ${__dplg_v_cache}
  __dplg_f_include
}
__dplg_f_include() {
  source "${__dplg_v_cache}"
}
__dplg_f_freeze() {
  echo "export PATH=\"\${PATH}:${__dplg_v_bin}\""
  while read plug
  do
    __dplg_f_parse "${plug}"
    [[ 0 -eq ${__dplg_v_status} ]] || continue
    {
      __dplg_f_of
      __dplg_f_use
    } &
  done | cat
}
__dplg_f_message() {
  if [[ -z $@ ]]
  then
    while read msg
    do echo -e ${msg} >&2
    done
  else
    echo -e "$@" >&2
  fi
}
__dplg_f_defrost() {
  while read plug
  do
    __dplg_f_parse "${plug}"
    [[ ! -z ${__dplg_v_as} ]] || continue
    if [[ ! -d ${__dplg_v_dir} ]]
    then __dplg_f_append 1
    elif [[ -z ${__dplg_v_plugins[${__dplg_v_as}]} ]]
    then __dplg_f_append 3
    elif [[ "${__dplg_v_plugins[${__dplg_v_as}]}" == "${plug}" ]]
    then __dplg_f_append 0
    else
      __dplg_f_parse "${__dplg_v_plugins[${__dplg_v_as}]}"
      __dplg_f_append 2
    fi
  done
}
__dplg_f_plugins() {
  for plug in "${__dplg_v_plugins[@]}"
  do echo ${plug}
  done
}
__dplg_f_install() {
  local __dplg_v_errmsg= __dplg_v_errcode=0
  while read plug
  do
    __dplg_f_parse "${plug}"
    {
      __dplg_f_message "${__dplg_v_colo[blu]}Install..${__dplg_v_colo[res]} ${__dplg_v_as}"
      __dplg_v_errmsg=$(__dplg_f_download 2>&1)
      [[ 0 -eq $? ]] || __dplg_v_errcode=1
      if [[ 0 -eq ${__dplg_v_errcode} ]]
      then
        __dplg_v_errmsg=$(__dplg_f_post 2>&1)
        [[ 0 -eq $? ]] || __dplg_v_errcode=1
      fi
      if [[ 0 -eq ${__dplg_v_errcode} ]]
      then
        __dplg_f_message "${__dplg_v_colo[cya]}Installed${__dplg_v_colo[res]} ${__dplg_v_as} ${__dplg_v_colo[cya]}${__dplg_v_errmsg[@]}${__dplg_v_colo[res]}"
        __dplg_f_stringfy 0
      else
        __dplg_f_message "${__dplg_v_colo[mag]}Failed   ${__dplg_v_colo[res]} ${__dplg_v_as} ${__dplg_v_colo[mag]}${__dplg_v_errmsg[@]}${__dplg_v_colo[res]}"
        __dplg_f_stringfy 4
      fi
    } &
  done | cat
}
__dplg_f_upgrade() {
  local __dplg_v_errmsg= __dplg_v_errcode=0
  while read plug
  do
    __dplg_f_parse "${plug}"
    {
      __dplg_f_message "${__dplg_v_colo[blu]}Update.. ${__dplg_v_colo[res]} ${__dplg_v_as}"
      __dplg_v_errmsg=$(__dplg_f_update 2>&1)
      [[ 0 -eq $? ]] || __dplg_v_errcode=1
      if [[ 0 -eq ${__dplg_v_errcode} ]]
      then
        __dplg_v_errmsg=$(__dplg_f_post 2>&1)
        [[ 0 -eq $? ]] || __dplg_v_errcode=1
      fi
      if [[ 0 -eq ${__dplg_v_errcode} ]]
      then
        __dplg_f_message "${__dplg_v_colo[cya]}Updated  ${__dplg_v_colo[res]} ${__dplg_v_as} ${__dplg_v_colo[cya]}${__dplg_v_errmsg[@]}${__dplg_v_colo[res]}"
        __dplg_f_stringfy 0
      else
        __dplg_f_message "${__dplg_v_colo[mag]}Failed   ${__dplg_v_colo[res]} ${__dplg_v_as} ${__dplg_v_colo[mag]}${__dplg_v_errmsg[@]}${__dplg_v_colo[res]}"
        __dplg_f_stringfy 4
      fi
    } &
  done | cat
}
__dplg_f_stringfy() {
  [[ ! -z ${__dplg_v_as} ]] || return
  echo "as:${__dplg_v_as}#plugin:${__dplg_v_plugin}#dir:${__dplg_v_dir}#tag:${__dplg_v_tag}#of:${__dplg_v_of}#use:${__dplg_v_use}#post:${__dplg_v_post}#from:${__dplg_v_from}#status:${__dplg_v_status}"
}
__dplg_c_clean() {
  __dplg_f_init
  declare -a __dplg_v_trash=()
  while read plug
  do
    __dplg_f_parse "${plug}"
    if [[ -z ${__dplg_v_plugins[${__dplg_v_as}]} ]]
    then
      echo -e "${__dplg_v_colo[yel]}Cleaning.. ${__dplg_v_dir}${__dplg_v_colo[res]}"
      __dplg_v_trash=("${__dplg_v_trash[@]}" "${__dplg_v_dir}")
    fi
  done < ${__dplg_v_state}
  if [[ ! -z "${__dplg_v_trash[@]}" ]]
  then
    local __dplug_v_ans
    if [[ 0 -eq ${__dplg_v_yes} ]]
    then
      echo -n -e "${__dplg_v_colo[mag]}Do you really want to clean? [y/N]: ${__dplg_v_colo[res]}"
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
      echo -e "${__dplg_v_colo[mag]}NoInstall ${__dplg_v_status}${__dplg_v_colo[res]}"
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
  done < ${__dplg_v_state}
  return ${__dplg_v_iserr}
}
__dplg_c_append() {
  local plug=$(__dplg_f_stringfy)
  if [[ ! -d ${__dplg_v_dir} ]]
  then __dplg_f_append 1
  elif [[ -z ${__dplg_v_plugins[${__dplg_v_as}]} ]]
  then __dplg_f_append 0
  elif [[ "${__dplg_v_plugins[${__dplg_v_as}]}" == "${plug}" ]]
  then __dplg_f_append 0
  else __dplg_f_append 2
  fi
}
__dplg_f_append() {
  # status 0 ... already installed
  # status 1 ... not install
  # status 2 ... changed
  # status 3 ... cached
  # status 4 ... error
  __dplg_v_status=${1:-0}
  __dplg_v_plugins[${__dplg_v_as}]="as:${__dplg_v_as}#plugin:${__dplg_v_plugin}#dir:${__dplg_v_dir}#tag:${__dplg_v_tag}#of:${__dplg_v_of}#use:${__dplg_v_use}#post:${__dplg_v_post}#from:${__dplg_v_from}#status:${__dplg_v_status}"
}
__dplg_c_remove() {
  unset __dplg_v_plugins[${__dplg_v_as}]
}
__dplg_c_help() {
  echo
}
__dplg_f_init() {
  mkdir -p ${__dplg_v_home} ${__dplg_v_repo} ${__dplg_v_bin}
  touch ${__dplg_v_state} ${__dplg_v_cache}
}
__dplg_f_parseArgs() {
  while [[ $# -gt 0 ]]
  do
    case $1 in
      --yes|-y)
        __dplg_v_yes=1
        shift || break
        ;;
      --color)
        __dplg_v_usecolo=1
        shift || break
        ;;
      --no-color)
        __dplg_v_usecolo=0
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
        if [[ -z ${__dplg_v_cmd} ]]
        then
          __dplg_v_cmd=append
          __dplg_v_usecolo=0
        fi
        __dplg_v_plugin=$1
        shift || break
        ;;
      *)
        __dplg_v_cmd=$1
        shift || break
        ;;
    esac
  done
  if [[ -z ${__dplg_v_as} ]]
  then __dplg_v_as=${__dplg_v_plugin##*/}
  fi
  if [[ -z "${__dplg_v_dir}"  ]]
  then __dplg_v_dir="${__dplg_v_repo}/${__dplg_v_as}"
  fi
  if [[ 1 -eq ${__dplg_v_usecolo} ]]
  then __dplg_f_color
  fi
}
__dplg_f_post() {
  [[ -z ${__dplg_v_post} ]] && return
  __dplg_v_pwd=$(pwd)
  cd "${__dplg_v_dir}" || return 1
  eval ${__dplg_v_post}
  if [[ 0 -eq $? ]]
  then
    cd "${__dplg_v_pwd}"
  else
    cd "${__dplg_v_pwd}"
    return 1
  fi
}
__dplg_f_download() {
  case ${__dplg_v_from} in
    *)
      if [[ ! -d ${__dplg_v_dir} ]]
      then
        git clone "${__dplg_v_from}/${__dplg_v_plugin}" "${__dplg_v_dir}"
        [[ 0 -eq $? ]] || return 1
      fi
      if [[ ! -z "${__dplg_v_tag}" ]]
      then
        __dplg_v_pwd=$(pwd)
        cd "${__dplg_v_dir}" || return 1
        git checkout ${__dplg_v_tag}
        if [[ 0 -eq $? ]]
        then
          cd "${__dplg_v_pwd}"
        else
          cd "${__dplg_v_pwd}"
          return 1
        fi
      fi
      ;;
  esac
}
__dplg_f_update() {
  __dplg_v_pwd=$(pwd)
  cd "${__dplg_v_dir}" || return 1
  case ${__dplg_v_from} in
    *)
      git pull
      if [[ 0 -gt $? ]]
      then
        cd "${__dplg_v_pwd}"
        return 1
      fi
      if [[ ! -z "${__dplg_v_tag}" ]]
      then
        git checkout ${__dplg_v_tag}
        if [[ 0 -gt $? ]]
        then
          cd "${__dplg_v_pwd}"
          return 1
        fi
      fi
      ;;
  esac
  cd "${__dplg_v_pwd}"
}
__dplg_f_of() {
  [[ -z ${__dplg_v_of} ]] && return
  __dplg_v_pwd=$(pwd)
  cd "${__dplg_v_dir}" || return 1
  __dplg_f_glob "${__dplg_v_of}" | while read srcfile
  do
    [[ ! -z ${srcfile} ]] || continue
    echo "source '${__dplg_v_dir}/${srcfile}'"
  done
  cd "${__dplg_v_pwd}"
}
__dplg_f_use() {
  [[ -z ${__dplg_v_use} ]] && return
  __dplg_v_pwd=$(pwd)
  cd "${__dplg_v_dir}" || return 1
  __dplg_f_glob "${__dplg_v_use}" | while read usefile
  do
    [[ ! -z ${usefile} ]] || continue
    ln -sf "${__dplg_v_dir}/${usefile}" "${__dplg_v_bin}/" 2>&1 | __dplg_f_message
  done
  cd "${__dplg_v_pwd}"
}
__dplg_f_verbose() {
  [[ 0 -eq ${__dplg_v_verbose} ]] && return
  cat
}
__dplg_f_logger() {
  sed -e "s#^#$@ #g" >&2
}
__dplg_f_glob() {
  eval \\ls -1pd "$@"
}
__dplg_f_color() {
  __dplg_v_colo[bla]="\033[30m"
  __dplg_v_colo[red]="\033[31m"
  __dplg_v_colo[gre]="\033[32m"
  __dplg_v_colo[yel]="\033[33m"
  __dplg_v_colo[blu]="\033[34m"
  __dplg_v_colo[mag]="\033[35m"
  __dplg_v_colo[cya]="\033[36m"
  __dplg_v_colo[whi]="\033[37m"
  __dplg_v_colo[res]="\033[m"
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
  __dplg_v_status=${__dplg_v_args[9]#status:}
}
