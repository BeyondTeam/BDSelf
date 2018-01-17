do

-- Returns the key (index) in the config.enabled_plugins table
local function plugin_enabled( name )
  for k,v in pairs(_config.enabled_plugins) do
    if name == v then
      return k
    end
  end
  -- If not found
  return false
end

-- Returns true if file exists in plugins folder
local function plugin_exists( name )
  for k,v in pairs(plugins_names()) do
    if name..'.lua' == v then
      return true
    end
  end
  return false
end

local function list_all_plugins(msg, only_enabled)
  local tmp = '\n\n@BeyondTeam'
  local text = ''
  local nsum = 0
  for k, v in pairs( plugins_names( )) do
    --  ✔ enabled, ❌ disabled
    local status = '*|✖️|>*'
    nsum = nsum+1
    nact = 0
    -- Check if is enabled
    for k2, v2 in pairs(_config.enabled_plugins) do
      if v == v2..'.lua' then 
        status = '*|✔|>*'
      end
      nact = nact+1
    end
    if not only_enabled or status == '*|✔|>*'then
      -- get the name
      v = string.match (v, "(.*)%.lua")
      text = text..nsum..'.'..status..' '..check_markdown(v)..' \n'
    end
  end
  local text = text..'\n\n'..nsum..' *📂plugins installed*\n\n'..nact..' _✔️plugins enabled_\n\n'..nsum-nact..' _❌plugins disabled_'..tmp
  return edit_msg(msg.to.id, msg.id, text, "md")
end

local function list_plugins(msg, only_enabled)
  local text = ''
  local nsum = 0
  for k, v in pairs( plugins_names( )) do
    --  ✔ enabled, ❌ disabled
    local status = '*|✖️|>*'
    nsum = nsum+1
    nact = 0
    -- Check if is enabled
    for k2, v2 in pairs(_config.enabled_plugins) do
      if v == v2..'.lua' then 
        status = '*|✔|>*'
      end
      nact = nact+1
    end
    if not only_enabled or status == '*|✔|>*'then
      -- get the name
      v = string.match (v, "(.*)%.lua")
     -- text = text..v..'  '..status..'\n'
    end
  end
  local text = text.."\n_🔃All Plugins Reloaded_\n\n"..nact.." *✔️Plugins Enabled*\n"..nsum.." *📂Plugins Installed*\n\n@BeyondTeam"
return edit_msg(msg.to.id, msg.id, text, "md")
end

local function reload_plugins(msg)
  plugins = {}
  load_plugins()
  return list_plugins(msg, true)
end


local function enable_plugin(msg, plugin_name)
  print('checking if '..plugin_name..' exists')
  -- Check if plugin is enabled
  if plugin_enabled(plugin_name) then
    return edit_msg(msg.to.id, msg.id, ''..plugin_name..' _is enabled_', "md")
  end
  -- Checks if plugin exists
  if plugin_exists(plugin_name) then
    -- Add to the config table
    table.insert(_config.enabled_plugins, plugin_name)
    print(plugin_name..' added to _config table')
    save_config()
    -- Reload the plugins
    return reload_plugins(msg)
  else
    return edit_msg(msg.to.id, msg.id, ''..plugin_name..' _does not exists_', "md")
  end
end

local function disable_plugin(msg, name, chat )
  -- Check if plugins exists
  if not plugin_exists(name) then
    return edit_msg(msg.to.id, msg.id, ' '..name..' _does not exists_', "md")
  end
  local k = plugin_enabled(name)
  -- Check if plugin is enabled
  if not k then
    return edit_msg(msg.to.id, msg.id, ' '..name..' _not enabled_', "md")
  end
  -- Disable and reload
  table.remove(_config.enabled_plugins, k)
  save_config( )
  return reload_plugins(msg)    
end

