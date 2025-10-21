-- client.lua (ESX)
ESX = nil
local shells = {}
local properties = {}

-- load ESX shared
Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)

-- load Shells table (shared file returns table)
local resPath = GetResourcePath(GetCurrentResourceName())
local s, ok = pcall(function()
  local fpath = resPath..'/shells.lua'
  -- using LoadResourceFile is safer for client but shells.lua returns a table when required on server;
  -- for client we'll request shells from server on open.
end)

-- Open NUI editor (server triggers for admin)
RegisterNetEvent('noleg_esx:openEditor')
AddEventHandler('noleg_esx:openEditor', function()
  SetNui(true, true)
  SendNUIMessage({ action = 'open' })
  -- request shells and properties from server
  ESX.TriggerServerCallback('noleg_esx:getProperties', function(props)
    properties = props or {}
    SendNUIMessage({ action = 'loadProperties', properties = properties })
  end)
  -- ask server for shells via a callback-like event (we can use a server event)
  TriggerServerEvent('noleg_esx:requestShells')
end)

-- receive shells from server
RegisterNetEvent('noleg_esx:sendShells')
AddEventHandler('noleg_esx:sendShells', function(shelltbl)
  SendNUIMessage({ action = 'loadShells', shells = shelltbl })
end)

-- NUI callbacks
RegisterNUICallback('submitProperty', function(data, cb)
  TriggerServerEvent('noleg_esx:createProperty', data)
  cb({ ok = true })
end)

RegisterNUICallback('close', function(_, cb)
  SetNui(false, false)
  cb({ ok = true })
end)

-- Helper to set NUI focus
function SetNui(enable, keep)
  SetNuiFocus(enable, enable)
  SendNUIMessage({ action = enable and 'focus' or 'blur' })
end

-- pick coords when NUI open (press E)
Citizen.CreateThread(function()
  local nuiOpen = false
  while true do
    Citizen.Wait(0)
    if IsControlJustReleased(0, 38) then -- E
      if GetNuiFocus() then
        local ped = PlayerPedId()
        local v = GetEntityCoords(ped)
        SendNUIMessage({ action = 'pickedCoords', coords = { x = v.x, y = v.y, z = v.z } })
      end
    end
  end
end)

-- Teleport into property interior when enter used
RegisterNetEvent('noleg_esx:enterProperty')
AddEventHandler('noleg_esx:enterProperty', function(prop)
  local shell = prop.shell
  if not shell or shell == '' then
    ESX.ShowNotification('This property has no shell assigned.')
    return
  end
  -- use exported Shells table from server via event
  TriggerServerEvent('noleg_esx:requestShellData', prop.id)
end)

-- receive shell spawn data from server and teleport
RegisterNetEvent('noleg_esx:spawnShellForClient')
AddEventHandler('noleg_esx:spawnShellForClient', function(data)
  if not data or not data.spawn then return end
  local coords = data.spawn
  DoScreenFadeOut(300)
  Citizen.Wait(350)
  SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z - 1.0, 0, 0, 0, false)
  SetEntityHeading(PlayerPedId(), coords.h or 0.0)
  Citizen.Wait(250)
  DoScreenFadeIn(300)
  -- request IPL if needed
  if data.ipl and data.ipl ~= '' then
    -- some IPLs need RequestIpl or EnableInteriorProp - try RequestIpl
    RequestIpl(data.ipl)
  end
end)

-- Commands
RegisterCommand('propertyeditor', function()
  TriggerServerEvent('noleg_esx:openEditorForSource') -- server will validate admin and open
end, false)

-- Receive updates
RegisterNetEvent('noleg_esx:updateProperty')
AddEventHandler('noleg_esx:updateProperty', function(_, prop)
  -- update local cache (simple approach: request full list)
  ESX.TriggerServerCallback('noleg_esx:getProperties', function(props)
    properties = props or {}
    SendNUIMessage({ action = 'loadProperties', properties = properties })
  end)
end)
