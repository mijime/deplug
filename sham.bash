__sham__command__load() {
  [[ ! -z ${shamese_plugins[@]} ]] || return
  if [[ ! -f ${__g__cache} ]]
  then
    __sham__init
    __sham__plugins_prev | __sham__save_cache > "${__g__cache}"
  fi
  source "${__g__cache}"
}
__sham__command__list() {
  __sham__init
  local __v__display=
  local __v__iserr=0
  __sham__plugins | while read __v__plug
  do
    __sham__parse_line "${__v__plug}"
    if [[ 0 -eq ${__v__verbose} ]]
    then __v__display="${__v__as}"
    else __v__display="${__v__as} (plugin: ${__v__plugin}, dir: ${__v__dir})"
    fi
    case ${__v__status} in
      0)
        __sham__message "${__v__colo[7]}Installed${__v__colo[9]} ${__v__display}"
        ;;
      1)
        __sham__message "${__v__colo[3]}NoInstall${__v__colo[9]} ${__v__display}"
        __v__iserr=1
        ;;
      2)
        __sham__message "${__v__colo[5]}Changed  ${__v__colo[9]} ${__v__display}"
        __v__iserr=1
        ;;
      3)
        __sham__message "${__v__colo[4]}Cached   ${__v__colo[9]} ${__v__display}"
        __v__iserr=1
        ;;
      4)
        __sham__message "${__v__colo[2]}Failed   ${__v__colo[9]} ${__v__display}"
        __v__iserr=1
        ;;
    esac
  done
  return ${__v__iserr}
}
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
  local __v__do=
  local __v__pwd=
  local __v__status=
  local __v__at=
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
__sham__command__install() {
  [[ ! -z ${shamese_plugins[@]} ]] || return
  __sham__init
  local __v__plug=
  __sham__plugins | while read __v__plug
  do
    __sham__parse_line "${__v__plug}"
    __sham__install &
  done | cat > "${__g__state}".bk
  mv "${__g__state}"{.bk,}
  __sham__plugins | __sham__save_cache > "${__g__cache}"
  __sham__load_cache "${__g__cache}"
}
__sham__install() {
  local __v__plug=
  local __v__errcode=0
  local __v__msgfmt=""
  case ${__v__status} in
    0|3)
      __sham__stringify "${__v__status}"
      return
      ;;
  esac
  __sham__message "${__v__colo[3]}Install..${__v__colo[9]} ${__v__as}"
  __sham__install_plugin 2>&1 | __sham__logger "${__v__colo[3]}Install..${__v__colo[9]} ${__v__as}:"
  if ! __sham__pipestatus 0
  then
    __sham__message "${__v__colo[2]}Failed   ${__v__colo[9]} ${__v__as} ${__v__colo[3]}"
    __sham__stringify 4
    return
  fi
  if [[ ! -z ${__v__do} ]]
  then
    __sham__do 2>&1 | __sham__logger "${__v__colo[3]}Doing..  ${__v__colo[9]} ${__v__as}:"
    if ! __sham__pipestatus 0
    then
      __sham__message "${__v__colo[2]}Failed   ${__v__colo[9]} ${__v__as}"
      __sham__stringify 4
      return
    fi
  fi
  __sham__message "${__v__colo[7]}Installed${__v__colo[9]} ${__v__as}"
  __sham__stringify 0
}
__sham__install_plugin() {
  if [[ ! -d "${__v__dir}" ]]
  then
    git clone "${__v__from}" "${__v__dir}"
    __v__errcode=$?
    [[ ${__v__errcode} -gt 0 ]] && return 1
  fi
  if [[ ! -z "${__v__at}" ]]
  then
    __v__pwd=$(pwd)
    cd "${__v__dir}" || return 1
    git checkout ${__v__at}
    __v__errcode=$?
    if [[ ${__v__errcode} -gt 0 ]]
    then
      cd "${__v__pwd}"
      return 1
    fi
    cd "${__v__pwd}"
  fi
}
__sham__init() {
  mkdir -p ${__g__home} ${__g__repos} ${__g__bin}
  touch ${__g__state} ${__g__cache}
}
__sham__parse_arguments() {
  while [[ $# -gt 0 ]]
  do
    case $1 in
      --yes|-y)
        __v__yes=1
        shift || break
        ;;
      --color)
        __v__usecolo=1
        shift || break
        ;;
      --no-color)
        __v__usecolo=0
        shift || break
        ;;
      --verbose|-v)
        __v__verbose=1
        shift || break
        ;;
      *:)
        eval "__v__${1%%:*}='$2'" || return 1
        shift 2 || break
        ;;
      *:*)
        eval "__v__${1%%:*}='${1#*:}'" || return 1
        shift || break
        ;;
      --*=*)
        __v__key=${1#--}
        __v__key=${__v__key%%=*}
        eval "__v__${__v__key}='${1#*=}'" || return 1
        shift || break
        ;;
      --*)
        eval "__v__${1#--}='$2'" || return 1
        shift 2 || break
        ;;
      */*)
        if [[ -z ${__v__cmd} ]]
        then
          __v__cmd=append
          __v__usecolo=0
        fi
        __v__plugin=$1
        shift || break
        ;;
      *)
        __v__cmd=$1
        shift || break
        ;;
    esac
  done
  if [[ -z ${__v__as} ]]
  then __v__as=${__v__plugin}
  fi
  if [[ -z "${__v__dir}"  ]]
  then __v__dir="${__g__repos}/${__v__plugin}"
  fi
  if [[ -z "${__v__from}"  ]]
  then __v__from="https://github.com/${__v__plugin}.git"
  fi
  if [[ 1 -eq ${__v__usecolo} ]]
  then __sham__color
  fi
}
__sham__do() {
  [[ -z ${__v__do} ]] && return
  __v__pwd=$(pwd)
  cd "${__v__dir}" || return 1
  eval ${__v__do}
  __v__errcode=$?
  if [[ ${__v__errcode} -gt 0 ]]
  then
    cd "${__v__pwd}"
    return 1
  fi
  cd "${__v__pwd}"
}
__sham__of() {
  [[ -z ${__v__of} ]] && return
  __v__pwd=$(pwd)
  cd "${__v__dir}" || return 1
  __sham__glob "${__v__of}" | while read srcfile
do
  [[ ! -z ${srcfile} ]] || continue
  echo "source '${__v__dir}/${srcfile}'"
done
cd "${__v__pwd}"
}
__sham__use() {
  [[ -z ${__v__use} ]] && return
  __v__pwd=$(pwd)
  cd "${__v__dir}" || return 1
  __sham__glob "${__v__use}" | while read usefile
do
  [[ ! -z ${usefile} ]] || continue
  ln -sf "${__v__dir}/${usefile}" "${__g__bin}/" 2>&1 | __sham__message
done
cd "${__v__pwd}"
}
__sham__glob() {
  eval \\ls -1pd "$@" 2>/dev/null
}
__sham__load_cache() {
  source $1
}
__sham__save_cache() {
  echo "echo \"\${PATH}\" | grep -c \"${__g__bin}\" >/dev/null || export PATH=\"\${PATH}:${__g__bin}\""
  local __v__plug=
  while read __v__plug
  do
    __sham__parse_line "${__v__plug}"
    [[ 0 -eq ${__v__status} ]] || continue
    {
      __sham__of
      __sham__use
    } &
  done | cat
}
__sham__message() {
  if [[ -z $@ ]]
  then
    while read msg
    do echo -e "${msg}" >&2
    done
  else
    echo -e "$@" >&2
  fi
}
__sham__verbose() {
  [[ 0 -eq ${__v__verbose} ]] && return
  if [[ -z $@ ]]
  then
    while read msg
    do echo -e "${msg}" >&2
    done
  else
    echo -e "$@" >&2
  fi
}
__sham__logger() {
  if [[ 0 -eq ${__v__verbose} ]]
  then
    cat > /dev/null
  else
    while read msg
    do
      [[ -z ${msg} ]] && continue
      echo -e "$@ ${msg}" >&2
    done
  fi
}
__sham__stringify() {
  [[ ! -z ${__v__as} ]] || return
  echo "as:${__v__as}#plugin:${__v__plugin}#dir:${__v__dir}#at:${__v__at}#of:${__v__of}#use:${__v__use}#do:${__v__do}#from:${__v__from}#status:${1:-${__v__status}}"
}
# status 0 ... already installed
# status 1 ... not install
# status 2 ... changed
# status 3 ... cached
# status 4 ... error
__sham__plugins() {
  {
    __sham__plugins_curr | sed -e 's/^/when:curr#/g'
    __sham__plugins_prev | sed -e 's/^/when:prev#/g'
  } \
    | awk -v FS="#" -v OFS="#" '
  {
    ctx=$3"#"$4"#"$5"#"$6"#"$7"#"$8"#"$9
    split($10,stat,":")
  }
  !st[$2] && $1=="when:curr" {
    if (dir[$4] && when[$2]=="when:prev")
      delete pl[dir[$4]]
    pl[$2]=ctx
    when[$2]=$1
    st[$2]=1
    dir[$4]=$2
    next
  }
  !st[$2] && $1=="when:prev" && stat[$2]==4 {
    pl[$2]=ctx
    when[$2]=$1
    st[$2]=4
    dir[$4]=$2
    next
  }
  !st[$2] && $1=="when:prev" && stat[$2]!=4 {
    if (dir[$4])
      next
    pl[$2]=ctx
    when[$2]=$1
    st[$2]=3
    dir[$4]=$2
    next
  }
  (stat[2]==4 || st[$2]==4) && $1=="when:prev" {
    st[$2]=4
    next
  }
  (stat[2]==4 || st[$2]==4) && $1=="when:curr" {
    pl[$2]=ctx
    when[$2]=$1
    st[$2]=4
    dir[$4]=$2
    next
  }
  pl[$2]==ctx && $1!=when[2] {
    when[$2]="when:curr"
    st[$2]=0
    next
  }
  pl[$2]!=ctx && $1=="when:curr" {
    pl[$2]=ctx
    when[$2]=$1
    st[$2]=2
    dir[$4]=$2
    next
  }
  pl[$2]!=ctx && $1=="when:prev" {
    st[$2]=2
    next
  }
  END { for(p in pl) { print p,pl[p],"status:"st[p] } }'
}
__sham__plugins_prev() {
  cat "${__g__state}"
}
__sham__plugins_curr() {
  for __v__plug in "${shamese_plugins[@]}"
  do echo "${__v__plug}"
  done
}
__sham__append_plugin() {
  shamese_plugins=("${shamese_plugins[@]}" "$@")
}
__sham__command__update() {
  [[ ! -z ${shamese_plugins[@]} ]] || return
  __sham__init
  local __v__plug=
  __sham__plugins | while read __v__plug
  do
    __sham__parse_line "${__v__plug}"
    __sham__update &
  done | cat > "${__g__state}".bk
  mv "${__g__state}"{.bk,}
  __sham__plugins | __sham__save_cache > "${__g__cache}"
  __sham__load_cache "${__g__cache}"
}
__sham__update() {
  local __v__plug=
  local __v__errcode=0
  local __v__msgfmt=""
  case ${__v__status} in
    3)
      __sham__stringify "${__v__status}"
      return
      ;;
  esac
  __sham__message "${__v__colo[3]}Update.. ${__v__colo[9]} ${__v__as}"
  __sham__update_plugin 2>&1 | __sham__logger "${__v__colo[3]}Update.. ${__v__colo[9]} ${__v__as}:"
  if ! __sham__pipestatus 0
  then
    __sham__message "${__v__colo[2]}Failed   ${__v__colo[9]} ${__v__as} ${__v__colo[3]}"
    __sham__stringify 4
    return
  fi
  if [[ ! -z ${__v__do} ]]
  then
    __sham__do 2>&1 | __sham__logger "${__v__colo[3]}Doing..  ${__v__colo[9]} ${__v__as}:"
    if ! __sham__pipestatus 0
    then
      __sham__message "${__v__colo[2]}Failed   ${__v__colo[9]} ${__v__as}"
      __sham__stringify 4
      return
    fi
  fi
  __sham__message "${__v__colo[7]}Updated  ${__v__colo[9]} ${__v__as}"
  __sham__stringify 0
}
__sham__update_plugin() {
  __v__pwd=$(pwd)
  cd "${__v__dir}" || return 1
  git pull
  __v__errcode=$?
  if [[ ${__v__errcode} -gt 0 ]]
  then
    cd "${__v__pwd}"
    return 1
  fi
  if [[ ! -z "${__v__at}" ]]
  then
    __v__pwd=$(pwd)
    cd "${__v__dir}" || return 1
    git checkout ${__v__at}
    __v__errcode=$?
    if [[ ${__v__errcode} -gt 0 ]]
    then
      cd "${__v__pwd}"
      return 1
    fi
  fi
  cd "${__v__pwd}"
}
__sham__command__clean() {
  local __v__has_trash=0
  local __v__ans=
  __sham__init
  __sham__plugins | while read __v__plug
  do
    __sham__parse_line "${__v__plug}"
    if [[ 0 -eq ${__v__verbose} ]]
    then __v__display="${__v__as}"
    else __v__display="${__v__as} (plugin: ${__v__plugin}, dir: ${__v__dir})"
    fi
    case ${__v__status} in
      3|4)
        __sham__message "${__v__colo[4]}Cached   ${__v__colo[9]} ${__v__display}"
        __v__has_trash=1
        ;;
    esac
  done
  [[ 0 -eq ${__v__has_trash} ]] && return
  if [[ 0 -eq ${__v__yes} ]]
  then
    echo -n -e "${__v__colo[4]}Do you really want to clean? [y/N]: ${__v__colo[9]}"
    read __v__ans
    echo
  else
    __v__ans=y
  fi
  [[ "${__v__ans}" == "y" ]] || return
  __sham__plugins | while read __v__plug
  do
    __sham__parse_line "${__v__plug}"
    if [[ 0 -eq ${__v__verbose} ]]
    then __v__display="${__v__as}"
    else __v__display="${__v__as} (plugin: ${__v__plugin}, dir: ${__v__dir})"
    fi
    case ${__v__status} in
      3|4)
        __sham__message "${__v__colo[6]}Clean..  ${__v__colo[9]} ${__v__display}"
        rm -rf "${__v__dir}" 2>&1 | __sham__logger "${__v__colo[6]}Clean..  ${__v__colo[9]} ${__v__as}"
        __sham__message "${__v__colo[2]}Cleaned  ${__v__colo[9]} ${__v__display}"
        ;;
      *)
        __sham__stringify
        ;;
    esac
  done | cat > "${__g__state}".bk
  mv "${__g__state}"{.bk,}
}
__sham__parse_line() {
  local -a __v__args=()
  IFS='#' read -ra __v__args <<< "$@"
  __v__as=${__v__args[0]#as:}
  __v__plugin=${__v__args[1]#plugin:}
  __v__dir=${__v__args[2]#dir:}
  __v__at=${__v__args[3]#at:}
  __v__of=${__v__args[4]#of:}
  __v__use=${__v__args[5]#use:}
  __v__do=${__v__args[6]#do:}
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
