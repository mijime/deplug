#!/bin/bash

__sham__repo__git() {
  __sham__util__repo_git "git://${__v__from#*://}"
}
