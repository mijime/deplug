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
