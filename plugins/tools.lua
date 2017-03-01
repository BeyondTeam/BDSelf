--Tools.lua :D

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
   local cmd = arg.cmd
  if data.sender_user_id_ then
   if cmd == "block" then
   tdcli.blockUser(data.sender_user_id_, dl_cb, nil)
    tdcli.sendMessage(data.chat_id_, data.id_, 0, "_User_ *"..data.sender_user_id_.."* _Has Been_ *Blocked*", 0, "md")
   end
   if cmd == "unblock" then
   tdcli.unblockUser(data.sender_user_id_, dl_cb, nil)
    tdcli.sendMessage(data.chat_id_, data.id_, 0, "_User_ *"..data.sender_user_id_.."* _Has Been_ *Unblocked*", 0, "md")
   end
else
  return tdcli.sendMessage(data.chat_id_, "", 0, "*User not founded*", 0, "md")
     end
  end

local function action_by_username(arg, data)
   local cmd = arg.cmd
  if data.id_ then
   if cmd == "block" then
   tdcli.blockUser(data.id_, dl_cb, nil)
    tdcli.sendMessage(arg.chat_id, "", 0, "_User_ *"..data.id_.."* _Has Been_ *Blocked*", 0, "md")
   end
   if cmd == "unblock" then
   tdcli.unblockUser(data.id_, dl_cb, nil)
     tdcli.sendMessage(arg.chat_id, "", 0, "_User_ *"..data.id_.."* _Has Been_ *Unblocked*", 0, "md")
   end
else
  return tdcli.sendMessage(arg.chat_id, "", 0, "*User not founded*", 0, "md")
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
  if msg.to.type == 'chat' or msg.to.type == 'channel' then

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
 if msg.to.type == 'chat' or msg.to.type == 'channel' then
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
    return "*All Cache Has Been Cleared*"
   end
 if matches[1] == "block" and is_sudo(msg) then
if not matches[2] and msg.reply_id then
    tdcli_function ({
      ID = "GetMessage",
      chat_id_ = msg.to.id,
      message_id_ = msg.reply_id
    }, action_by_reply, {chat_id=msg.to.id,cmd="block"})
end
  if matches[2] and string.match(matches[2], '^%d+$') and not msg.reply_id then
   tdcli.blockUser(matches[2], dl_cb, nil)
  return "_User_ *"..matches[2].."* _Has Been_ *Blocked*"
   end
  if matches[2] and not string.match(matches[2], '^%d+$') and not msg.reply_id then
    tdcli_function ({
      ID = "SearchPublicChat",
      username_ = matches[2]
    }, action_by_username, {chat_id=msg.to.id,username=matches[2],cmd="block"})
         end
      end
 if matches[1] == "unblock" and is_sudo(msg) then
if not matches[2] and msg.reply_id then
    tdcli_function ({
      ID = "GetMessage",
      chat_id_ = msg.to.id,
      message_id_ = msg.reply_id
    }, action_by_reply, {chat_id=msg.to.id,cmd="unblock"})
end
  if matches[2] and string.match(matches[2], '^%d+$') and not msg.reply_id then
   tdcli.unblockUser(matches[2], dl_cb, nil)
  return "_User_ *"..matches[2].."* _Has Been_ *Unblocked*"
   end
  if matches[2] and not string.match(matches[2], '^%d+$') and not msg.reply_id then
    tdcli_function ({
      ID = "SearchPublicChat",
      username_ = matches[2]
    }, action_by_username, {chat_id=msg.to.id,username=matches[2],cmd="unblock"})
         end
      end
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

  if is_sudo(msg) then
	if matches[1]:lower() == "sendfile" and matches[2] and 
matches[3] then
		local send_file = 
