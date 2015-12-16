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
  __dplg_v_status=${__dplg_v_args[8]#status:}
}

__dplg_f_progress() {
  local -a progress=("|" "/" "-" "\\" "|")
  local inc=0
  while read line; do
    echo -n -e "\r${progress[$((inc++ % 5))]}" >&2
    echo -n -e "\r" >&2
    echo "$line"
  done
  echo -n -e "\r" >&2
}
