--Tools.lua :D

local function getindex(t,id) 
for i,v in pairs(t) do 
if v == id then 
return i 
end 
end 
return nil 
end 

local function already_sudo(user_id)
  for k,v in pairs(_config.sudo_users) do
    if user_id == v then
      return k
    end
  end
  -- If not found
  return false
end

local function reload_plugins( ) 
  plugins = {} 
  load_plugins() 
end

local function sudolist(msg)
local sudo_users = _config.sudo_users
 text = "*List of sudo users :*\n"
for i=1,#sudo_users do
  		local user_info = redis:hgetall('user:'..sudo_users[i])
		if user_info and user_info.user_name then
   local user_name = check_markdown(user_info.user_name)
    text = text..i.." - "..user_name.." `"..sudo_users[i].."`\n"
 else
    text = text..i.." - `"..sudo_users[i].."`\n"
   end
end
return edit_msg(msg.to.id, msg.id, text, "md")
end

local function run_bash(str)
    local cmd = io.popen(str)
    local result = cmd:read('*all')
    return result
end

local function exi_file()
    local files = {}
    local pth = tcpath..'/data/document'
    for k, v in pairs(scandir(pth)) do
        if (v:match('.lua$')) then
            table.insert(files, v)
        end
    end
    return files
end

local function pl_exi(name)
    for k,v in pairs(exi_file()) do
        if name == v then
            return true
        end
    end
    return false
end

local function exi_files(cpath)
    local files = {}
    local pth = cpath
    for k, v in pairs(scandir(pth)) do
		table.insert(files, v)
    end
    return files
end

local function file_exi(name, cpath)
    for k,v in pairs(exi_files(cpath)) do
        if name == v then
            return true
        end
    end
    return false
end

local function action_by_reply(arg, data)
   local msg = arg.msg
   local cmd = arg.cmd
  if data.sender_user_id_ then
    if cmd == "visudo" then
local function visudo_cb(arg, data)
if data.username_ then
user_name = '@'..check_markdown(data.username_)
else
user_name = check_markdown(data.first_name_)
end
if already_sudo(tonumber(data.id_)) then
    return edit_msg(arg.chat_id, msg.id, "_User_ "..user_name.." *"..data.id_.."* _is already a_ *sudoer*", "md")
   end
          table.insert(_config.sudo_users, tonumber(data.id_))
		save_config()
     reload_plugins(true)
    return edit_msg(arg.chat_id, msg.id, "_User_ "..user_name.." *"..data.id_.."* _is now_ *sudoer*", "md")
end
tdcli_function ({
    ID = "GetUser",
    user_id_ = data.sender_user_id_
  }, visudo_cb, {chat_id=data.chat_id_,user_id=data.sender_user_id_})
  end
    if cmd == "desudo" then
local function desudo_cb(arg, data)
if data.username_ then
user_name = '@'..check_markdown(data.username_)
else
user_name = check_markdown(data.first_name_)
end
     if not already_sudo(data.id_) then
    return edit_msg(arg.chat_id, msg.id, "_User_ "..user_name.." *"..data.id_.."* _is not a_ *sudoer*", "md")
   end
          table.remove(_config.sudo_users, getindex( _config.sudo_users, tonumber(data.id_)))
		save_config()
     reload_plugins(true) 
    return edit_msg(arg.chat_id, msg.id, "_User_ "..user_name.." *"..data.id_.."* _is no longer a_ *sudoer*", "md")
end
tdcli_function ({
    ID = "GetUser",
    user_id_ = data.sender_user_id_
  }, desudo_cb, {chat_id=data.chat_id_,user_id=data.sender_user_id_})
  end
   if cmd == "block" then
   tdcli.blockUser(data.sender_user_id_, dl_cb, nil)
    edit_msg(data.chat_id_, msg.id, "_User_ *"..data.sender_user_id_.."* _Has Been_ *Blocked*", "md")
   end
   if cmd == "unblock" then
   tdcli.unblockUser(data.sender_user_id_, dl_cb, nil)
    edit_msg(data.chat_id_, msg.id, "_User_ *"..data.sender_user_id_.."* _Has Been_ *Unblocked*", "md")
   end
else
  return edit_msg(data.chat_id_, msg.id, "*User not founded*", "md")
     end
  end

