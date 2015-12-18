declare -a deplugins=()

deplug() {
  local -a __v__colo=()
  local __g__bin=
  local __g__cache=
  local __g__home=${DEPLUG_HOME:-~/.deplug}
  local __g__repos=
  local __g__state=
  local __v__as=
  local __v__cmd=
  local __v__dir=
  local __v__errcode=0
  local __v__errmsg=
  local __v__from=
  local __v__key=
  local __v__of=
  local __v__plugin=
  local __v__post=
  local __v__pwd=
  local __v__status=
  local __v__tag=
  local __v__use=
  local __v__usecolo=1
  local __v__verbose=0
  local __v__yes=0

  __g__bin=${DEPLUG_BIN:-${__g__home}/bin}
  __g__cache=${DEPLUG_CACHE:-${__g__home}/cache}
  __g__repos=${DEPLUG_REPO:-${__g__home}/repos}
  __g__state=${DEPLUG_STATE:-${__g__home}/state}

  __dplg__parse_arguments "$@"

  if [[ -z ${__v__cmd} ]]
  then
    __dplg__command__help
    return 1
  fi

  __dplg__verbose "[DEBUG] command: ${__v__cmd}"
  "__dplg__command__${__v__cmd}"
}

__dplg__command__append() {
  local __v__plug=$(__dplg__stringify 1)
  __dplg__append_plugin "${__v__plug}"
}

__dplg__command__help() {
  echo
}

__dplg__command__reset() {
  deplugins=()
}
