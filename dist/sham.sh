#!/bin/bash

__sham__cmd__append() {
  if [[ -z ${__v__as} ]]
  then __v__as=${__v__plug}
  fi

  if [[ -z ${__v__dir} ]]
  then __v__dir=${__g__repos}/${__v__as}
  fi

  if [[ -z ${__v__from} ]]
  then __v__from=github://${__v__plug}
  fi

  if [[ -d ${__v__dir} ]]
  then __v__stat=2
  else __v__stat=1
  fi

  SHAM_PLUGS=("${SHAM_PLUGS[@]}" "$(__sham__util__stringify)")
}
#!/bin/bash

__sham__cmd__clean() {
  local __v__tmp=

  __sham__util__disp_stat \
    | while read __v__tmp
      do
        __sham__util__parse

        case ${__v__stat} in
          [0-2])
            __sham__util__stringify
            ;;

          *)
            if [[ ! -d "${__v__dir}" ]]
            then continue
            fi

            {
              __sham__util__stringify 10
              rm -rf "${__v__dir}"
              __sham__util__stringify 11
            } &
            ;;
        esac
      done \
    | while read __v__tmp
      do
        __sham__util__parse
        __sham__util__disp_status >&2
        case ${__v__stat} in
          [0-4])
            echo "${__v__tmp}"
            ;;
        esac
      done \
    > "${__g__state}".tmp
  mv "${__g__state}"{.tmp,}

  if [[ -f "${__g__cache}".tmp ]]
  then
    mv "${__g__cache}"{.tmp,}
  fi

  unset SHAM_PLUGS
}
#!/bin/bash

__sham__cmd__update() {
  mkdir -p "${__g__home}" "${__g__bin}"

  local __v__tmp=

  __sham__util__disp_stat \
    | while read __v__tmp
      do
        __sham__util__parse

        case "${__v__stat}" in
          [13])
            __sham__util__stringify
            continue
            ;;
        esac

        __sham__util__sync &
      done \
    | while read __v__tmp
      do
        __sham__util__parse

        __sham__util__disp_status >&2

        case "${__v__stat}" in
          [0-4])
            echo "${__v__tmp}"
            ;;
        esac
      done \
    > "${__g__state}".tmp
  mv "${__g__state}"{.tmp,}

  if [[ -f "${__g__cache}".tmp ]]
  then
    mv "${__g__cache}"{.tmp,}
  fi

  unset SHAM_PLUGS
}
#!/bin/bash

__sham__cmd__status() {
  local __v__tmp=

  __sham__util__disp_stat \
    | while read __v__tmp
      do
        __sham__util__parse
        __sham__util__disp_status
      done
}
#!/bin/bash

__sham__cmd__load() {
  source "${__g__cache}";
}
#!/bin/bash

__sham__cmd__install() {
  mkdir -p "${__g__home}" "${__g__bin}"

  local __v__tmp=

  __sham__util__disp_stat \
    | while read __v__tmp
      do
        __sham__util__parse

        case "${__v__stat}" in
          [03])
            __sham__util__stringify
            continue
            ;;
        esac

        __sham__util__sync &
      done \
    | while read __v__tmp
      do
        __sham__util__parse

        __sham__util__disp_status >&2

        case "${__v__stat}" in
          [0-4])
            echo "${__v__tmp}"
            ;;
        esac
      done \
    > "${__g__state}".tmp
  mv "${__g__state}"{.tmp,}

  if [[ -f "${__g__cache}".tmp ]]
  then
    mv "${__g__cache}"{.tmp,}
  fi

  unset SHAM_PLUGS
}
#!/bin/bash

__sham__repo__github() {
  __sham__util__repo_git "https://github.com/${__v__from#*://}"
}
#!/bin/bash

__sham__repo__file() {
  __sham__util__repo_git "${__v__from#*://}"
}
#!/bin/bash

