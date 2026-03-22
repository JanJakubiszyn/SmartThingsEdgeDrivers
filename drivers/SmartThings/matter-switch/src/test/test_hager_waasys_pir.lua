-- Copyright © 2025 SmartThings, Inc.
-- Licensed under the Apache License, Version 2.0

local test = require "integration_test"
local capabilities = require "st.capabilities"
local t_utils = require "integration_test.utils"
local data_types = require "st.matter.data_types"

local clusters = require "st.matter.clusters"
local cluster_base = require "st.matter.cluster_base"
local descriptor = require "st.matter.generated.zap_clusters.Descriptor"

local HOST_ID = "HOST_ID"
local SUBHUB_ID = "SUBHUB_ID"

-- ========================================================================
-- DEVICE DEFINITIONS
-- ========================================================================

-- Device 1: Motion Sensor + Illuminance (Power Module A)
local pir_sensor_only = test.mock_device.build_test_matter_device({
    label = "Hager PIR Sensor Only",
    profile = t_utils.get_profile_definition("matter-bridge.yml"),
    manufacturer_info = {
        vendor_id = 0x1285,
        product_id = 0x0005,
    },
    parent_device_id = "00000000-1111-2222-3333-000000000001",
    endpoints = {
        {
            endpoint_id = 0,
            clusters = {
                { cluster_id = clusters.Basic.ID, cluster_type = "SERVER" },
            },
            device_types = {
                { device_type_id = 0x0016, device_type_revision = 1 }
            }
        },
        {
            endpoint_id = 1,
            clusters = {
                {
                    cluster_id = clusters.OccupancySensing.ID,
                    cluster_type = "SERVER",
                    cluster_revision = 1,
                }
            },
            device_types = {
                { device_type_id = 0x0107, device_type_revision = 1 }
            }
        },
        {
            endpoint_id = 2,
            clusters = {
                {
                    cluster_id = clusters.IlluminanceMeasurement.ID,
                    cluster_type = "SERVER",
                    cluster_revision = 1,
                }
            },
            device_types = {
                { device_type_id = 0x0106, device_type_revision = 1 }
            }
        },
    }
})

-- Device 2: Motion Sensor + Illuminance + Simple Switch (Power Module B)
local pir_with_switch = test.mock_device.build_test_matter_device({
    label = "Hager PIR With Switch",
    profile = t_utils.get_profile_definition("matter-bridge.yml"),
    manufacturer_info = {
        vendor_id = 0x1285,
        product_id = 0x0005,
    },
    parent_device_id = "00000000-1111-2222-3333-000000000001",
    endpoints = {
        {
            endpoint_id = 0,
            clusters = {
                { cluster_id = clusters.Basic.ID, cluster_type = "SERVER" },
            },
            device_types = {
                { device_type_id = 0x0016, device_type_revision = 1 }
            }
        },
        {
            endpoint_id = 1,
            clusters = {
                {
                    cluster_id = clusters.OccupancySensing.ID,
                    cluster_type = "SERVER",
                    cluster_revision = 1,
                }
            },
            device_types = {
                { device_type_id = 0x0107, device_type_revision = 1 }
            }
        },
        {
            endpoint_id = 2,
            clusters = {
                {
                    cluster_id = clusters.IlluminanceMeasurement.ID,
                    cluster_type = "SERVER",
                    cluster_revision = 1,
                }
            },
            device_types = {
                { device_type_id = 0x0106, device_type_revision = 1 }
            }
        },
        {
            endpoint_id = 3,
            clusters = {
                {
                    cluster_id = clusters.OnOff.ID,
                    cluster_type = "SERVER",
                    cluster_revision = 1,
                    feature_map = 0,
                }
            },
            device_types = {
                { device_type_id = 0x0100, device_type_revision = 1 }
            }
        },
    }
})

