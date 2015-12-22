__sham__parse_line() {
  local -a __v__args=()

  __v__args=("${(s/#/)@}")

  __v__as=${__v__args[1]#as:}
  __v__plugin=${__v__args[2]#plugin:}
  __v__dir=${__v__args[3]#dir:}
  __v__at=${__v__args[4]#at:}
  __v__of=${__v__args[5]#of:}
  __v__use=${__v__args[6]#use:}
  __v__do=${__v__args[7]#do:}
  __v__from=${__v__args[8]#from:}
  __v__status=${__v__args[9]#status:}
}

__sham__color() {
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
  local -a __v__pipestatus=(${pipestatus[@]})
  __sham__verbose "[DEBUG] pipestatus ${__v__pipestatus[@]}"
  return ${__v__pipestatus[$(($1 + 1))]}
}

__sham__progress() {
  local -a progress=("|" "/" "-" "\\" "|")
  local inc=0
  while read line; do
    echo -n -e "\r${progress[$((inc++ % 5 + 1))]}" >&2
    echo -n -e "\r" >&2
    echo "${line}"
  done
  echo -n -e "\r" >&2
}
