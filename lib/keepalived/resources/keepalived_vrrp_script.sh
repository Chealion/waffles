# == Name
#
# keepalived.vrrp_script
#
# === Description
#
# Manages vrrp_script section in keepalived.conf
#
# === Parameters
#
# * state: The state of the resource. Required. Default: present.
# * name: The name of the VRRP instance. Required. namevar.
# * script: The script to define. Required.
# * interval: The interval to run the script. Optional.
# * weight: The points for priority. Optional.
# * fall: Number of failures for KO. Optional.
# * raise: Number of successes for OK. Optional.
# * file: The file to store the settings in. Required. Defaults to /etc/keepalived/keepalived.conf.
#
# === Example
#
# ```shell
# keepalived.vrrp_script --name check_apache2 \
#                        --script "killall -0 apache2"
# ```
#
function keepalived.vrrp_script {
  stdlib.subtitle "keepalived.vrrp_script"

  if ! stdlib.command_exists augtool ; then
    stdlib.error "Cannot find augtool."
    if [[ -n "$WAFFLES_EXIT_ON_ERROR" ]]; then
      exit 1
    else
      return 1
    fi
  fi

  local -A options
  local -a group
  stdlib.options.create_option state    "present"
  stdlib.options.create_option name     "__required__"
  stdlib.options.create_option script   "__required__"
  stdlib.options.create_option file     "/etc/keepalived/keepalived.conf"
  stdlib.options.create_option interval
  stdlib.options.create_option weight
  stdlib.options.create_option fall
  stdlib.options.create_option raise
  stdlib.options.parse_options "$@"

  local _name="${options[name]}"
  stdlib.catalog.add "keepalived.vrrp_script/${options[name]}"

  local _dir=$(dirname "${options[file]}")
  local _file="${options[file]}"
  local -A options_to_update

  # a list of "simple" key/value options
  local -a simple_options=("script" "interval" "weight" "raise" "fall")

  keepalived.vrrp_script.read
  if [[ "${options[state]}" == "absent" ]]; then
    if [[ "$stdlib_current_state" != "absent" ]]; then
      stdlib.info "$_name state: $stdlib_current_state, should be absent."
      keepalived.vrrp_script.delete
    fi
  else
    case "$stdlib_current_state" in
      absent)
        stdlib.info "$_name state: absent, should be present."
        keepalived.vrrp_script.create
        ;;
      present)
        stdlib.debug "$_name state: present."
        ;;
      update)
        stdlib.info "$_name state: present, needs updated."
        keepalived.vrrp_script.delete
        keepalived.vrrp_script.create
        ;;
    esac
  fi
}

function keepalived.vrrp_script.read {
  if [[ ! -f "$_file" ]]; then
    stdlib_current_state="absent"
    return
  fi

  # Check if the vrrp_script exists
  stdlib_current_state=$(augeas.get --lens Keepalived --file "$_file" --path "/vrrp_script[. = '${options[name]}']")
  if [[ "$stdlib_current_state" == "absent" ]]; then
    return
  fi

  # simple keys
  for o in "${simple_options[@]}"; do
    if [[ -n "${options[$o]}" ]]; then
      _result=$(augeas.get --lens Keepalived --file "$_file" --path "/vrrp_script[. = '${options[name]}']/$o[. = '${options[$o]}']")
      if [[ "$_result" == "absent" ]]; then
        options_to_update[$o]=1
        stdlib_current_state="update"
      fi
    fi
  done

  # Set simple options
  for o in "${simple_options[@]}"; do
    if [[ "${options_to_update[$o]+isset}" || "$stdlib_current_state" == "absent" ]]; then
      if [[ -n "${options[$o]}" ]]; then
        _augeas_commands+=("set /files/${_file}/vrrp_script[. = '${options[name]}']/$o '${options[$o]}'")
      fi
    fi
  done

  if [[ "$stdlib_current_state" == "update" ]]; then
    return
  else
    stdlib_current_state="present"
  fi
}

function keepalived.vrrp_script.create {
  local _result
  local -a _augeas_commands=()

  if [[ ! -d "$_dir" ]]; then
    stdlib.capture_error mkdir -p "$_dir"
  fi

  # Create the vrrp_script
  if [[ "$stdlib_current_state" == "absent" ]]; then
    _augeas_commands+=("set /files/${_file}/vrrp_script[0] '${options[name]}'")
  fi

  # Create simple options
  for o in "${simple_options[@]}"; do
    if [[ "${options_to_update[$o]+isset}" || "$stdlib_current_state" == "absent" ]]; then
      if [[ -n "${options[$o]}" ]]; then
        _augeas_commands+=("set /files/${_file}/vrrp_script[. = '${options[name]}']/$o '${options[$o]}'")
      fi
    fi
  done

  _result=$(augeas.run --lens Keepalived --file "$_file" "${_augeas_commands[@]}")
  if [[ "$_result" =~ ^error ]]; then
    stdlib.error "Error adding $_name with augeas: $_result"
  fi

  stdlib_state_change="true"
  stdlib_resource_change="true"
  let "stdlib_resource_changes++"
}

function keepalived.vrrp_script.delete {
  local _result
  local -a _augeas_commands=()

  _result=$(augeas.run --lens Keepalived --file "$_file" "${_augeas_commands[@]}")
  if [[ "$_result" =~ ^error ]]; then
    stdlib.error "Error adding $_name with augeas: $_result"
  fi

  stdlib_state_change="true"
  stdlib_resource_change="true"
  let "stdlib_resource_changes++"
}
