#!/bin/bash

__sham__util__parse() {
  __v__as=${__v__tmp#*#as=}
  __v__as=${__v__as%%#*=*}
  __v__at=${__v__tmp#*#at=}
  __v__at=${__v__at%%#*=*}
  __v__dir=${__v__tmp#*#dir=}
  __v__dir=${__v__dir%%#*=*}
  __v__from=${__v__tmp#*#from=}
  __v__from=${__v__from%%#*=*}
  __v__of=${__v__tmp#*#of=}
  __v__of=${__v__of%%#*=*}
  __v__use=${__v__tmp#*#use=}
  __v__use=${__v__use%%#*=*}
  __v__do=${__v__tmp#*#do=}
  __v__do=${__v__do%%#*=*}
  __v__stat=${__v__tmp#*#stat=}
  __v__stat=${__v__stat%%#*=*}
}