local function action_by_username(arg, data)
   local cmd = arg.cmd
   local msg = arg.msg
  if data.id_ then
    if cmd == "visudo" then
if already_sudo(tonumber(data.id_)) then
    return edit_msg(arg.chat_id, msg.id, "_User_ "..user_name.." *"..data.id_.."* _is already a_ *sudoer*", "md")
   end
          table.insert(_config.sudo_users, tonumber(data.id_))
		save_config()
     reload_plugins(true)
    return edit_msg(arg.chat_id, msg.id, "_User_ "..user_name.." *"..data.id_.."* _is now_ *sudoer*", "md")
end
    if cmd == "desudo" then
     if not already_sudo(data.id_) then
    return edit_msg(arg.chat_id, msg.id, "_User_ "..user_name.." *"..data.id_.."* _is not a_ *sudoer*", "md")
   end
          table.remove(_config.sudo_users, getindex( _config.sudo_users, tonumber(data.id_)))
		save_config()
     reload_plugins(true)
    return edit_msg(arg.chat_id, msg.id, "_User_ "..user_name.." *"..data.id_.."* _is no longer a_ *sudoer*", "md")
   end
   if cmd == "block" then
   tdcli.blockUser(data.id_, dl_cb, nil)
    edit_msg(arg.chat_id, msg.id, "_User_ *"..data.id_.."* _Has Been_ *Blocked*", "md")
   end
   if cmd == "unblock" then
   tdcli.unblockUser(data.id_, dl_cb, nil)
     edit_msg(arg.chat_id, msg.id, "_User_ *"..data.id_.."* _Has Been_ *Unblocked*", "md")
   end
else
  return edit_msg(arg.chat_id, msg.id, "*User not founded*", "md")
     end
  end
local function get_variables_hash(msg)
  if msg.to.type == 'chat' or msg.to.type == 'channel' then
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
    return edit_msg(msg.to.id, msg.id, text, "md")
	else
	return 
  end
end


local function save_value(msg, name, value)
  if (not name or not value) then
    return edit_msg(msg.to.id, msg.id, "Usage: !set var_name value", "md")
  end
  local hash = nil
  if msg.to.type == 'chat' or msg.to.type == 'channel' then

    hash = 'chat:bot:variables'
  end
  if hash then
    redis:hset(hash, name, value)
    return edit_msg(msg.to.id, msg.id, "_Saved_ *"..name.."*", "md")
  end
end
local function del_value(msg, name)
  if not name then
    return
  end
  local hash = nil
 if msg.to.type == 'chat' or msg.to.type == 'channel' then
    hash = 'chat:bot:variables'
  end
  if hash then
    redis:hdel(hash, name)
    return edit_msg(msg.to.id, msg.id, "_Removed_ *"..name.."*", "md")
  end
end

local function delallchats(msg)
  local hash = 'chat:bot:variables'

  if hash then
    local names = redis:hkeys(hash)
    for i=1, #names do
      redis:hdel(hash,names[i])
    end
    return edit_msg(msg.to.id, msg.id, "*Done!*", "md")
	else
	return 
  end
end


local function run(msg, matches)
   local chat = msg.to.id
   local user = msg.from.id
if matches[1] == "clear cache" and tonumber(msg.from.id) == our_id then
     run_bash("rm -rf ~/.telegram-cli/data/sticker/*")
     run_bash("rm -rf ~/.telegram-cli/data/photo/*")
     run_bash("rm -rf ~/.telegram-cli/data/animation/*")
     run_bash("rm -rf ~/.telegram-cli/data/video/*")
     run_bash("rm -rf ~/.telegram-cli/data/audio/*")
     run_bash("rm -rf ~/.telegram-cli/data/voice/*")
     run_bash("rm -rf ~/.telegram-cli/data/temp/*")
     run_bash("rm -rf ~/.telegram-cli/data/thumb/*")
     run_bash("rm -rf ~/.telegram-cli/data/document/*")
     run_bash("rm -rf ~/.telegram-cli/data/profile_photo/*")
     run_bash("rm -rf ~/.telegram-cli/data/encrypted/*")
    return edit_msg(msg.to.id, msg.id, "*All Cache Has Been Cleared*", "md")
   end
   if tonumber(msg.from.id) == tonumber(our_id) then
 if matches[1] == "visudo" then
