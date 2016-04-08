#!/bin/bash

__sham__plug__save() {
  if [[ -f "${__g__cache}".tmp ]]
  then mv "${__g__cache}"{.tmp,}
  fi

  if [[ -f "${__g__stats}".tmp ]]
  then mv "${__g__stats}"{.tmp,}
  fi
}
