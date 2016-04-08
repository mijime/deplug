#!/bin/bash


__sham__util__logger() {
  local \
    __v__tmp_prefix= \
    __v__tmp_level=1 \
    __v__tmp_out=/dev/stderr

  while [[ $# -gt 0 ]]
  do
    case $1 in
      --prefix)
        __v__tmp_prefix=$2
        shift 2 || break
        ;;

      --level)
        __v__tmp_level=$2
        shift 2 || break
        ;;

      --out)
        __v__tmp_out=$2
        shift 2 || break
        ;;
    esac
  done

  if [[ ${__v__logger} -lt ${__v__tmp_level} ]]
  then __v__tmp_out=/dev/null
  fi

  sed -e "s@^@${__v__tmp_prefix}@g" >> "${__v__tmp_out}"
}