if not matches[2] and msg.reply_id then
    tdcli_function ({
      ID = "GetMessage",
      chat_id_ = msg.to.id,
      message_id_ = msg.reply_id
    }, action_by_reply, {chat_id=msg.to.id,cmd="visudo",msg=msg})
end
  if matches[2] and string.match(matches[2], '^%d+$') and not msg.reply_id then
if already_sudo(tonumber(matches[2])) then
    return edit_msg(msg.to.id, msg.id, "_User_ *"..matches[2].."* _is already a_ *sudoer*", "md")
   end
          table.insert(_config.sudo_users, tonumber(matches[2]))
		save_config()
     reload_plugins(true)
    return edit_msg(msg.to.id, msg.id, "_User_ *"..matches[2].."* _is now_ *sudoer*", "md")
   end
  if matches[2] and not string.match(matches[2], '^%d+$') and not msg.reply_id then
    tdcli_function ({
      ID = "SearchPublicChat",
      username_ = matches[2]
    }, action_by_username, {chat_id=msg.to.id,username=matches[2],cmd="visudo",msg=msg})
         end
      end
 if matches[1] == "desudo" then
if not matches[2] and msg.reply_id then
    tdcli_function ({
      ID = "GetMessage",
      chat_id_ = msg.to.id,
      message_id_ = msg.reply_id
    }, action_by_reply, {chat_id=msg.to.id,cmd="desudo",msg=msg})
end
  if matches[2] and string.match(matches[2], '^%d+$') and not msg.reply_id then
     if not already_sudo(matches[2]) then
    return edit_msg(msg.to.id, msg.id, "_User_ *"..matches[2].."* _is not a_ *sudoer*", "md")
   end
          table.remove(_config.sudo_users, getindex( _config.sudo_users, tonumber(matches[2])))
		save_config()
     reload_plugins(true)
    return edit_msg(msg.to.id, msg.id, "_User_ *"..matches[2].."* _is no longer a_ *sudoer*", "md")
   end
  if matches[2] and not string.match(matches[2], '^%d+$') and not msg.reply_id then
    tdcli_function ({
      ID = "SearchPublicChat",
      username_ = matches[2]
    }, action_by_username, {chat_id=msg.to.id,username=matches[2],cmd="desudo",msg=msg})
         end
      end
   end
 if matches[1] == "block" and is_sudo(msg) then
if not matches[2] and msg.reply_id then
    tdcli_function ({
      ID = "GetMessage",
      chat_id_ = msg.to.id,
      message_id_ = msg.reply_id
    }, action_by_reply, {chat_id=msg.to.id,cmd="block",msg=msg})
end
  if matches[2] and string.match(matches[2], '^%d+$') and not msg.reply_id then
   tdcli.blockUser(matches[2], dl_cb, nil)
  return edit_msg(msg.to.id, msg.id, "_User_ *"..matches[2].."* _Has Been_ *Blocked*", "md")
   end
  if matches[2] and not string.match(matches[2], '^%d+$') and not msg.reply_id then
    tdcli_function ({
      ID = "SearchPublicChat",
      username_ = matches[2]
    }, action_by_username, {chat_id=msg.to.id,username=matches[2],cmd="block",msg=msg})
         end
      end
 if matches[1] == "unblock" and is_sudo(msg) then
if not matches[2] and msg.reply_id then
    tdcli_function ({
      ID = "GetMessage",
      chat_id_ = msg.to.id,
      message_id_ = msg.reply_id
    }, action_by_reply, {chat_id=msg.to.id,cmd="unblock",msg=msg})
end
  if matches[2] and string.match(matches[2], '^%d+$') and not msg.reply_id then
   tdcli.unblockUser(matches[2], dl_cb, nil)
  return edit_msg(msg.to.id, msg.id, "_User_ *"..matches[2].."* _Has Been_ *Unblocked*", "md")
   end
  if matches[2] and not string.match(matches[2], '^%d+$') and not msg.reply_id then
    tdcli_function ({
      ID = "SearchPublicChat",
      username_ = matches[2]
    }, action_by_username, {chat_id=msg.to.id,username=matches[2],cmd="unblock",msg=msg})
         end
      end
