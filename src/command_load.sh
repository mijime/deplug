__sham__command__load() {
  [[ ! -z ${shamese_plugins[@]} ]] || return


  if [[ ! -f ${__g__cache} ]]
  then
    __sham__init
    __sham__plugins_prev | __sham__save_cache > "${__g__cache}"
  fi

  source "${__g__cache}"
}
