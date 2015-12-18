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
    echo "err: ${__v__errcode}"
    cd "${__v__pwd}"
    return 1
  fi

  echo "ok: ${__v__errcode}"
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
    print "[DEBUG]",1,$0 > "/dev/stderr"
    next
  }

  !st[$2] && $1=="when:prev" && stat[$2]==4 {
    pl[$2]=ctx
    when[$2]=$1
    st[$2]=4
    print "[DEBUG]",4,$0 > "/dev/stderr"
    next
  }

  !st[$2] && $1=="when:prev" && stat[$2]!=4 {
    pl[$2]=ctx
    when[$2]=$1
    st[$2]=3
    print "[DEBUG]",3,$0 > "/dev/stderr"
    next
  }

  (stat[2]==4 || st[$2]==4) && $1=="when:prev" {
    st[$2]=4
    print "[DEBUG]",4,$0 > "/dev/stderr"
    next
  }

  (stat[2]==4 || st[$2]==4) && $1=="when:curr" {
    pl[$2]=ctx
    when[$2]=$1
    st[$2]=4
    print "[DEBUG]",4,$0 > "/dev/stderr"
    next
  }

  pl[$2]==ctx && $1!=when[2] {
    when[$2]="when:curr"
    st[$2]=0
    print "[DEBUG]",0,$0 > "/dev/stderr"
    next
  }

  pl[$2]!=ctx && $1=="when:curr" {
    pl[$2]=ctx
    when[$2]=$1
    st[$2]=2
    print "[DEBUG]",2,$0 > "/dev/stderr"
    next
  }

  pl[$2]!=ctx && $1=="when:prev" {
    st[$2]=2
    print "[DEBUG]",2,$0 > "/dev/stderr"
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