if matches[1] == 'addplugin' and is_sudo(msg) then 
if not is_sudo(msg) then 
return edit_msg(msg.to.id, msg.id, '_You Are Not Allowed To Add Plugin_', "md")
end 
text = matches[2] 
name = matches[3] 
file = io.open('./plugins/'..name, 'w') 
file:write(text) 
file:flush() 
file:close() 
return edit_msg(msg.to.id, msg.id, '_Plugin_ *['..matches[3]..']* _Has Been Added_', "md")
end

if matches[1] == "delplugin" and is_sudo(msg) then	 
if not is_sudo(msg) then 
return edit_msg(msg.to.id, msg.id, "_You Are Not Allow To Delete Plugins!_", "md")
end 
io.popen("cd plugins && rm "..matches[2]..".lua") 
return edit_msg(msg.to.id, msg.id, "*Done!*", "md")
end

  if is_sudo(msg) then
	if matches[1]:lower() == "sendfile" and matches[2] and 
matches[3] then
		local send_file = 
"./"..matches[2].."/"..matches[3]
   if msg.to.type == "channel" then
    del_msg(msg.to.id, msg.id)
       else
     edit_msg(msg.to.id, msg.id, "😐", "md")
   end
		tdcli.sendDocument(msg.chat_id_, msg.id_,0, 
1, nil, send_file, '@BeyondTeam', dl_cb, nil)
	end
	if matches[1]:lower() == "sendplug" and matches[2] then
	    local plug = "./plugins/"..matches[2]..".lua"
   if msg.to.type == "channel" then
    del_msg(msg.to.id, msg.id)
       else
     edit_msg(msg.to.id, msg.id, "😐", "md")
   end
		tdcli.sendDocument(msg.chat_id_, msg.id_,0, 
1, nil, plug, '@BeyondTeam', dl_cb, nil)
    end
  end

    if matches[1]:lower() == 'save' and matches[2] and is_sudo(msg) then
        if tonumber(msg.reply_to_message_id_) ~= 0  then
            function get_filemsg(arg, data)
                function get_fileinfo(arg,data)
                    if data.content_.ID == 'MessageDocument' then
                        fileid = data.content_.document_.document_.id_
                        filename = data.content_.document_.file_name_
                        if (filename:lower():match('.lua$')) then
                            local pathf = tcpath..'/data/document/'..filename
                            if pl_exi(filename) then
                                local pfile = 'plugins/'..matches[2]..'.lua'
                                os.rename(pathf, pfile)
                                tdcli.downloadFile(fileid , dl_cb, nil)
                                edit_msg(msg.to.id, msg.id_, '<b>Plugin</b> <code>'..matches[2]..'</code> <b>Has Been Saved.</b>', 'html')
                            else
                                edit_msg(msg.to.id, msg.id_, '_This file does not exist. Send file again._', 'md')
                            end
                        else
                            edit_msg(msg.to.id, msg.id_, '_This file is not Plugin File._', 'md')
                        end
                    else
                        return
                    end
                end
                tdcli_function ({ ID = 'GetMessage', chat_id_ = msg.chat_id_, message_id_ = data.id_ }, get_fileinfo, nil)
            end
	        tdcli_function ({ ID = 'GetMessage', chat_id_ = msg.chat_id_, message_id_ = msg.reply_to_message_id_ }, get_filemsg, nil)
        end
    end

	if matches[1]:lower() == 'savefile' and matches[2] and is_sudo(msg) then
		if msg.reply_id  then
			local folder = matches[2]
            function get_filemsg(arg, data)
				function get_fileinfo(arg,data)
                    if data.content_.ID == 'MessageDocument' or data.content_.ID == 'MessagePhoto' or data.content_.ID == 'MessageSticker' or data.content_.ID == 'MessageAudio' or data.content_.ID == 'MessageVoice' or data.content_.ID == 'MessageVideo' or data.content_.ID == 'MessageAnimation' then
                        if data.content_.ID == 'MessageDocument' then
							local doc_id = data.content_.document_.document_.id_
							local filename = data.content_.document_.file_name_
                            local pathf = tcpath..'/data/document/'..filename
							local cpath = tcpath..'/data/document'
                            if file_exi(filename, cpath) then
                                local pfile = folder
                                os.rename(pathf, pfile)
                                file_dl(doc_id)
                                edit_msg(msg.to.id, msg.id_, '<b>File</b> <code>'..folder..'</code> <b>Has Been Saved.</b>', 'html')
                            else
                                edit_msg(msg.to.id, msg.id_, '_This file does not exist. Send file again._', 'md')
                            end
						end
						if data.content_.ID == 'MessagePhoto' then
							local photo_id = data.content_.photo_.sizes_[2].photo_.id_
							local file = data.content_.photo_.id_
                            local pathf = tcpath..'/data/photo/'..file..'_(1).jpg'
							local cpath = tcpath..'/data/photo'
                            if file_exi(file..'_(1).jpg', cpath) then
                                local pfile = folder
                                os.rename(pathf, pfile)
                                file_dl(photo_id)
                                edit_msg(msg.to.id, msg.id_, '<b>Photo</b> <code>'..folder..'</code> <b>Has Been Saved.</b>', 'html')
                            else
                                edit_msg(msg.to.id, msg.id_, '_This file does not exist. Send file again._', 'md')
                            end
						end
		                if data.content_.ID == 'MessageSticker' then
							local stpath = data.content_.sticker_.sticker_.path_
							local sticker_id = data.content_.sticker_.sticker_.id_
							local secp = tostring(tcpath)..'/data/sticker/'
							local ffile = string.gsub(stpath, '-', '')
							local fsecp = string.gsub(secp, '-', '')
							local name = string.gsub(ffile, fsecp, '')
                            if file_exi(name, secp) then
                                local pfile = folder
                                os.rename(stpath, pfile)
                                file_dl(sticker_id)
                                edit_msg(msg.to.id, msg.id_, '<b>Sticker</b> <code>'..folder..'</code> <b>Has Been Saved.</b>', 'html')
                            else
                                edit_msg(msg.to.id, msg.id_, '_This file does not exist. Send file again._', 'md')
                            end
						end
						if data.content_.ID == 'MessageAudio' then
						local audio_id = data.content_.audio_.audio_.id_
						local audio_name = data.content_.audio_.file_name_
                        local pathf = tcpath..'/data/audio/'..audio_name
						local cpath = tcpath..'/data/audio'
							if file_exi(audio_name, cpath) then
								local pfile = folder
								os.rename(pathf, pfile)
								file_dl(audio_id)
								edit_msg(msg.to.id, msg.id_, '<b>Audio</b> <code>'..folder..'</code> <b>Has Been Saved.</b>', 'html')
							else
								edit_msg(msg.to.id, msg.id_, '_This file does not exist. Send file again._', 'md')
							end
						end
						if data.content_.ID == 'MessageVoice' then
							local voice_id = data.content_.voice_.voice_.id_
							local file = data.content_.voice_.voice_.path_
							local secp = tostring(tcpath)..'/data/voice/'
							local ffile = string.gsub(file, '-', '')
							local fsecp = string.gsub(secp, '-', '')
							local name = string.gsub(ffile, fsecp, '')
                            if file_exi(name, secp) then
                                local pfile = folder
                                os.rename(file, pfile)
                                file_dl(voice_id)
                                edit_msg(msg.to.id, msg.id_, '<b>Voice</b> <code>'..folder..'</code> <b>Has Been Saved.</b>', 'html')
                            else
                                edit_msg(msg.to.id, msg.id_, '_This file does not exist. Send file again._', 'md')
                            end
						end
						if data.content_.ID == 'MessageVideo' then
							local video_id = data.content_.video_.video_.id_
							local file = data.content_.video_.video_.path_
							local secp = tostring(tcpath)..'/data/video/'
							local ffile = string.gsub(file, '-', '')
							local fsecp = string.gsub(secp, '-', '')
							local name = string.gsub(ffile, fsecp, '')
                            if file_exi(name, secp) then
                                local pfile = folder
                                os.rename(file, pfile)
                                file_dl(video_id)
                                edit_msg(msg.to.id, msg.id_, '<b>Video</b> <code>'..folder..'</code> <b>Has Been Saved.</b>', 'html')
                            else
                                edit_msg(msg.to.id, msg.id_, '_This file does not exist. Send file again._', 'md')
                            end
						end
						if data.content_.ID == 'MessageAnimation' then
							local anim_id = data.content_.animation_.animation_.id_
							local anim_name = data.content_.animation_.file_name_
                            local pathf = tcpath..'/data/animation/'..anim_name
							local cpath = tcpath..'/data/animation'
                            if file_exi(anim_name, cpath) then
                                local pfile = folder
                                os.rename(pathf, pfile)
                                file_dl(anim_id)
                                edit_msg(msg.to.id, msg.id_, '<b>Gif</b> <code>'..folder..'</code> <b>Has Been Saved.</b>', 'html')
                            else
                                edit_msg(msg.to.id, msg.id_, '_This file does not exist. Send file again._', 'md')
                            end
						end
                    else
                        return
                    end
                end
                tdcli_function ({ ID = 'GetMessage', chat_id_ = msg.chat_id_, message_id_ = data.id_ }, get_fileinfo, nil)
            end
	        tdcli_function ({ ID = 'GetMessage', chat_id_ = msg.chat_id_, message_id_ = msg.reply_to_message_id_ }, get_filemsg, nil)
        end
    end

