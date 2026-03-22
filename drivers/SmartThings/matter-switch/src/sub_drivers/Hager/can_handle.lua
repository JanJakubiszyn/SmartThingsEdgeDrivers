-- Copyright © 2025 SmartThings, Inc.
-- Licensed under the Apache License, Version 2.0

return function(opts, driver, device, ...)
  local device_lib = require "st.device"
  local fields = require "switch_utils.fields"
  
  local vendor_id = device.manufacturer_info and device.manufacturer_info.vendor_id
  local is_hager = (vendor_id == fields.HAGER_VENDOR_ID)
  
  if device.network_type == device_lib.NETWORK_TYPE_CHILD then
    local parent = device:get_parent_device()
    if parent
      and parent.network_type == device_lib.NETWORK_TYPE_MATTER
      and is_hager
    then
      return true, require("sub_drivers.Hager")
    end
  end
  
  if device.network_type == device_lib.NETWORK_TYPE_MATTER and is_hager then
    return true, require("sub_drivers.Hager")
  end
  
  return false
end