-- Device 3: Motion Sensor + Illuminance + Dimmable Switch (Power Module C)
local pir_with_dimmable = test.mock_device.build_test_matter_device({
    label = "Hager PIR With Dimmable",
    profile = t_utils.get_profile_definition("matter-bridge.yml"),
    manufacturer_info = {
        vendor_id = 0x1285,
        product_id = 0x0005,
    },
    parent_device_id = "00000000-1111-2222-3333-000000000001",
    endpoints = {
        {
            endpoint_id = 0,
            clusters = {
                { cluster_id = clusters.Basic.ID, cluster_type = "SERVER" },
            },
            device_types = {
                { device_type_id = 0x0016, device_type_revision = 1 }
            }
        },
        {
            endpoint_id = 1,
            clusters = {
                {
                    cluster_id = clusters.OccupancySensing.ID,
                    cluster_type = "SERVER",
                    cluster_revision = 1,
                }
            },
            device_types = {
                { device_type_id = 0x0107, device_type_revision = 1 }
            }
        },
        {
            endpoint_id = 2,
            clusters = {
                {
                    cluster_id = clusters.IlluminanceMeasurement.ID,
                    cluster_type = "SERVER",
                    cluster_revision = 1,
                }
            },
            device_types = {
                { device_type_id = 0x0106, device_type_revision = 1 }
            }
        },
        {
            endpoint_id = 4,
            clusters = {
                {
                    cluster_id = clusters.OnOff.ID,
                    cluster_type = "SERVER",
                    cluster_revision = 1,
                },
                {
                    cluster_id = clusters.LevelControl.ID,
                    cluster_type = "SERVER",
                    cluster_revision = 1,
                    feature_map = 2,
                }
            },
            device_types = {
                { device_type_id = 0x0101, device_type_revision = 1 }
            }
        },
    }
})

-- ========================================================================
-- INITIALIZATION
-- ========================================================================

local function test_init_sensor_only()
    -- test_init is not needed for these tests since each test coroutine handles device initialization
end

test.set_test_init_function(test_init_sensor_only)

-- ========================================================================
-- CONFIGURATION TESTS
-- ========================================================================

-- Device 1: Motion + Illuminance (5 tests)

test.register_coroutine_test("Device 1: Occupancy report emits motion active event", function()
    test.mock_device.add_test_device(pir_sensor_only)
    
    test.socket.matter:__queue_receive({
        pir_sensor_only.id,
        clusters.OccupancySensing.attributes.Occupancy:build_test_report_data(pir_sensor_only, 1, 0x01)
    })
    
    pir_sensor_only:expect_test_message("main", capabilities.motionSensor.motion.active())
    test.wait_for_events()
end)

test.register_coroutine_test("Device 1: Occupancy report emits motion inactive event", function()
    test.mock_device.add_test_device(pir_sensor_only)
    
    test.socket.matter:__queue_receive({
        pir_sensor_only.id,
        clusters.OccupancySensing.attributes.Occupancy:build_test_report_data(pir_sensor_only, 1, 0x00)
    })
    
    pir_sensor_only:expect_test_message("main", capabilities.motionSensor.motion.inactive())
    test.wait_for_events()
end)

test.register_coroutine_test("Device 1: Illuminance report emits illuminance measurement event", function()
    test.mock_device.add_test_device(pir_sensor_only)
    
    test.socket.matter:__queue_receive({
        pir_sensor_only.id,
        clusters.IlluminanceMeasurement.attributes.MeasuredValue:build_test_report_data(pir_sensor_only, 2, 10000)
    })
    
    pir_sensor_only:expect_test_message("main", capabilities.illuminanceMeasurement.illuminance(100))
    test.wait_for_events()
end)

