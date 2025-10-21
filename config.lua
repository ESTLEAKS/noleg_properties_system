Config = {}

-- ESX
Config.UseESX = true
Config.ESXGetSharedObject = 'esx:getSharedObject' -- event name (default ESX)

-- Database
Config.UseMySQL = true
Config.MySQLTable = 'noleg_properties'

-- Admin editor
Config.AdminOnly = true
Config.AdminAce = 'noleg.propertyeditor'
Config.AdminGroup = 'admin' -- if you use group checks instead of ACE

-- Purchase settings
Config.EnableBuying = true
Config.SellBackPercent = 0.8 -- players get 80% back when selling

-- Interactions
Config.EnterDistance = 2.0

-- NUI settings
Config.NUIKey = 'propertyeditor' -- not used for hotkey, just identifier

-- Helper for permission check (server-side)
Config.IsAdmin = function(source)
  if source == 0 then return true end
  return IsPlayerAceAllowed(source, Config.AdminAce)
end