local function disable_plugin_on_chat(msg, receiver, plugin)
  if not plugin_exists(plugin) then
    return edit_msg(msg.to.id, msg.id, "_Plugin doesn't exists_", "md")
  end

  if not _config.disabled_plugin_on_chat then
    _config.disabled_plugin_on_chat = {}
  end

  if not _config.disabled_plugin_on_chat[receiver] then
    _config.disabled_plugin_on_chat[receiver] = {}
  end

  _config.disabled_plugin_on_chat[receiver][plugin] = true

  save_config()
  return edit_msg(msg.to.id, msg.id, ' '..plugin..' _disabled on this chat_', "md")
end

local function reenable_plugin_on_chat(msg, receiver, plugin)
  if not _config.disabled_plugin_on_chat then
    return edit_msg(msg.to.id, msg.id, 'There aren\'t any disabled plugins', "md")
  end

  if not _config.disabled_plugin_on_chat[receiver] then
    return edit_msg(msg.to.id, msg.id, 'There aren\'t any disabled plugins for this chat', "md")
  end

  if not _config.disabled_plugin_on_chat[receiver][plugin] then
    return edit_msg(msg.to.id, msg.id, '_This plugin is not disabled_', "md")
  end

  _config.disabled_plugin_on_chat[receiver][plugin] = false
  save_config()
  return edit_msg(msg.to.id, msg.id, ' '..plugin..' is enabled again', "md")
end

local function run(msg, matches)
  -- Show the available plugins 
  if is_sudo(msg) then
  if matches[1]:lower() == '!plist' or matches[1]:lower() == '/plist' or matches[1]:lower() == '#plist' then --after changed to moderator mode, set only sudo
    return list_all_plugins(msg, true)
  end
end
  -- Re-enable a plugin for this chat
   if matches[1] == 'pl' then
  if matches[2] == '+' and matches[4] == 'chat' then
      if is_momod(msg) then
    local receiver = msg.chat_id_
    local plugin = matches[3]
    print("enable "..plugin..' on this chat')
    return reenable_plugin_on_chat(msg, receiver, plugin)
  end
    end

  -- Enable a plugin
  if matches[2] == '+' and is_sudo(msg) then --after changed to moderator mode, set only sudo
      if is_mod(msg) then
    local plugin_name = matches[3]
    print("enable: "..matches[3])
    return enable_plugin(msg, plugin_name)
  end
    end
  -- Disable a plugin on a chat
  if matches[2] == '-' and matches[4] == 'chat' then
      if is_mod(msg) then
    local plugin = matches[3]
    local receiver = msg.chat_id_
    print("disable "..plugin..' on this chat')
    return disable_plugin_on_chat(msg, receiver, plugin)
  end
    end
  -- Disable a plugin
  if matches[2] == '-' and is_sudo(msg) then --after changed to moderator mode, set only sudo
    if matches[3] == 'plugins' then
    	return edit_msg(msg.to.id, msg.id, 'This plugin can\'t be disabled', "md")
    end
    print("disable: "..matches[3])
    return disable_plugin(msg, matches[3])
  end
end
  -- Reload all the plugins!
  if matches[1] == '*' and is_sudo(msg) then --after changed to moderator mode, set only sudo
    return reload_plugins(true)
  end
  if matches[1]:lower() == 'reload' and is_sudo(msg) then --after changed to moderator mode, set only sudo
    return reload_plugins(msg)
  end
end

return {
  description = "Plugin to manage other plugins. Enable, disable or reload.", 
  usage = {
      moderator = {
          "!plug disable [plugin] chat : disable plugin only this chat.",
          "!plug enable [plugin] chat : enable plugin only this chat.",
          },
      sudo = {
          "!plist : list all plugins.",
          "!pl + [plugin] : enable plugin.",
          "!pl - [plugin] : disable plugin.",
          "!pl * : reloads all plugins." },
          },
  patterns = {
    "^[!/#]plist$",
    "^[!/#](pl) (+) ([%w_%.%-]+)$",
    "^[!/#](pl) (-) ([%w_%.%-]+)$",
    "^[!/#](pl) (+) ([%w_%.%-]+) (chat)",
    "^[!/#](pl) (-) ([%w_%.%-]+) (chat)",
    "^!pl? (*)$",
    "^[!/](reload)$"
    },
  run = run
}

end

