__dplg_f_parse() {
  local __dplg_v_args=()

  IFS='#' read -ra __dplg_v_args <<< "$@"
  __dplg_v_name=${__dplg_v_args[0]#name:}
  __dplg_v_plugin=${__dplg_v_args[1]#plugin:}
  __dplg_v_dir=${__dplg_v_args[2]#dir:}
  __dplg_v_tag=${__dplg_v_args[3]#tag:}
  __dplg_v_post=${__dplg_v_args[4]#post:}
  __dplg_v_of=${__dplg_v_args[5]#of:}
  __dplg_v_use=${__dplg_v_args[6]#use:}
}
