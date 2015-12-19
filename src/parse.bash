__sham__parse_line() {
  local -a __v__args=()

  IFS='#' read -ra __v__args <<< "$@"
  __v__as=${__v__args[0]#as:}
  __v__plugin=${__v__args[1]#plugin:}
  __v__dir=${__v__args[2]#dir:}
  __v__tag=${__v__args[3]#tag:}
  __v__of=${__v__args[4]#of:}
  __v__use=${__v__args[5]#use:}
  __v__post=${__v__args[6]#post:}
  __v__from=${__v__args[7]#from:}
  __v__status=${__v__args[8]#status:}
}

__sham__color() {
  __v__colo[0]="\033[m"
  __v__colo[1]="\033[30m"
  __v__colo[2]="\033[31m"
  __v__colo[3]="\033[32m"
  __v__colo[4]="\033[33m"
  __v__colo[5]="\033[34m"
  __v__colo[6]="\033[35m"
  __v__colo[7]="\033[36m"
  __v__colo[8]="\033[37m"
  __v__colo[9]="\033[m"
}

__sham__pipestatus() {
  local -a __v__pipestatus=(${PIPESTATUS[@]})
  __sham__verbose "[DEBUG] pipestatus ${__v__pipestatus[@]}"
  return ${__v__pipestatus[$1]}
}

__sham__progress() {
  local -a __v__progress=("|" "/" "-" "\\" "|")
  local __v__inc=0
  local __v__msg=
  while read __v__msg
  do
    echo -n -e "\r${__v__progress[$((__v__inc++ % 5))]}" >&2
    echo -n -e "\r" >&2
    echo "${__v__msg}"
  done
  echo -n -e "\r" >&2
}
