__sham__command__update() {
  [[ ! -z ${shamese_plugins[@]} ]] || return

  __sham__init

  local __v__plug=

  __sham__plugins | while read __v__plug
  do
    __sham__parse_line "${__v__plug}"
    __sham__update &
  done | cat > "${__g__state}".bk
  mv "${__g__state}"{.bk,}

  __sham__plugins | __sham__save_cache > "${__g__cache}"
  __sham__load_cache "${__g__cache}"
}

__sham__update() {
  local __v__plug=
  local __v__errcode=0
  local __v__msgfmt=""

  __sham__stringify | sed -e 's/^/[DEBUG] update /g' | __sham__verbose

  case ${__v__status} in
    3)
      __sham__stringify "${__v__status}"
      return
      ;;
  esac

  __sham__message "${__v__colo[3]}Update.. ${__v__colo[9]} ${__v__as}"

  __sham__update_plugin 2>&1 | __sham__logger "${__v__colo[3]}Update.. ${__v__colo[9]} ${__v__as}:"

  if ! __sham__pipestatus 0
  then
    __sham__message "${__v__colo[2]}Failed   ${__v__colo[9]} ${__v__as} ${__v__colo[3]}"
    __sham__stringify 4
    return
  fi

  if [[ ! -z ${__v__do} ]]
  then
    __sham__do 2>&1 | __sham__logger "${__v__colo[3]}Doing..  ${__v__colo[9]} ${__v__as}:"

    if ! __sham__pipestatus 0
    then
      __sham__message "${__v__colo[2]}Failed   ${__v__colo[9]} ${__v__as}"
      __sham__stringify 4
      return
    fi
  fi

  __sham__message "${__v__colo[7]}Updated  ${__v__colo[9]} ${__v__as}"
  __sham__stringify 0
}

__sham__update_plugin() {
  __v__pwd=$(pwd)

  cd "${__v__dir}" || return 1

  git pull

  __v__errcode=$?
  if [[ ${__v__errcode} -gt 0 ]]
  then
    cd "${__v__pwd}"
    return 1
  fi

  if [[ ! -z "${__v__at}" ]]
  then
    __v__pwd=$(pwd)
    cd "${__v__dir}" || return 1
    git checkout ${__v__at}

    __v__errcode=$?
    if [[ ${__v__errcode} -gt 0 ]]
    then
      cd "${__v__pwd}"
      return 1
    fi
  fi

  cd "${__v__pwd}"
}
