#!/bin/bash

__sham__util__error() {
  if [[ -p /dev/stdin ]]
  then
    while read __v__tmp
    do echo "[E] ${__v__tmp}" >&2
    done
  else echo "[E] $@" >&2
  fi
}
