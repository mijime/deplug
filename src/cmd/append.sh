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
