__dplg__command__clean() {
  local __v__has_trash=0
  local __v__ans=

  __dplg__init

  __dplg__plugins | while read __v__plug
  do
    __dplg__parse_line "${__v__plug}"

    if [[ 0 -eq ${__v__verbose} ]]
    then __v__display="${__v__as}"
    else __v__display="${__v__as} (plugin: ${__v__plugin}, dir: ${__v__dir})"
    fi

    case ${__v__status} in
      3|4)
        __dplg__message "${__v__colo[7]}Cached   ${__v__colo[9]} ${__v__display}"
        __v__has_trash=1
        ;;
    esac
  done

  [[ 0 -eq ${__v__has_trash} ]] && return

  if [[ 0 -eq ${__v__yes} ]]
  then
    echo -n -e "${__v__colo[7]}Do you really want to clean? [y/N]: ${__v__colo[9]}"
    read __v__ans
    echo
  else
    __v__ans=y
  fi

  [[ "${__v__ans}" == "y" ]] || return
  __dplg__plugins | while read __v__plug
  do
    __dplg__parse_line "${__v__plug}"
    __dplg__stringify | sed -e 's/^/[DEBUG] clean /g' | __dplg__verbose

    if [[ 0 -eq ${__v__verbose} ]]
    then __v__display="${__v__as}"
    else __v__display="${__v__as} (plugin: ${__v__plugin}, dir: ${__v__dir})"
    fi

    case ${__v__status} in
      3|4)
        __dplg__stringify | sed -e 's/^/[DEBUG] clean /g' | __dplg__verbose
        __dplg__message "${__v__colo[5]}Clean..  ${__v__colo[9]} ${__v__display}"
        rm -rf "${__v__dir}" 2>&1 | __dplg__logger "${__v__colo[5]}Clean..  ${__v__colo[9]} ${__v__as}"
        __dplg__message "${__v__colo[1]}Cleaned  ${__v__colo[9]} ${__v__display}"
        ;;
      *)
        __dplg__stringify
        ;;
    esac
  done | cat > "${__g__state}".bk
  mv "${__g__state}"{.bk,}
}
