declare -g -A deplugins

deplug() {
  local -A __dplg_v_colo=()
  local \
    __dplg_v_errcode=0 \
    __dplg_v_verbose=0 \
    __dplg_v_yes=0 \
    __dplg_v_usecolo=1 \
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

  __dplg_f_verbose "[DEBUG] command: ${__dplg_v_cmd}"
  "__dplg_c_${__dplg_v_cmd}"
}

__dplg_c_reset() {
  unset deplugins
  declare -g -A deplugins=()
}

__dplg_c_load() {
  [[ ! -z ${deplugins[@]} ]] || return

  __dplg_f_init

  if [[ -f ${__dplg_v_cache} ]]
  then __dplg_f_plugins | __dplg_f_save_cache > "${__dplg_v_cache}"
  fi

  source "${__dplg_v_cache}"
}

__dplg_c_install() {
  [[ ! -z ${deplugins[@]} ]] || return

  __dplg_f_init
  __dplg_f_check_plugins < ${__dplg_v_state}
  __dplg_f_plugins | __dplg_f_install > "${__dplg_v_state}"
  __dplg_f_defrost < "${__dplg_v_state}"

  __dplg_f_plugins | __dplg_f_save_cache > "${__dplg_v_cache}"
  __dplg_f_load_cache "${__dplg_v_cache}"
}

__dplg_c_upgrade() {
  [[ ! -z ${deplugins[@]} ]] || return

  __dplg_f_init
  __dplg_f_check_plugins < ${__dplg_v_state}
  __dplg_f_plugins | __dplg_f_upgrade > ${__dplg_v_state}
  __dplg_f_defrost < ${__dplg_v_state}

  __dplg_f_plugins | __dplg_f_save_cache > ${__dplg_v_cache}
  __dplg_f_load_cache "${__dplg_v_cache}"
}

__dplg_c_clean() {
  local -a __dplg_v_trash=()
  local __dplug_v_ans=

  __dplg_f_init
  __dplg_f_check_plugins < ${__dplg_v_state}

  for plug in "${deplugins[@]}"
  do
    __dplg_f_parse "${plug}"
    __dplg_f_stringify | sed -e 's/^/[DEBUG] clean /g' | __dplg_f_verbose

    if [[ 0 -eq ${__dplg_v_verbose} ]]
    then __dplg_v_display="${__dplg_v_as}"
    else __dplg_v_display="${__dplg_v_as} (plugin: ${__dplg_v_plugin}, dir: ${__dplg_v_dir})"
    fi

    case ${__dplg_v_status} in
      3|4)
        echo ${__dplg_v_status} | sed -e 's/^/[DEBUG] clean status /g' | __dplg_f_verbose
        __dplg_f_message "${__dplg_v_colo[yel]}Cached   ${__dplg_v_colo[res]} ${__dplg_v_display}"
        __dplg_v_trash=("${__dplg_v_trash[@]}" "${__dplg_v_as}")
        ;;
    esac
  done

  [[ -z "${__dplg_v_trash[@]}" ]] && return

  if [[ 0 -eq ${__dplg_v_yes} ]]
  then
    echo -n -e "${__dplg_v_colo[yel]}Do you really want to clean? [y/N]: ${__dplg_v_colo[res]}"
    read __dplug_v_ans
    echo
  else
    __dplug_v_ans=y
  fi

  if [[ "${__dplug_v_ans}" =~ y ]]
  then
    for __dplg_v_as in "${__dplg_v_trash[@]}"
    do
      __dplg_f_parse "${deplugins[${__dplg_v_as}]}"

      if [[ 0 -eq ${__dplg_v_verbose} ]]
      then __dplg_v_display="${__dplg_v_as}"
      else __dplg_v_display="${__dplg_v_as} (plugin: ${__dplg_v_plugin}, dir: ${__dplg_v_dir})"
      fi

      if [[ ! -z ${__dplg_v_dir} ]]
      then
        __dplg_f_message "${__dplg_v_colo[mag]}Clean..  ${__dplg_v_colo[res]} ${__dplg_v_display}"
        rm -rf "${__dplg_v_dir}"
        unset "deplugins[${__dplg_v_as}]"
        __dplg_f_message "${__dplg_v_colo[red]}Cleaned  ${__dplg_v_colo[res]} ${__dplg_v_display}"
      fi
    done
  fi

  __dplg_f_plugins | __dplg_f_freeze > ${__dplg_v_state}
}

__dplg_c_status() {
  local __dplg_v_display=
  local __dplg_v_iserr=0

  if [[ 0 -gt ${__dplg_v_verbose} ]]
  then __dplg_f_check_plugins < ${__dplg_v_state}
  fi

  for plug in "${deplugins[@]}"
  do
    __dplg_f_parse "${plug}"

    if [[ 0 -eq ${__dplg_v_verbose} ]]
    then __dplg_v_display="${__dplg_v_as}"
    else __dplg_v_display="${__dplg_v_as} (plugin: ${__dplg_v_plugin}, dir: ${__dplg_v_dir})"
    fi

    case ${__dplg_v_status} in
      0)
        __dplg_f_message "${__dplg_v_colo[cya]}Installed${__dplg_v_colo[res]} ${__dplg_v_display}"
        ;;
      1)
        __dplg_f_message "${__dplg_v_colo[mag]}NoInstall${__dplg_v_colo[res]} ${__dplg_v_display}"
        __dplg_v_iserr=1
        ;;
      2)
        __dplg_f_message "${__dplg_v_colo[blu]}Changed  ${__dplg_v_colo[res]} ${__dplg_v_display}"
        __dplg_v_iserr=1
        ;;
      3)
        __dplg_f_message "${__dplg_v_colo[yel]}Cached   ${__dplg_v_colo[res]} ${__dplg_v_display}"
        __dplg_v_iserr=1
        ;;
      4)
        __dplg_f_message "${__dplg_v_colo[red]}Failed   ${__dplg_v_colo[res]} ${__dplg_v_display}"
        __dplg_v_iserr=1
        ;;
    esac
  done

  return ${__dplg_v_iserr}
}

__dplg_c_append() {
  local plug=$(__dplg_f_stringify)

  if [[ ! -d ${__dplg_v_dir} ]]
  then __dplg_f_append 1
  elif [[ -z ${deplugins[${__dplg_v_as}]} ]]
  then __dplg_f_append 0
  elif [[ "${deplugins[${__dplg_v_as}]}" == "${plug}" ]]
  then __dplg_f_append 0
  else __dplg_f_append 2
  fi
}

__dplg_c_help() {
  echo
}