if matches[1] == 'markread' and is_sudo(msg) then
if matches[2] == 'on' then
redis:set('markread:'..msg.to.id, true)
return edit_msg(msg.to.id, msg.id, '_Markread has been turned_ *ON* _for this chat_', "md")
end
if matches[2] == 'off' then
redis:del('markread:'..msg.to.id)
return edit_msg(msg.to.id, msg.id, '_Markread has been turned_ *OFF* _for this chat_', "md")
end
end

if matches[1] == 'setmyusername' and is_sudo(msg) then
tdcli.changeUsername(matches[2], dl_cb, nil)
return edit_msg(msg.to.id, msg.id, '_Username Changed To:_ @'..matches[2], "md")
end

if matches[1] == 'delmyusername' and is_sudo(msg) then
tdcli.changeUsername('', dl_cb, nil)
return edit_msg(msg.to.id, msg.id, '*Done!*', "md")
  end

if matches[1] == 'setmyname' and is_sudo(msg) then
tdcli.changeName(matches[2], dl_cb, nil)
return edit_msg(msg.to.id, msg.id, '_Name Changed To:_ *'..matches[2]..'*', "md")
end

if matches[1] == 'delmyname' and is_sudo(msg) then
tdcli.changeName(' ', dl_cb, nil)
return edit_msg(msg.to.id, msg.id, '_Name Has Been Deleted_', "md")
end