__sham__repo__git() {
  __sham__util__repo_git "git://${__v__from#*://}"
}
#!/bin/bash

__sham__util__repo_git() {
  local __v__git_url=$1
  shift

  case "${__g__cmd}" in
    install)
      if [[ ! -d "${__v__dir}" ]] && ! git clone "${__v__git_url}" "${__v__dir}"
      then
        return 1
      fi

      local __v__dir_curr=$(pwd)

      cd "${__v__dir}"

      if [[ ! -z "${__v__at}" ]] && ! git checkout "${__v__at}"
      then
        cd "${__v__dir_curr}"

        return 1
      fi

      cd "${__v__dir_curr}"
      ;;

    update)
      if [[ ! -d ${__v__dir} ]]
      then
        return 1
      fi

      local __v__dir_curr=$(pwd)

      cd "${__v__dir}"

      if ! git fetch
      then
        cd "${__v__dir_curr}"

        return 1
      fi

      if [[ ! -z "${__v__at}" ]] && ! git checkout "${__v__at}"
      then
        cd "${__v__dir_curr}"

        return 1
      fi

      if ! git pull
      then
        cd "${__v__dir_curr}"

        return 1
      fi

      cd "${__v__dir_curr}"
      ;;

    *)
      ;;
  esac

  return
}
#!/bin/bash

__sham__util__color() {
  __g__colo[0]="\033[m"
  __g__colo[1]="\033[30m"
  __g__colo[2]="\033[31m"
  __g__colo[3]="\033[32m"
  __g__colo[4]="\033[33m"
  __g__colo[5]="\033[34m"
  __g__colo[6]="\033[35m"
  __g__colo[7]="\033[36m"
}
#!/bin/bash

__sham__util__of() {
  local \
    __v__tmp_file= \
    __v__dir_curr=$(pwd)

  cd "${__v__dir}"

  for __v__tmp_file in $(eval "\\ls -1pd ${__v__of}" 2>/dev/null)
  do
    echo "source '${__v__dir}/${__v__tmp_file}';"
  done

  cd "${__v__dir_curr}"
}
#!/bin/bash

__sham__util__stringify() {
  local __v__tmp_stat=${1:-${__v__stat}}
  echo "@@#no=${__v__no}#as=${__v__as}#at=${__v__at}#dir=${__v__dir}#from=${__v__from}#of=${__v__of}#use=${__v__use}#do=${__v__do}#stat=${__v__tmp_stat}"
}
#!/bin/bash

