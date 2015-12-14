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

  __dplg_f_stat | __dplg_f_logger 'post' | __dplg_f_debug

  __dplg_v_pwd=$(pwd)
  cd "${__dplg_v_dir}"
  eval ${__dplg_v_post} 2>&1
  cd "${__dplg_v_pwd}"
}

__dplg_f_download() {
  __dplg_f_stat | __dplg_f_logger 'download' | __dplg_f_debug

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

  __dplg_f_stat | __dplg_f_logger 'update' | __dplg_f_debug

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

  __dplg_f_stat | __dplg_f_logger 'of' | __dplg_f_debug

  __dplg_f_glob "${__dplg_v_dir}/${__dplg_v_of}" | while read srcfile
  do
    [[ -z "{srcfile}" ]] && continue
    echo "source '${srcfile}'" | tee -a "${__dplg_v_src}"
  done | __dplg_f_logger 'Include..' | __dplg_f_verbose
}

__dplg_f_use() {
  [[ ! -z ${__dplg_v_use} ]] || return

  __dplg_f_stat | __dplg_f_logger 'use' | __dplg_f_debug

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
  echo "$@" | __dplg_f_logger 'glob' | __dplg_f_debug

  eval \\ls -1pd "$@"
}
