-- server.lua (ESX-integrated NoLeg-like property system)
ESX = nil
Properties = {} -- in-memory cache of properties

local function log(...)
  print('[noleg_esx_property]', ...)
end

-- Load ESX
TriggerEvent(Config.ESXGetSharedObject, function(obj) ESX = obj end)

-- Load properties from MySQL or fallback on start
local function loadProperties()
  if Config.UseMySQL then
    MySQL.Async.fetchAll('SELECT * FROM ' .. Config.MySQLTable, {}, function(result)
      Properties = {}
      for _, row in ipairs(result) do
        -- decode JSON fields safely
        row.interact_points = row.interact_points and json.decode(row.interact_points) or nil
        row.yard_zone = row.yard_zone and json.decode(row.yard_zone) or nil
        row.entrance = row.entrance and json.decode(row.entrance) or nil
        row.exit = row.exit and json.decode(row.exit) or nil
        row.camdata = row.camdata and json.decode(row.camdata) or nil
        table.insert(Properties, row)
      end
      log('Loaded ' .. tostring(#Properties) .. ' properties from DB.')
    end)
  else
    -- fallback: nothing implemented here (you can extend to file save)
    log('MySQL disabled — no properties loaded.')
  end
end

AddEventHandler('onResourceStart', function(res)
  if res == GetCurrentResourceName() then
    loadProperties()
  end
end)

-- Helper: save new property
local function saveProperty(prop, cb)
  if Config.UseMySQL then
    MySQL.Async.insert('INSERT INTO '..Config.MySQLTable..' (name,address,price,shell,ipl,interact_points,yard_zone,entrance,exit,camdata,meta,owner) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      {
        prop.name or '',
        prop.address or '',
        tonumber(prop.price) or 0,
        prop.shell or nil,
        prop.ipl or nil,
        prop.interact_points and json.encode(prop.interact_points) or nil,
        prop.yard_zone and json.encode(prop.yard_zone) or nil,
        prop.entrance and json.encode(prop.entrance) or nil,
        prop.exit and json.encode(prop.exit) or nil,
        prop.camdata and json.encode(prop.camdata) or nil,
        prop.meta and json.encode(prop.meta) or nil,
        prop.owner or nil
      }, function(id)
        prop.id = id
        table.insert(Properties, prop)
        if cb then cb(true, id) end
      end)
  else
    if cb then cb(false, 'mysql_disabled') end
  end
end

-- Exports for compatibility
exports('AddProperty', function(prop)
  local ok, err = pcall(function()
    saveProperty(prop)
  end)
  if ok then return true else return false, err end
end)

-- Server event: create property (from NUI)
RegisterNetEvent('noleg_esx:createProperty')
AddEventHandler('noleg_esx:createProperty', function(prop)
  local src = source
  if Config.AdminOnly and not Config.IsAdmin(src) then
    TriggerClientEvent('chat:addMessage', src, { args = { '[Property]', 'Permission denied.' } })
    return
  end
  prop.meta = prop.meta or {}
  prop.meta.created_by = src
  prop.meta.created_at = os.time()
  if not prop.shell then prop.shell = nil end
  saveProperty(prop, function(ok, id)
    if ok then
      TriggerClientEvent('noleg_esx:propertySaved', src, prop)
      -- trigger event other resources can listen to (NoLeg compatibility)
      TriggerEvent('nolag:properties:addProperty', prop)
    else
      TriggerClientEvent('chat:addMessage', src, { args = { '[Property]', 'Failed saving property.' } })
    end
  end)
end)

-- Buying a property (player)
RegisterServerEvent('noleg_esx:buyProperty')
AddEventHandler('noleg_esx:buyProperty', function(propertyId)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  if not xPlayer then return end
  local prop = nil
  for _, p in ipairs(Properties) do
    if tonumber(p.id) == tonumber(propertyId) then prop = p; break end
  end
  if not prop then
    TriggerClientEvent('esx:showNotification', src, 'Property not found.')
    return
  end
  if prop.owner and prop.owner ~= '' then
    TriggerClientEvent('esx:showNotification', src, 'Property already owned.')
    return
  end
  local price = tonumber(prop.price) or 0
  if xPlayer.getMoney() >= price then
    xPlayer.removeMoney(price)
    MySQL.Async.execute('UPDATE '..Config.MySQLTable..' SET owner = ? WHERE id = ?', { xPlayer.identifier, prop.id }, function(rows)
      prop.owner = xPlayer.identifier
      TriggerClientEvent('esx:showNotification', src, 'You bought '..(prop.name or 'property')..' for $'..price)
      TriggerClientEvent('noleg_esx:updateProperty', -1, prop) -- broadcast update
    end)
  else
    TriggerClientEvent('esx:showNotification', src, 'Not enough money.')
  end
end)

-- Selling a property (owner)
RegisterServerEvent('noleg_esx:sellProperty')
AddEventHandler('noleg_esx:sellProperty', function(propertyId)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  if not xPlayer then return end
  local prop = nil
  for _, p in ipairs(Properties) do
    if tonumber(p.id) == tonumber(propertyId) then prop = p; break end
  end
  if not prop then
    TriggerClientEvent('esx:showNotification', src, 'Property not found.')
    return
  end
  if prop.owner ~= xPlayer.identifier then
    TriggerClientEvent('esx:showNotification', src, 'You do not own this property.')
    return
  end
  local refund = math.floor((tonumber(prop.price) or 0) * Config.SellBackPercent)
  xPlayer.addMoney(refund)
  MySQL.Async.execute('UPDATE '..Config.MySQLTable..' SET owner = NULL WHERE id = ?', { prop.id }, function(rows)
    prop.owner = nil
    TriggerClientEvent('esx:showNotification', src, 'You sold '..(prop.name or 'property')..' for $'..refund)
    TriggerClientEvent('noleg_esx:updateProperty', -1, prop)
  end)
end)

-- Fetch all properties (for client)
ESX.RegisterServerCallback('noleg_esx:getProperties', function(source, cb)
  cb(Properties)
end)