__sham__util__parse() {
  __v__no=${__v__tmp#*#no=}
  __v__no=${__v__no%%#*=*}
  __v__as=${__v__tmp#*#as=}
  __v__as=${__v__as%%#*=*}
  __v__at=${__v__tmp#*#at=}
  __v__at=${__v__at%%#*=*}
  __v__dir=${__v__tmp#*#dir=}
  __v__dir=${__v__dir%%#*=*}
  __v__from=${__v__tmp#*#from=}
  __v__from=${__v__from%%#*=*}
  __v__of=${__v__tmp#*#of=}
  __v__of=${__v__of%%#*=*}
  __v__use=${__v__tmp#*#use=}
  __v__use=${__v__use%%#*=*}
  __v__do=${__v__tmp#*#do=}
  __v__do=${__v__do%%#*=*}
  __v__stat=${__v__tmp#*#stat=}
  __v__stat=${__v__stat%%#*=*}
}
#!/bin/bash

__sham__util__disp_stat() {
  if [[ -z ${SHAM_PLUGS} ]] && [[ -f "${__g__state}" ]]
  then
    cat "${__g__state}"
    return
  fi

  {
    if [[ -f "${__g__state}" ]]
    then
      cat "${__g__state}" \
        | awk -v FS="#" -v OFS="#" -v RS="@@|\n" -v ORS="@@" \
        '$0==""{next}{print"cache"$0}'
    fi

    echo "${SHAM_PLUGS[@]}"
  } \
    | awk -v FS="#" -v OFS="#" -v RS="@@|\n" -v ORS="\n" \
    'BEGIN{n=0}$3==""{next}
    !nl[$3]{nl[$3]=n++}
    {ctx=$3"#"$4"#"$5"#"$6"#"$7"#"$8"#"$9}
    $1=="cache"&&$10~/stat=[^4]/{st[$3]="stat=3"}
    $1=="cache"&&$10~/stat=[4]/{st[$3]="stat=4"}
    $1!="cache"&&$10~/stat=[^2]/{st[$3]=$10}
    $1!="cache"&&$10~/stat=[2]/{if(pl[$3]==ctx){st[$3]="stat=0"}else{st[$3]="stat=2"}}
    {pl[$3]=ctx}
    END{for(p in pl)print"#no="nl[p],pl[p],st[p]}'
}
#!/bin/bash

__sham__util__sync() {
  local __v__scheme=${__v__from%%://*}

  if hash __sham__repo__"${__v__scheme}" >/dev/null 2>/dev/null
  then
    __sham__util__stringify 5
    __sham__repo__"${__v__scheme}" 2>&1 \
      | sed "s@^@[${__v__as}] @g" >"${__v__logger}"

    if [[ ! -d ${__v__dir} ]]
    then
      __sham__util__stringify 4
      continue
    fi

  else
    printf "%10s %s: %s\n" "[ERROR]" "No specified command" "${__v__scheme}" >&2
    __sham__util__stringify 4
    continue
  fi

  if [[ ! -z ${__v__of} ]]
  then
    __sham__util__stringify 7
    __sham__util__of >> "${__g__cache}".tmp

    if [[ $? -gt 0 ]]
    then
      __sham__util__stringify 4
      continue
    fi
  fi

  if [[ ! -z ${__v__use} ]]
  then
    __sham__util__stringify 8
    __sham__util__use 2>&1 \
      | sed "s@^@[${__v__as}] @g" >"${__v__logger}"

    if [[ $? -gt 0 ]]
    then
      __sham__util__stringify 4
      continue
    fi
  fi

  if [[ ! -z ${__v__do} ]]
  then
    __sham__util__stringify 9
    __sham__util__do 2>&1 \
      | sed "s@^@[${__v__as}] @g" >"${__v__logger}"

    if [[ $? -gt 0 ]]
    then
      __sham__util__stringify 4
      continue
    fi
  fi

  __sham__util__stringify 0
}
#!/bin/bash

__sham__util__do() {
  local \
    __v__dir_curr=$(pwd)

  if [[ ! -d "${__v__dir}" ]]
  then
    echo 4
    return
  fi

  cd "${__v__dir}"

  if ! eval "${__v__do}"
  then
    cd "${__v__dir_curr}"
    echo 4
    return
  fi

  cd "${__v__dir_curr}"
  echo 0
  return
}
#!/bin/bash

__sham__util__disp_status() {
  local __v__format="%-12s %s\n"

  case "${__v__stat}" in
    0)
      printf "${__g__colo[7]}%-12s${__g__colo[0]} %s\n" Installed "${__v__as}"
      ;;
    1)
      printf "${__g__colo[3]}%-12s${__g__colo[0]} %s\n" NoInstall "${__v__as}"
      ;;
    2)
      printf "${__g__colo[5]}%-12s${__g__colo[0]} %s\n" Update "${__v__as}"
      ;;
    3)
      printf "${__g__colo[4]}%-12s${__g__colo[0]} %s\n" Cached "${__v__as}"
      ;;
    4)
      printf "${__g__colo[1]}%-12s${__g__colo[0]} %s\n" Failed "${__v__as}"
      ;;
    5)
      printf "${__g__colo[0]}%-12s${__g__colo[0]} %s\n" Install.. "${__v__as}"
      ;;
    7)
      printf "${__g__colo[3]}%-12s${__g__colo[0]} %s\n" Include.. "${__v__as}"
      ;;
    8)
      printf "${__g__colo[5]}%-12s${__g__colo[0]} %s\n" Link.. "${__v__as}"
      ;;
    9)
      printf "${__g__colo[7]}%-12s${__g__colo[0]} %s\n" Doing.. "${__v__as}"
      ;;
    10)
      printf "${__g__colo[2]}%-12s${__g__colo[0]} %s\n" Cleaning.. "${__v__as}"
      ;;
    11)
      printf "${__g__colo[6]}%-12s${__g__colo[0]} %s\n" Cleaned "${__v__as}"
      ;;
    *)
      ;;
  esac
}
#!/bin/bash

__sham__util__use() {
  local \
    __v__tmp_file= \
    __v__dir_curr=$(pwd)

  cd "${__v__dir}"

  for __v__tmp_file in $(eval "ls -1pd ${__v__use}" 2>/dev/null)
  do
    ln -sf "${__v__dir}/${__v__tmp_file}" "${__g__bin}/"
  done

  cd "${__v__dir_curr}"
}
#!/bin/bash

__sham__util__multiline() {
  local \
    __v__tmp_line=$1 \
    __v__tmp_n=

  shift || return 1

  printf "\\033[%dA%s\n" $((${__v__tmp_line} + 1)) "$*"
  for __v__tmp_n in $(seq ${__v__tmp_line})
  do printf "\n" ""
  done
}
#!/bin/bash

declare -a SHAM_PLUGS=()

sham() {
  local \
    __g__home=${SHAM_HOME:-~/.sham} \
    __g__bin= \
    __g__cache= \
    __g__repos= \
    __g__state= \
    __g__cmd= \
    __v__plug= \
    __v__no=0 \
    __v__as= \
    __v__at= \
    __v__dir= \
    __v__from= \
    __v__of= \
    __v__use= \
    __v__do= \
    __v__verbose= \
    __v__logger=/dev/null

  local -a \
    __g__colo=()

  __g__bin=${SHAM_BIN:-${__g__home}/bin}
  __g__cache=${SHAM_CACHE:-${__g__home}/cache}
  __g__repos=${SHAM_REPO:-${__g__home}/repos}
  __g__state=${SHAM_STATE:-${__g__home}/state}

  while [[ $# -gt 0 ]]
  do
    local __v__tmp=

    case $1 in
      --color|-c)
        __sham__util__color
        shift || break
        ;;

      --verbose|-v)
        __v__verbose=1
        shift || break
        ;;

      --logger|--as|--at|--dir|--from|--of|--use|--do)
        eval "__v__${1#--}=\"$2\""
        shift 2 || break
        ;;

      as:|at:|dir:|from:|of:|use:|do:)
        eval "__v__${1%%:*}=\"$2\""
        shift 2 || break
        ;;

      --logger=*|--as=*|--at=*|--dir=*|--from=*|--of=*|--use=*|--do=*)
        __v__tmp=${1%%=*}
        eval "__v__${__v__tmp#--}=\"${1#*=}\""
        shift || break
        ;;

      as:*|at:*|dir:*|from:*|of:*|use:*|do:*)
        eval "__v__${1%%:*}=\"${1#*:}\""
        shift || break
        ;;

      *://*/*)
        __g__cmd=append
        __v__from=$1
        __v__plug=${1#*://}
        shift || break
        ;;

      */*)
        __g__cmd=append
        __v__plug=$1
        shift || break
        ;;

      *)
        __g__cmd=$1
        shift || break
        ;;
    esac
  done

  if [[ -z ${__g__cmd} ]]
  then
    return
  elif hash "__sham__cmd__${__g__cmd}" >/dev/null 2>/dev/null
  then
    "__sham__cmd__${__g__cmd}" "$@"
  else
    printf "%10s %s: %s" "[ERROR]" "No specified command" "${__g__cmd}"
    return 1
  fi
}
