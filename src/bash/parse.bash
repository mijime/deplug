__dplg__parse() {
  local __dplg__args=()

  IFS='#' read -ra __dplg__args <<< "$@"
  __dplg__name=${__dplg__args[0]#name:}
  __dplg__plugin=${__dplg__args[1]#plugin:}
  __dplg__dir=${__dplg__args[2]#dir:}
  __dplg__tag=${__dplg__args[3]#tag:}
  __dplg__post=${__dplg__args[4]#post:}
  __dplg__of=${__dplg__args[5]#of:}
  __dplg__use=${__dplg__args[6]#use:}
}
