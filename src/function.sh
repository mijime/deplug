__dplg_f_init() {
  mkdir -p ${__dplg_v_home} ${__dplg_v_repo} ${__dplg_v_bin}
  touch ${__dplg_v_state}
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
  eval ${__dplg_v_post} 2>&1
  cd "${__dplg_v_pwd}"
}

__dplg_f_download() {
  __dplg_v_pwd=$(pwd)
  case ${__dplg_v_from} in
    *)
      if [[ ! -d ${__dplg_v_dir} ]]
      then
        git clone "${__dplg_v_from}/${__dplg_v_plugin}" "${__dplg_v_dir}" 2>&1
      fi

      if [[ ! -z "${__dplg_v_tag}" ]]
      then
        cd "${__dplg_v_dir}" || return 1
        git checkout ${__dplg_v_tag}
        cd "${__dplg_v_pwd}"
      fi
      ;;
  esac
}

__dplg_f_update() {
  if [[ ! -d ${__dplg_v_dir} ]]
  then
    echo "[E] isn't installed"
    return 1
  fi

  __dplg_v_pwd=$(pwd)
  cd "${__dplg_v_dir}" || return 1
  case ${__dplg_v_from} in
    *)
      git pull

      if [[ ! -z "${__dplg_v_tag}" ]]
      then
        git checkout ${__dplg_v_tag}
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
    [[ -z ${srcfile} ]] && continue
    echo "source '${__dplg_v_dir}/${srcfile}'" | tee -a "${__dplg_v_cache}"
  done | __dplg_f_logger 'Include..' | __dplg_f_verbose
  cd "${__dplg_v_pwd}"
}

__dplg_f_use() {
  [[ -z ${__dplg_v_use} ]] && return

  __dplg_v_pwd=$(pwd)
  cd "${__dplg_v_dir}" || return 1
  __dplg_f_glob "${__dplg_v_use}" | while read usefile
  do
    [[ -z ${usefile} ]] && continue
    echo "${usefile} => ${__dplg_v_bin}/"
    ln -sf "${__dplg_v_dir}/${usefile}" "${__dplg_v_bin}/" 2>&1 | __dplg_f_logger ${usefile}
  done | __dplg_f_logger 'Using..' | __dplg_f_verbose
  cd "${__dplg_v_pwd}"
}

__dplg_f_verbose() {
  [[ 0 -eq ${__dplg_v_verbose} ]] && return

  while read line
  do echo -e "${__dplg_v_colo[${1:-yel}]}${line}${__dplg_v_colo[res]}"
  done >&2
}

__dplg_f_logger() {
  sed -e "s#^#$1 #g"
}

__dplg_f_glob() {
  eval \\ls -1pd "$@"
}
