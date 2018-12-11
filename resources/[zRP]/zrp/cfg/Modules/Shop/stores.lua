local cfg = {
    blipId = 52,
    blipColor = 2,
    coords = {
        { 1862.0400390625, 3675.5163574219, 33.645408630371, 1000 },
        { 1862.9279785156, 3666.4030761719, 33.952159881592, 1000 }
    }
}

cfg.store_config = {
    ["id"] = {
        name = "Default_Name",
        dbmanager = true,
        items = {},
        forsale = true,
        store_level = 10,
        group_store = false,
        -- owner_id = 1, -- Only For create a store with owner
        -- group = "TAXI"
        rent = false,
        buy = true,
        price = 100000,
        --seller = id,
        --time = 10
    }
}

cfg.stores = {
    { "id", 1862.0400390625, 3675.5163574219, 33.645408630371 }
}

return cfg