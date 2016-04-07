#!/bin/bash

__sham__util__disp_status() {
  local __v__format="%-12s %s\n"

  case "${__v__stat}" in
    0)
      printf "${__v__format}" Installed "${__v__as}"
      ;;
    1)
      printf "${__v__format}" NoInstall "${__v__as}"
      ;;
    2)
      printf "${__v__format}" Changed "${__v__as}"
      ;;
    3)
      printf "${__v__format}" Cached "${__v__as}"
      ;;
    4)
      printf "${__v__format}" Failed "${__v__as}"
      ;;
    5)
      printf "${__v__format}" Install.. "${__v__as}"
      ;;
    7)
      printf "${__v__format}" Include.. "${__v__as}"
      ;;
    8)
      printf "${__v__format}" Link.. "${__v__as}"
      ;;
    9)
      printf "${__v__format}" Doing.. "${__v__as}"
      ;;
    10)
      printf "${__v__format}" Cleaning.. "${__v__as}"
      ;;
    11)
      printf "${__v__format}" Cleaned "${__v__as}"
      ;;
    *)
      ;;
  esac
}
