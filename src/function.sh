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
