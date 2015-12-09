__dplg__parse() {
  local __dplg__args=()

  __dplg__args=("${(s/#/)@}")

  __dplg__name=${__dplg__args[1]#name:}
  __dplg__plugin=${__dplg__args[2]#plugin:}
  __dplg__dir=${__dplg__args[3]#dir:}
  __dplg__tag=${__dplg__args[4]#tag:}
  __dplg__post=${__dplg__args[5]#post:}
  __dplg__of=${__dplg__args[6]#of:}
  __dplg__use=${__dplg__args[7]#use:}
}