test.register_coroutine_test("Device 1: Profile changes to motion-illuminance when motion endpoint detected", function()
    test.mock_device.add_test_device(pir_sensor_only)
    test.socket.matter:__set_channel_ordering("relaxed")
    
    test.socket.device_lifecycle:__queue_receive({ pir_sensor_only.id, "added" })
    test.socket.device_lifecycle:__queue_receive({ pir_sensor_only.id, "init" })
    
    pir_sensor_only:set_field(SUBHUB_ID, pir_sensor_only.id, {persist = true})
    pir_sensor_only:set_field(HOST_ID, pir_sensor_only.id, {persist = true})
    
    test.socket.device_lifecycle:__queue_receive({ pir_sensor_only.id, "doConfigure" })
    
    test.socket.matter:__expect_send({
        pir_sensor_only.id,
        cluster_base.subscribe(pir_sensor_only, 2, descriptor.ID, descriptor.attributes.PartsList.ID, nil)
    })
    test.socket.matter:__expect_send({
        pir_sensor_only.id,
        cluster_base.subscribe(pir_sensor_only, 0, descriptor.ID, descriptor.attributes.PartsList.ID, nil)
    })
    
    test.wait_for_events()
    
    test.socket.matter:__queue_receive({
        pir_sensor_only.id,
        clusters.Descriptor.attributes.PartsList:build_test_report_data(pir_sensor_only, 0, data_types.Array({
            data_types.Uint16(1),
            data_types.Uint16(2),
        }))
    })
    
    test.wait_for_events()
    pir_sensor_only:expect_metadata_update({ profile = "motion-illuminance" })
    test.wait_for_events()
end)

test.register_coroutine_test("Device 1: Subscriptions for Occupancy and Illuminance are created", function()
    test.mock_device.add_test_device(pir_sensor_only)
    test.socket.matter:__set_channel_ordering("relaxed")
    
    test.socket.device_lifecycle:__queue_receive({ pir_sensor_only.id, "added" })
    test.socket.device_lifecycle:__queue_receive({ pir_sensor_only.id, "init" })
    
    pir_sensor_only:set_field(SUBHUB_ID, pir_sensor_only.id, {persist = true})
    pir_sensor_only:set_field(HOST_ID, pir_sensor_only.id, {persist = true})
    
    test.socket.device_lifecycle:__queue_receive({ pir_sensor_only.id, "doConfigure" })
    
    test.socket.matter:__expect_send({
        pir_sensor_only.id,
        cluster_base.subscribe(pir_sensor_only, 2, descriptor.ID, descriptor.attributes.PartsList.ID, nil)
    })
    test.socket.matter:__expect_send({
        pir_sensor_only.id,
        cluster_base.subscribe(pir_sensor_only, 0, descriptor.ID, descriptor.attributes.PartsList.ID, nil)
    })
    
    test.wait_for_events()
    
    test.socket.matter:__queue_receive({
        pir_sensor_only.id,
        clusters.Descriptor.attributes.PartsList:build_test_report_data(pir_sensor_only, 0, data_types.Array({
            data_types.Uint16(1),
            data_types.Uint16(2),
        }))
    })
    
    test.wait_for_events()
    
    test.socket.matter:__expect_send({
        pir_sensor_only.id,
        cluster_base.subscribe(pir_sensor_only, 1, clusters.OccupancySensing.ID, clusters.OccupancySensing.attributes.Occupancy.ID, nil)
    })
    
    test.socket.matter:__expect_send({
        pir_sensor_only.id,
        cluster_base.subscribe(pir_sensor_only, 2, clusters.IlluminanceMeasurement.ID, clusters.IlluminanceMeasurement.attributes.MeasuredValue.ID, nil)
    })
    
    test.wait_for_events()
end)

-- Device 2: Motion + Illuminance + Simple Switch (4 tests)

