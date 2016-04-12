#!/bin/bash

__sham__plug__write_stats() {
  case ${__v__stat} in
    [01234])
      __sham__plug__stringify >> "${__g__stats}".tmp
      ;;
  esac
}
