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
