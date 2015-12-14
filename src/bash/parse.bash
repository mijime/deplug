__dplg_f_parse() {
  local __dplg_v_args=()

  IFS='#' read -ra __dplg_v_args <<< "$@"
  __dplg_v_as=${__dplg_v_args[0]#as:}
  __dplg_v_plugin=${__dplg_v_args[1]#plugin:}
  __dplg_v_dir=${__dplg_v_args[2]#dir:}
  __dplg_v_tag=${__dplg_v_args[3]#tag:}
  __dplg_v_of=${__dplg_v_args[4]#of:}
  __dplg_v_use=${__dplg_v_args[5]#use:}
  __dplg_v_post=${__dplg_v_args[6]#post:}
  __dplg_v_from=${__dplg_v_args[7]#from:}
}

__dplg_f_color() {
  __dplg_v_colo[bla]="\e[0;30m"
  __dplg_v_colo[red]="\e[0;31m"
  __dplg_v_colo[gre]="\e[0;32m"
  __dplg_v_colo[yel]="\e[0;33m"
  __dplg_v_colo[blu]="\e[0;34m"
  __dplg_v_colo[mag]="\e[0;35m"
  __dplg_v_colo[cya]="\e[0;36m"
  __dplg_v_colo[whi]="\e[0;37m"
  __dplg_v_colo[res]="\e[m"
}
