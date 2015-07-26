# == Name
#
# rabbitmq.msg_store_file_size_limit
#
# === Description
#
# Manages msg_store_file_size_limit settings in a rabbitmq.config file.
#
# === Parameters
#
# * state: The state of the resource. Required. Default: present.
# * value: The default value. Required. namevar.
# * file: The file to store the settings in. Optional. Defaults to /etc/rabbitmq/rabbitmq.config.
#
# === Example
#
# ```shell
# rabbitmq.msg_store_file_size_limit --value /
# ```
#
function rabbitmq.msg_store_file_size_limit {
  stdlib.subtitle "rabbitmq.msg_store_file_size_limit"

  if ! stdlib.command_exists augtool ; then
    stdlib.error "Cannot find augtool."
    if [[ -n $WAFFLES_EXIT_ON_ERROR ]]; then
      exit 1
    else
      return 1
    fi
  fi

  # Resource Options
  local -A options
  stdlib.options.create_option state "present"
  stdlib.options.create_option value "__required__"
  stdlib.options.create_option file  "/etc/rabbitmq/rabbitmq.config"
  stdlib.options.parse_options "$@"

  # Local Variables
  local _name="${options[value]}"
  local _dir=$(dirname "${options[file]}")
  local _file="${options[file]}"

  # Process the resource
  stdlib.resource.process "rabbitmq.msg_store_file_size_limit" "$_name"
}

function rabbitmq.msg_store_file_size_limit.read {
  if [[ ! -f $_file ]]; then
    stdlib_current_state="absent"
    return
  fi

  rabbitmq.generic_value_read $_file "msg_store_file_size_limit" "${options[value]}"
}

function rabbitmq.msg_store_file_size_limit.create {
  local _result

  if [[ ! -d $_dir ]]; then
    stdlib.capture_error mkdir -p $_dir
  fi

  rabbitmq.generic_value_create $_file "msg_store_file_size_limit" "${options[value]}"

  if [[ $_result =~ ^error ]]; then
    stdlib.error "Error adding $_name with augeas: $_result"
  fi
}

function rabbitmq.msg_store_file_size_limit.update {
  rabbitmq.msg_store_file_size_limit.delete
  rabbitmq.msg_store_file_size_limit.create
}

function rabbitmq.msg_store_file_size_limit.delete {
  local _result

  rabbitmq.generic_value_delete $_file "msg_store_file_size_limit" "${options[value]}"

  if [[ $_result =~ ^error ]]; then
    stdlib.error "Error deleting rabbitmq.msg_store_file_size_limit $_name with augeas: $_result"
  fi
}
