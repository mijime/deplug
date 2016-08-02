#!/bin/bash

__sham__repo__file() {
  __sham__util__repo_git "$(readlink -f "${__v__from#*://}")/."
}
