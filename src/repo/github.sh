#!/bin/bash

__sham__repo__github() {
  __sham__util__repo_git "https://github.com/${__v__from#*://}"
}