"./"..matches[2].."/"..matches[3]
		tdcli.sendDocument(msg.chat_id_, msg.id_,0, 
1, nil, send_file, '@BeyondTeam', dl_cb, nil)
	end
	if matches[1]:lower() == "sendplug" and matches[2] then
	    local plug = "./plugins/"..matches[2]..".lua"
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
                                tdcli.sendMessage(msg.to.id, msg.id_,1, '<b>Plugin</b> <code>'..matches[2]..'</code> <b>Has Been Saved.</b>', 1, 'html')
                            else
                                tdcli.sendMessage(msg.to.id, msg.id_, 1, '_This file does not exist. Send file again._', 1, 'md')
                            end
                        else
                            tdcli.sendMessage(msg.to.id, msg.id_, 1, '_This file is not Plugin File._', 1, 'md')
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
                                tdcli.sendMessage(msg.to.id, msg.id_,1, '<b>File</b> <code>'..folder..'</code> <b>Has Been Saved.</b>', 1, 'html')
                            else
                                tdcli.sendMessage(msg.to.id, msg.id_, 1, '_This file does not exist. Send file again._', 1, 'md')
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
                                tdcli.sendMessage(msg.to.id, msg.id_,1, '<b>Photo</b> <code>'..folder..'</code> <b>Has Been Saved.</b>', 1, 'html')
                            else
                                tdcli.sendMessage(msg.to.id, msg.id_, 1, '_This file does not exist. Send file again._', 1, 'md')
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
                                tdcli.sendMessage(msg.to.id, msg.id_,1, '<b>Sticker</b> <code>'..folder..'</code> <b>Has Been Saved.</b>', 1, 'html')
                            else
                                tdcli.sendMessage(msg.to.id, msg.id_, 1, '_This file does not exist. Send file again._', 1, 'md')
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
								tdcli.sendMessage(msg.to.id, msg.id_,1, '<b>Audio</b> <code>'..folder..'</code> <b>Has Been Saved.</b>', 1, 'html')
							else
								tdcli.sendMessage(msg.to.id, msg.id_, 1, '_This file does not exist. Send file again._', 1, 'md')
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
                                tdcli.sendMessage(msg.to.id, msg.id_,1, '<b>Voice</b> <code>'..folder..'</code> <b>Has Been Saved.</b>', 1, 'html')
                            else
                                tdcli.sendMessage(msg.to.id, msg.id_, 1, '_This file does not exist. Send file again._', 1, 'md')
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
                                tdcli.sendMessage(msg.to.id, msg.id_,1, '<b>Video</b> <code>'..folder..'</code> <b>Has Been Saved.</b>', 1, 'html')
                            else
                                tdcli.sendMessage(msg.to.id, msg.id_, 1, '_This file does not exist. Send file again._', 1, 'md')
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
                                tdcli.sendMessage(msg.to.id, msg.id_,1, '<b>Gif</b> <code>'..folder..'</code> <b>Has Been Saved.</b>', 1, 'html')
                            else
                                tdcli.sendMessage(msg.to.id, msg.id_, 1, '_This file does not exist. Send file again._', 1, 'md')
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
redis:set('markread','on')
return '_Markread >_ *ON*'
end
if matches[2] == 'off' then
redis:set('markread','off')
return '_Markread >_ *OFF*'
end
end

if matches[1] == 'setmyusername' and is_sudo(msg) then
tdcli.changeUsername(matches[2], dl_cb, nil)
return '_Username Changed To:_ @'..matches[2]
end

if matches[1] == 'delmyusername' and is_sudo(msg) then
tdcli.changeUsername('', dl_cb, nil)
return '*Done!*'
  end

if matches[1] == 'setmyname' and is_sudo(msg) then
tdcli.changeName(matches[2], dl_cb, nil)
return '_Name Changed To:_ *'..matches[2]..'*'
end

if matches[1] == 'delmyname' and is_sudo(msg) then
tdcli.changeName(' ', dl_cb, nil)
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

    if matches[1] == 'left' and is_sudo(msg) then
    tdcli.sendMessage(msg.to.id, "", 0, "*Bye All :D*", 0, "md")
  tdcli.changeChatMemberStatus(chat, our_id, 'Left', dl_cb, nil)
   end

    if matches[1] == 'selfbot' then
    return tdcli.sendMessage(msg.to.id, msg.id, 1, _config.info_text, 1, 'html')
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
