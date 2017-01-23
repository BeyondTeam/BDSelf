--Tools.lua :D
local function get_variables_hash(msg)
  if gp_type(msg.chat_id_) == 'chat' or gp_type(msg.chat_id_) == 'channel' then
    return 'chat:bot:variables'
  end
end 

local function get_value(msg, var_name)
  local hash = get_variables_hash(msg)
  if hash then
    local value = redis:hget(hash, var_name)
    if not value then
      return
    else
      return value
    end
  end
end

local function list_chats(msg)
  local hash = get_variables_hash(msg)

  if hash then
    local names = redis:hkeys(hash)
    local text = 'bot replyes :\n\n'
    for i=1, #names do
      text = text..'> '..names[i]..'\n'
    end
    return text
	else
	return 
  end
end


local function save_value(msg, name, value)
  if (not name or not value) then
    return "Usage: !set var_name value"
  end
  local hash = nil
  if gp_type(msg.chat_id_) == 'chat' or gp_type(msg.chat_id_) == 'channel' then

    hash = 'chat:bot:variables'
  end
  if hash then
    redis:hset(hash, name, value)
    return "_Saved_ *"..name.."*"
  end
end
local function del_value(msg, name)
  if not name then
    return
  end
  local hash = nil
  if gp_type(msg.chat_id_) == 'chat' or gp_type(msg.chat_id_) == 'channel' then
    hash = 'chat:bot:variables'
  end
  if hash then
    redis:hdel(hash, name)
    return "_Removed_ *"..name.."*"
  end
end

local function delallchats(msg)
  local hash = 'chat:bot:variables'

  if hash then
    local names = redis:hkeys(hash)
    for i=1, #names do
      redis:hdel(hash,names[i])
    end
    return "*Done!*"
	else
	return 
  end
end


local function run(msg, matches)

if matches[1] == 'addplugin' and is_sudo(msg) then 
if not is_sudo(msg) then 
return '_You Are Not Allowed To Add Plugin_'
end 
text = matches[2] 
name = matches[3] 
file = io.open('./plugins/'..name, 'w') 
file:write(text) 
file:flush() 
file:close() 
return '_Plugin_ *['..matches[3]..']* _Has Been Added_'
end

if matches[1] == "delplugin" and is_sudo(msg) then	 
if not is_sudo(msg) then 
return "_You Are Not Allow To Delete Plugins!_" 
end 
io.popen("cd plugins && rm "..matches[2]..".lua") 
return "*Done!*" 
end

if matches[1] == 'markread' and is_sudo(msg) then
if matches[2] == 'on' then
redis:set('markread','on')
return '_Markread >_ *ON*'
end
if matches[2] == 'off' then
redis:set('markread','off')
return '_Markread >_ *OFF*'
end
end

if matches[1] == 'setmyusername' and is_sudo(msg) then
tdcli.changeUsername(matches[2])
return '_Username Changed To:_ @'..matches[2]
end

if matches[1] == 'delmyusername' and is_sudo(msg) then
tdcli.changeUsername('')
return '*Done!*'
  end

if matches[1] == 'setmyname' and is_sudo(msg) then
tdcli.changeName(matches[2])
return '_Name Changed To:_ *'..matches[2]..'*'
end

if matches[1] == 'delmyname' and is_sudo(msg) then
tdcli.changeName(' ')
return '_Name Has Been Deleted_'
end

if matches[1] == 'addcontact' and is_sudo(msg) then
    local phone_number = matches[2]
    local first_name = matches[3]
    local last_name = matches[4]
    tdcli.importContacts(phone_number, first_name, last_name, 0)
    return '_User_ *[+'.. matches[2] ..']* _Has Been Added_'
  end

if matches[1] == 'delcontact' and is_sudo(msg) then
    tdcli.deleteContacts({
      [0] = tonumber(matches[2])
    })
    return '_User_ *['.. matches[2] ..']* _Removed From Contact List_'
  end

if matches[1] == 'block' and is_sudo(msg) then
local id = matches[2]
tdcli.blockUser(id)
return '_User_ *['..matches[2]..']* _Has Been Blocked_'
end

if matches[1] == 'unblock' and is_sudo(msg) then
local id = matches[2]
tdcli.unblockUser(id)
return '_User_ *['..matches[2]..']* _Has Been Blocked_'
end

if matches[1] == 'chatlist' and is_sudo(msg) then
    local output = list_chats(msg)
    return output
  end
if matches[1] then
 return get_value(msg, matches[1])
end
if matches[1] == 'chat' and is_sudo(msg) then
    local name = matches[3]
  local value = matches[4]
  if matches[2] == 'clean' then
    local output = delallchats(msg)
    return output
  elseif matches[2] == '+' then
  local text = save_value(msg, name, value)
  return text
    elseif matches[2] == '-' then
    local text = del_value(msg,name)
    return text
    end
  end
 end
return { 
patterns = { 
"^[!/#](addplugin) (.*) (.+)$",
"^[!/#](delplugin) (.*)$",
"^[!/#](chatlist)$",
"^[#!/](chat) (+) ([^%s]+) (.+)$",
"^[#!/](chat) (clean)$",
"^[#!/](chat) (-) (.*)$",
"^[!/#](markread) (.*)$",
"^[!/#](setmyusername) (.*)$", 
"^[!/#](delmyusername)$",
"^[!/#](setmyname) (.*)$",
"^[!/#](delmyname) (.*)$",
"^[!/#](addcontact) (%d+) (.*) (.*)$",
"^[!/#](delcontact) (%d+)$",
"^[!/#](block) (.*)$",
"^[!/#](unblock) (.*)$",
"^(.+)$",
}, 
run = run 
}