test.register_coroutine_test("Device 2: Profile changes to light-binary when EP3 detected", function()
    test.socket.matter:__set_channel_ordering("relaxed")
    test.mock_device.add_test_device(pir_with_switch)
    
    test.socket.device_lifecycle:__queue_receive({ pir_with_switch.id, "added" })
    test.socket.device_lifecycle:__queue_receive({ pir_with_switch.id, "init" })
    
    pir_with_switch:set_field(SUBHUB_ID, pir_with_switch.id, {persist = true})
    pir_with_switch:set_field(HOST_ID, pir_with_switch.id, {persist = true})
    
    test.socket.device_lifecycle:__queue_receive({ pir_with_switch.id, "doConfigure" })
    
    test.socket.matter:__expect_send({
        pir_with_switch.id,
        cluster_base.subscribe(pir_with_switch, 2, descriptor.ID, descriptor.attributes.PartsList.ID, nil)
    })
    test.socket.matter:__expect_send({
        pir_with_switch.id,
        cluster_base.subscribe(pir_with_switch, 0, descriptor.ID, descriptor.attributes.PartsList.ID, nil)
    })
    
    test.wait_for_events()
    
    test.socket.matter:__queue_receive({
        pir_with_switch.id,
        clusters.Descriptor.attributes.PartsList:build_test_report_data(pir_with_switch, 0, data_types.Array({
            data_types.Uint16(1),
            data_types.Uint16(2),
            data_types.Uint16(3),
        }))
    })
    
    test.wait_for_events()
    
    test.socket.matter:__expect_send({
        pir_with_switch.id,
        clusters.Descriptor.attributes.DeviceTypeList:read(pir_with_switch, 3)
    })
    
    pir_with_switch:expect_metadata_update({ profile = "light-binary" })
    test.wait_for_events()
end)

test.register_message_test("Device 2: Switch on command from HOST sends Matter OnOff to EP3", {
    {
        channel = "capability",
        direction = "receive",
        message = {
            pir_with_switch.id,
            { capability = "switch", component = "main", command = "on", args = {} }
        }
    },
    {
        channel = "matter",
        direction = "send",
        message = {
            pir_with_switch.id,
            clusters.OnOff.server.commands.On(pir_with_switch, 3)
        }
    }
})

test.register_message_test("Device 2: Switch off command from HOST sends Matter OnOff to EP3", {
    {
        channel = "capability",
        direction = "receive",
        message = {
            pir_with_switch.id,
            { capability = "switch", component = "main", command = "off", args = {} }
        }
    },
    {
        channel = "matter",
        direction = "send",
        message = {
            pir_with_switch.id,
            clusters.OnOff.server.commands.Off(pir_with_switch, 3)
        }
    }
})

test.register_message_test("Device 2: OnOff report on EP3 emits switch event on HOST", {
    {
        channel = "matter",
        direction = "receive",
        message = {
            pir_with_switch.id,
            clusters.OnOff.attributes.OnOff:build_test_report_data(pir_with_switch, 3, true)
        }
    },
    {
        channel = "capability",
        direction = "send",
        message = pir_with_switch:generate_test_message("main", capabilities.switch.switch.on())
    }
})

-- Device 3: Motion + Illuminance + Dimmable Switch (6 tests)

test.register_coroutine_test("Device 3: Profile changes to light-level when EP4 (dimmer) detected", function()
    test.socket.matter:__set_channel_ordering("relaxed")
    test.mock_device.add_test_device(pir_with_dimmable)
    
    test.socket.device_lifecycle:__queue_receive({ pir_with_dimmable.id, "added" })
    test.socket.device_lifecycle:__queue_receive({ pir_with_dimmable.id, "init" })
    
    pir_with_dimmable:set_field(SUBHUB_ID, pir_with_dimmable.id, {persist = true})
    pir_with_dimmable:set_field(HOST_ID, pir_with_dimmable.id, {persist = true})
    
    test.socket.device_lifecycle:__queue_receive({ pir_with_dimmable.id, "doConfigure" })
    
    test.socket.matter:__expect_send({
        pir_with_dimmable.id,
        cluster_base.subscribe(pir_with_dimmable, 2, descriptor.ID, descriptor.attributes.PartsList.ID, nil)
    })
    test.socket.matter:__expect_send({
        pir_with_dimmable.id,
        cluster_base.subscribe(pir_with_dimmable, 0, descriptor.ID, descriptor.attributes.PartsList.ID, nil)
    })
    
    test.wait_for_events()
    
    test.socket.matter:__queue_receive({
        pir_with_dimmable.id,
        clusters.Descriptor.attributes.PartsList:build_test_report_data(pir_with_dimmable, 0, data_types.Array({
            data_types.Uint16(1),
            data_types.Uint16(2),
            data_types.Uint16(4),
        }))
    })
    
    test.wait_for_events()
    
    test.socket.matter:__expect_send({
        pir_with_dimmable.id,
        clusters.Descriptor.attributes.DeviceTypeList:read(pir_with_dimmable, 4)
    })
    
    pir_with_dimmable:expect_metadata_update({ profile = "light-level" })
    test.wait_for_events()
end)