if matches[1] == 'addcontact' and is_sudo(msg) then
    local phone_number = matches[2]
    local first_name = matches[3]
    local last_name = matches[4]
    tdcli.importContacts(phone_number, first_name, last_name, 0)
    return edit_msg(msg.to.id, msg.id, '_User_ *[+'.. matches[2] ..']* _Has Been Added_', "md")
  end

if matches[1] == 'delcontact' and is_sudo(msg) then
    tdcli.deleteContacts({
      [0] = tonumber(matches[2])
    })
    return edit_msg(msg.to.id, msg.id, '_User_ *['.. matches[2] ..']* _Removed From Contact List_', "md")
  end

    if matches[1] == 'left' and is_sudo(msg) then
    edit_msg(msg.to.id, msg.id, "*Bye All :D*", "md")
  tdcli.changeChatMemberStatus(chat, our_id, 'Left', dl_cb, nil)
   end

    if matches[1] == 'selfbot' then
    return tdcli.sendMessage(msg.to.id, msg.id, 1, _config.info_text, 1, 'html')
   end

    if matches[1] == 'sudolist' and is_sudo(msg) then
    return sudolist(msg)
   end

if matches[1] == 'chatlist' and is_sudo(msg) then
    local output = list_chats(msg)
    return output
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
if matches[1] then
 return get_value(msg, matches[1])
end
 end
return { 
patterns = { 
"^[!/#](visudo)$", 
"^[!/#](desudo)$",
"^[!/#](sudolist)$",
"^[!/#](visudo) (.*)$", 
"^[!/#](desudo) (.*)$",
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
"^[!/#](selfbot)$",
"^[!/#](clear cache)$",
"^[!/#](left)$",
"^[!/#](block)$",
"^[!/#](block)$",
"^[!/#](unblock)$",
"^[!/#](block) (.*)$",
"^[!/#](unblock) (.*)$",
"^[!/#](sendfile) (.*) (.*)$",
"^[!/#](save) (.*)$",
"^[!/#](sendplug) (.*)$",
"^[!/#](savefile) (.*)$",
"^(.+)$",
}, 
run = run 
}
