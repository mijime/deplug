__dplg__command__install() {
  [[ ! -z ${deplugins[@]} ]] || return

  __dplg__init

  local __v__plug=

  __dplg__plugins | while read __v__plug
  do
    echo "${__v__plug}" | sed -e 's/^/[DEBUG] install:prev /g' | __dplg__verbose
    __dplg__parse_line "${__v__plug}"
    __dplg__install &
  done | cat > "${__g__state}".bk
  mv "${__g__state}"{.bk,}

  __dplg__plugins | __dplg__save_cache > "${__g__cache}"
  __dplg__load_cache "${__g__cache}"
}

__dplg__install() {
  local __v__plug=
  local __v__errcode=0
  local __v__msgfmt=""

  __dplg__stringify | sed -e 's/^/[DEBUG] install /g' | __dplg__verbose

  case ${__v__status} in
    0|3)
      __dplg__stringify "${__v__status}"
      return
      ;;
  esac

  __dplg__message "${__v__colo[3]}Install..${__v__colo[9]} ${__v__as}"

  __dplg__install_plugin 2>&1 | __dplg__logger "${__v__colo[3]}Install..${__v__colo[9]} ${__v__as}"

  if ! __dplg__pipestatus 0
  then
    __dplg__message "${__v__colo[2]}Failed${__v__colo[9]} ${__v__as} ${__v__colo[3]}"
    __dplg__stringify 4
    return
  fi

  if [[ ! -z ${__v__post} ]]
  then
    __dplg__post 2>&1 | __dplg__verbose "${__v__colo[3]}Install..${__v__colo[9]} ${__v__as}"

    if ! __dplg__pipestatus 0
    then
      __dplg__message "${__v__colo[2]}Failed${__v__colo[9]} ${__v__as}"
      __dplg__stringify 4
      return
    fi
  fi

  __dplg__message "${__v__colo[4]}Installed${__v__colo[9]} ${__v__as}"
  __dplg__stringify 0
}

__dplg__install_plugin() {
  if [[ ! -d "${__v__dir}" ]]
  then
    git clone "${__v__from}" "${__v__dir}"
    __v__errcode=$?
    [[ ${__v__errcode} -gt 0 ]] && return 1
  fi

  if [[ ! -z "${__v__tag}" ]]
  then
    __v__pwd=$(pwd)
    cd "${__v__dir}" || return 1
    git checkout ${__v__tag}
    __v__errcode=$?
    if [[ ${__v__errcode} -gt 0 ]]
    then
      cd "${__v__pwd}"
      return 1
    fi
    cd "${__v__pwd}"
  fi
}