test.register_message_test("Device 3: Switch on command from HOST sends Matter OnOff to EP4", {
    {
        channel = "capability",
        direction = "receive",
        message = {
            pir_with_dimmable.id,
            { capability = "switch", component = "main", command = "on", args = {} }
        }
    },
    {
        channel = "matter",
        direction = "send",
        message = {
            pir_with_dimmable.id,
            clusters.OnOff.server.commands.On(pir_with_dimmable, 4)
        }
    }
})

test.register_message_test("Device 3: Switch off command from HOST sends Matter OnOff to EP4", {
    {
        channel = "capability",
        direction = "receive",
        message = {
            pir_with_dimmable.id,
            { capability = "switch", component = "main", command = "off", args = {} }
        }
    },
    {
        channel = "matter",
        direction = "send",
        message = {
            pir_with_dimmable.id,
            clusters.OnOff.server.commands.Off(pir_with_dimmable, 4)
        }
    }
})

test.register_message_test("Device 3: OnOff report on EP4 emits switch event on HOST", {
    {
        channel = "matter",
        direction = "receive",
        message = {
            pir_with_dimmable.id,
            clusters.OnOff.attributes.OnOff:build_test_report_data(pir_with_dimmable, 4, true)
        }
    },
    {
        channel = "capability",
        direction = "send",
        message = pir_with_dimmable:generate_test_message("main", capabilities.switch.switch.on())
    }
})

test.register_message_test("Device 3: setLevel command from HOST sends Matter MoveToLevelWithOnOff to EP4", {
    {
        channel = "capability",
        direction = "receive",
        message = {
            pir_with_dimmable.id,
            { capability = "switchLevel", component = "main", command = "setLevel", args = { level = 80 } }
        }
    },
    {
        channel = "matter",
        direction = "send",
        message = {
            pir_with_dimmable.id,
            clusters.LevelControl.server.commands.MoveToLevelWithOnOff(pir_with_dimmable, 4, 203, 0, 0, 0)
        }
    }
})

test.register_message_test("Device 3: CurrentLevel report on EP4 emits switchLevel event on HOST", {
    {
        channel = "matter",
        direction = "receive",
        message = {
            pir_with_dimmable.id,
            clusters.LevelControl.attributes.CurrentLevel:build_test_report_data(pir_with_dimmable, 4, 127)
        }
    },
    {
        channel = "capability",
        direction = "send",
        message = pir_with_dimmable:generate_test_message("main", capabilities.switchLevel.level(50))
    }
})

-- ========================================================================
-- DYNAMIC ENDPOINT CHANGE TESTS
-- ========================================================================

