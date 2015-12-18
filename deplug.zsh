__dplg__command__load() {
  [[ ! -z ${deplugins[@]} ]] || return
  if [[ ! -f ${__g__cache} ]]
  then
    __dplg__init
    __dplg__plugins_prev | __dplg__save_cache > "${__g__cache}"
  fi
  source "${__g__cache}"
}
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
declare -a deplugins=()
deplug() {
  local -a __v__colo=()
  local __g__bin=
  local __g__cache=
  local __g__home=${DEPLUG_HOME:-~/.deplug}
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
  __g__bin=${DEPLUG_BIN:-${__g__home}/bin}
  __g__cache=${DEPLUG_CACHE:-${__g__home}/cache}
  __g__repos=${DEPLUG_REPO:-${__g__home}/repos}
  __g__state=${DEPLUG_STATE:-${__g__home}/state}
  __dplg__parse_arguments "$@"
  if [[ -z ${__v__cmd} ]]
  then
    __dplg__command__help
    return 1
  fi
  "__dplg__command__${__v__cmd}"
}
__dplg__command__append() {
  local __v__plug=$(__dplg__stringify 1)
  __dplg__append_plugin "${__v__plug}"
}
__dplg__command__help() {
  echo
}
__dplg__command__reset() {
  deplugins=()
}
__dplg__command__install() {
  [[ ! -z ${deplugins[@]} ]] || return
  __dplg__init
  local __v__plug=
  __dplg__plugins | while read __v__plug
  do
    __dplg__parse_line "${__v__plug}"
    __dplg__install &
  done | cat > "${__g__state}".bk
  mv "${__g__state}"{.bk,}
  __dplg__plugins | __dplg__save_cache > "${__g__cache}"
  __dplg__load_cache "${__g__cache}"
}
__dplg__install() {
  local __v__plug=
  local __v__errcode=0
  local __v__msgfmt=""
  case ${__v__status} in
    0|3)
      __dplg__stringify "${__v__status}"
      return
      ;;
  esac
  __dplg__message "${__v__colo[3]}Install..${__v__colo[9]} ${__v__as}"
  __dplg__install_plugin 2>&1 | __dplg__logger "${__v__colo[3]}Install..${__v__colo[9]} ${__v__as}:"
  if ! __dplg__pipestatus 0
  then
    __dplg__message "${__v__colo[2]}Failed${__v__colo[9]} ${__v__as} ${__v__colo[3]}"
    __dplg__stringify 4
    return
  fi
  if [[ ! -z ${__v__post} ]]
  then
    __dplg__post 2>&1 | __dplg__logger "${__v__colo[3]}Doing..${__v__colo[9]} ${__v__as}:"
    if ! __dplg__pipestatus 0
    then
      __dplg__message "${__v__colo[2]}Failed${__v__colo[9]} ${__v__as}"
      __dplg__stringify 4
      return
    fi
  fi
  __dplg__message "${__v__colo[4]}Installed${__v__colo[9]} ${__v__as}"
  __dplg__stringify 0
}
__dplg__install_plugin() {
  if [[ ! -d "${__v__dir}" ]]
  then
    git clone "${__v__from}" "${__v__dir}"
    __v__errcode=$?
    [[ ${__v__errcode} -gt 0 ]] && return 1
  fi
  if [[ ! -z "${__v__tag}" ]]
  then
    __v__pwd=$(pwd)
    cd "${__v__dir}" || return 1
    git checkout ${__v__tag}
    __v__errcode=$?
    if [[ ${__v__errcode} -gt 0 ]]
    then
      cd "${__v__pwd}"
      return 1
    fi
    cd "${__v__pwd}"
  fi
}
__dplg__init() {
  mkdir -p ${__g__home} ${__g__repos} ${__g__bin}
  touch ${__g__state} ${__g__cache}
}
__dplg__parse_arguments() {
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
  then __v__as=${__v__plugin##*/}
  fi
  if [[ -z "${__v__dir}"  ]]
  then __v__dir="${__g__repos}/${__v__as}"
  fi
  if [[ -z "${__v__from}"  ]]
  then __v__from="https://github.com/${__v__plugin}"
  fi
  if [[ 1 -eq ${__v__usecolo} ]]
  then __dplg__color
  fi
}
__dplg__post() {
  [[ -z ${__v__post} ]] && return
  __v__pwd=$(pwd)
  cd "${__v__dir}" || return 1
  eval ${__v__post}
  __v__errcode=$?
  if [[ ${__v__errcode} -gt 0 ]]
  then
    cd "${__v__pwd}"
    return 1
  fi
  cd "${__v__pwd}"
}
__dplg__of() {
  [[ -z ${__v__of} ]] && return
  __v__pwd=$(pwd)
  cd "${__v__dir}" || return 1
  __dplg__glob "${__v__of}" | while read srcfile
do
  [[ ! -z ${srcfile} ]] || continue
  echo "source '${__v__dir}/${srcfile}'"
done
cd "${__v__pwd}"
}
__dplg__use() {
  [[ -z ${__v__use} ]] && return
  __v__pwd=$(pwd)
  cd "${__v__dir}" || return 1
  __dplg__glob "${__v__use}" | while read usefile
do
  [[ ! -z ${usefile} ]] || continue
  ln -sf "${__v__dir}/${usefile}" "${__g__bin}/" 2>&1 | __dplg__message
done
cd "${__v__pwd}"
}
__dplg__glob() {
  eval \\ls -1pd "$@" 2>/dev/null
}
__dplg__load_cache() {
  source $1
}
__dplg__save_cache() {
  echo "echo \"\${PATH}\" | grep -c \"${__g__bin}\" >/dev/null || export PATH=\"\${PATH}:${__g__bin}\""
  local __v__plug=
  while read __v__plug
  do
    __dplg__parse_line "${__v__plug}"
    [[ 0 -eq ${__v__status} ]] || continue
    {
      __dplg__of
      __dplg__use
    } &
  done | cat
}
__dplg__message() {
  if [[ -z $@ ]]
  then
    while read msg
    do echo -e "${msg}" >&2
    done
  else
    echo -e "$@" >&2
  fi
}
__dplg__verbose() {
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
__dplg__logger() {
  [[ 0 -eq ${__v__verbose} ]] && return
  while read msg
  do
    [[ -z ${msg} ]] && continue
    echo -e "$@ ${msg}" >&2
  done
}
__dplg__stringify() {
  [[ ! -z ${__v__as} ]] || return
  echo "as:${__v__as}#plugin:${__v__plugin}#dir:${__v__dir}#tag:${__v__tag}#of:${__v__of}#use:${__v__use}#post:${__v__post}#from:${__v__from}#status:${1:-${__v__status}}"
}
# status 0 ... already installed
# status 1 ... not install
# status 2 ... changed
# status 3 ... cached
# status 4 ... error
__dplg__plugins() {
  {
    __dplg__plugins_curr | sed -e 's/^/when:curr#/g'
    __dplg__plugins_prev | sed -e 's/^/when:prev#/g'
  } \
    | awk -v FS="#" -v OFS="#" '
  {
    ctx=$3"#"$4"#"$5"#"$6"#"$7"#"$8"#"$9
    split($10,stat,":")
  }
  !st[$2] && $1=="when:curr" {
    pl[$2]=ctx
    when[$2]=$1
    st[$2]=1
    next
  }
  !st[$2] && $1=="when:prev" && stat[$2]==4 {
    pl[$2]=ctx
    when[$2]=$1
    st[$2]=4
    next
  }
  !st[$2] && $1=="when:prev" && stat[$2]!=4 {
    pl[$2]=ctx
    when[$2]=$1
    st[$2]=3
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
    next
  }
  pl[$2]!=ctx && $1=="when:prev" {
    st[$2]=2
    next
  }
  END { for(p in pl) { print p,pl[p],"status:"st[p] } }'
}
__dplg__plugins_prev() {
  cat "${__g__state}"
}
__dplg__plugins_curr() {
  for __v__plug in "${deplugins[@]}"
  do echo "${__v__plug}"
  done
}
__dplg__append_plugin() {
  deplugins=("${deplugins[@]}" "$@")
}
__dplg__command__update() {
  [[ ! -z ${deplugins[@]} ]] || return
  __dplg__init
  local __v__plug=
  __dplg__plugins | while read __v__plug
  do
    __dplg__parse_line "${__v__plug}"
    __dplg__update &
  done | cat > "${__g__state}".bk
  mv "${__g__state}"{.bk,}
  __dplg__plugins | __dplg__save_cache > "${__g__cache}"
  __dplg__load_cache "${__g__cache}"
}
__dplg__update() {
  local __v__plug=
  local __v__errcode=0
  local __v__msgfmt=""
  case ${__v__status} in
    3)
      __dplg__stringify "${__v__status}"
      return
      ;;
  esac
  __dplg__message "${__v__colo[3]}Update..${__v__colo[9]} ${__v__as}"
  __dplg__update_plugin 2>&1 | __dplg__logger "${__v__colo[3]}Update..${__v__colo[9]} ${__v__as}:"
  if ! __dplg__pipestatus 0
  then
    __dplg__message "${__v__colo[2]}Failed${__v__colo[9]} ${__v__as} ${__v__colo[3]}"
    __dplg__stringify 4
    return
  fi
  if [[ ! -z ${__v__post} ]]
  then
    __dplg__post 2>&1 | __dplg__logger "${__v__colo[3]}Doing..${__v__colo[9]} ${__v__as}:"
    if ! __dplg__pipestatus 0
    then
      __dplg__message "${__v__colo[2]}Failed${__v__colo[9]} ${__v__as}"
      __dplg__stringify 4
      return
    fi
  fi
  __dplg__message "${__v__colo[4]}Updated${__v__colo[9]} ${__v__as}"
  __dplg__stringify 0
}
__dplg__update_plugin() {
  __v__pwd=$(pwd)
  cd "${__v__dir}" || return 1
  git pull
  __v__errcode=$?
  if [[ ${__v__errcode} -gt 0 ]]
  then
    cd "${__v__pwd}"
    return 1
  fi
  if [[ ! -z "${__v__tag}" ]]
  then
    __v__pwd=$(pwd)
    cd "${__v__dir}" || return 1
    git checkout ${__v__tag}
    __v__errcode=$?
    if [[ ${__v__errcode} -gt 0 ]]
    then
      cd "${__v__pwd}"
      return 1
    fi
  fi
  cd "${__v__pwd}"
}
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
    if [[ 0 -eq ${__v__verbose} ]]
    then __v__display="${__v__as}"
    else __v__display="${__v__as} (plugin: ${__v__plugin}, dir: ${__v__dir})"
    fi
    case ${__v__status} in
      3|4)
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
__dplg__parse_line() {
  local -a __v__args=()
  __v__args=("${(s/#/)@}")
  __v__as=${__v__args[1]#as:}
  __v__plugin=${__v__args[2]#plugin:}
  __v__dir=${__v__args[3]#dir:}
  __v__tag=${__v__args[4]#tag:}
  __v__of=${__v__args[5]#of:}
  __v__use=${__v__args[6]#use:}
  __v__post=${__v__args[7]#post:}
  __v__from=${__v__args[8]#from:}
  __v__status=${__v__args[9]#status:}
}
__dplg__color() {
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
__dplg__pipestatus() {
  local -a __v__pipestatus=(${pipestatus[@]})
  return ${__v__pipestatus[$(($1 + 1))]}
}
__dplg__progress() {
  local -a progress=("|" "/" "-" "\\" "|")
  local inc=0
  while read line; do
    echo -n -e "\r${progress[$((inc++ % 5 + 1))]}" >&2
    echo -n -e "\r" >&2
    echo "${line}"
  done
  echo -n -e "\r" >&2
}
