__dplg__command__load() {
  [[ ! -z ${deplugins[@]} ]] || return


  if [[ ! -f ${__g__cache} ]]
  then
    __dplg__init
    __dplg__plugins_prev | __dplg__save_cache > "${__g__cache}"
  fi

  source "${__g__cache}"
}