-- Dynamic Test 1: Add EP3 (switch) to motion/illuminance device
test.register_coroutine_test("Dynamic Test 1: Add EP3 (switch) to motion/illuminance device", function()
    test.socket.matter:__set_channel_ordering("relaxed")
    test.mock_device.add_test_device(pir_with_switch)
    
    test.socket.device_lifecycle:__queue_receive({ pir_with_switch.id, "added" })
    test.socket.device_lifecycle:__queue_receive({ pir_with_switch.id, "init" })
    
    pir_with_switch:set_field(SUBHUB_ID, pir_with_switch.id, {persist = true})
    pir_with_switch:set_field(HOST_ID, pir_with_switch.id, {persist = true})
    
    test.socket.device_lifecycle:__queue_receive({ pir_with_switch.id, "doConfigure" })
    
    test.socket.matter:__expect_send({
        pir_with_switch.id,
        cluster_base.subscribe(pir_with_switch, 2, descriptor.ID, descriptor.attributes.PartsList.ID, nil)
    })
    test.socket.matter:__expect_send({
        pir_with_switch.id,
        cluster_base.subscribe(pir_with_switch, 0, descriptor.ID, descriptor.attributes.PartsList.ID, nil)
    })
    
    test.wait_for_events()
    
    -- Initial PartsList: only EP1, EP2 (motion/illuminance)
    test.socket.matter:__queue_receive({
        pir_with_switch.id,
        clusters.Descriptor.attributes.PartsList:build_test_report_data(pir_with_switch, 0, data_types.Array({
            data_types.Uint16(1),
            data_types.Uint16(2),
        }))
    })
    
    test.wait_for_events()
    pir_with_switch:expect_metadata_update({ profile = "motion-illuminance" })
    test.wait_for_events()
    
    -- EP3 (switch) is added dynamically
    pir_with_switch:set_field("__active_EPS", {1, 2}, {persist = true})
    
    test.socket.matter:__queue_receive({
        pir_with_switch.id,
        clusters.Descriptor.attributes.PartsList:build_test_report_data(pir_with_switch, 0, data_types.Array({
            data_types.Uint16(1),
            data_types.Uint16(2),
            data_types.Uint16(3),
        }))
    })
    
    test.wait_for_events()
    
    test.socket.matter:__expect_send({
        pir_with_switch.id,
        clusters.Descriptor.attributes.DeviceTypeList:read(pir_with_switch, 3)
    })
    
    pir_with_switch:expect_metadata_update({ profile = "light-binary" })
    test.wait_for_events()
end)

-- Dynamic Test 2: Remove EP3 (switch) from motion/illuminance+switch device
test.register_coroutine_test("Dynamic Test 2: Remove EP3 (switch) from motion/illuminance+switch device", function()
    test.socket.matter:__set_channel_ordering("relaxed")
    test.mock_device.add_test_device(pir_with_switch)
    
    test.socket.device_lifecycle:__queue_receive({ pir_with_switch.id, "added" })
    test.socket.device_lifecycle:__queue_receive({ pir_with_switch.id, "init" })
    
    pir_with_switch:set_field(SUBHUB_ID, pir_with_switch.id, {persist = true})
    pir_with_switch:set_field(HOST_ID, pir_with_switch.id, {persist = true})
    
    test.socket.device_lifecycle:__queue_receive({ pir_with_switch.id, "doConfigure" })
    
    test.socket.matter:__expect_send({
        pir_with_switch.id,
        cluster_base.subscribe(pir_with_switch, 2, descriptor.ID, descriptor.attributes.PartsList.ID, nil)
    })
    test.socket.matter:__expect_send({
        pir_with_switch.id,
        cluster_base.subscribe(pir_with_switch, 0, descriptor.ID, descriptor.attributes.PartsList.ID, nil)
    })
    
    test.wait_for_events()
    
    -- Initial PartsList: EP1, EP2, EP3 (motion+illuminance+switch)
    test.socket.matter:__queue_receive({
        pir_with_switch.id,
        clusters.Descriptor.attributes.PartsList:build_test_report_data(pir_with_switch, 0, data_types.Array({
            data_types.Uint16(1),
            data_types.Uint16(2),
            data_types.Uint16(3),
        }))
    })
    
    test.wait_for_events()
    
    test.socket.matter:__expect_send({
        pir_with_switch.id,
        clusters.Descriptor.attributes.DeviceTypeList:read(pir_with_switch, 3)
    })
    
    pir_with_switch:expect_metadata_update({ profile = "light-binary" })
    test.wait_for_events()
    
    -- EP3 is removed dynamically
    pir_with_switch:set_field("__active_EPS", {1, 2, 3}, {persist = true})
    
    test.socket.matter:__queue_receive({
        pir_with_switch.id,
        clusters.Descriptor.attributes.PartsList:build_test_report_data(pir_with_switch, 0, data_types.Array({
            data_types.Uint16(1),
            data_types.Uint16(2),
        }))
    })
    
    test.wait_for_events()
    pir_with_switch:expect_metadata_update({ profile = "motion-illuminance" })
    test.wait_for_events()
end)

test.run_registered_tests()