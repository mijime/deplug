#!/bin/bash

__sham__util__disp_status() {
  case "${__v__stat}" in
    0)
      echo "Installed ${__v__as}"
      ;;
    1)
      echo "NoInstall ${__v__as}"
      ;;
    2)
      echo "Update    ${__v__as}"
      ;;
    3)
      echo "Cached    ${__v__as}"
      ;;
    4)
      echo "Failed    ${__v__as}"
      ;;
  esac
}
