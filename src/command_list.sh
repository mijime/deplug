__dplg__command__list() {
  __dplg__init

  local __v__display=
  local __v__iserr=0

  __dplg__plugins | while read __v__plug
  do
    __dplg__parse_line "${__v__plug}"

    if [[ 0 -eq ${__v__verbose} ]]
    then __v__display="${__v__as}"
    else __v__display="${__v__as} (plugin: ${__v__plugin}, dir: ${__v__dir})"
    fi

    case ${__v__status} in
      0)
        __dplg__message "${__v__colo[4]}Installed${__v__colo[9]} ${__v__display}"
        ;;
      1)
        __dplg__message "${__v__colo[5]}NoInstall${__v__colo[9]} ${__v__display}"
        __v__iserr=1
        ;;
      2)
        __dplg__message "${__v__colo[6]}Changed  ${__v__colo[9]} ${__v__display}"
        __v__iserr=1
        ;;
      3)
        __dplg__message "${__v__colo[7]}Cached   ${__v__colo[9]} ${__v__display}"
        __v__iserr=1
        ;;
      4)
        __dplg__message "${__v__colo[1]}Failed   ${__v__colo[9]} ${__v__display}"
        __v__iserr=1
        ;;
    esac
  done

  return ${__v__iserr}
}
