#!/bin/bash

__sham__plug__init() {
  mkdir -p "${__g__home}" "${__g__bin}" "${__g__repos}"
  touch {"${__g__cache}","${__g__stats}"}
}
