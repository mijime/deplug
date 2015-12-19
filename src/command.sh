declare -a shamese_plugins=()

sham() {
  local -a __v__colo=()
  local __g__bin=
  local __g__cache=
  local __g__home=${SHAM_HOME:-~/.sham}
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

  __g__bin=${SHAM_BIN:-${__g__home}/bin}
  __g__cache=${SHAM_CACHE:-${__g__home}/cache}
  __g__repos=${SHAM_REPO:-${__g__home}/repos}
  __g__state=${SHAM_STATE:-${__g__home}/state}

  __sham__parse_arguments "$@"

  if [[ -z ${__v__cmd} ]]
  then
    __sham__command__help
    return 1
  fi

  __sham__verbose "[DEBUG] command: ${__v__cmd}"
  "__sham__command__${__v__cmd}"
}

__sham__command__append() {
  local __v__plug=$(__sham__stringify 1)
  __sham__append_plugin "${__v__plug}"
}

__sham__command__help() {
  echo
}

__sham__command__reset() {
  shamese_plugins=()
}
