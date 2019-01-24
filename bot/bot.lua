-- #Beyond Self Robot
-- #@BeyondTeam

tdcli = dofile('./tg/tdcli.lua')
serpent = (loadfile "./libs/serpent.lua")()
feedparser = (loadfile "./libs/feedparser.lua")()
require('./bot/utils')
URL = require "socket.url"
http = require "socket.http"
https = require "ssl.https"
ltn12 = require "ltn12"
json = (loadfile "./libs/JSON.lua")()
utf8 = (loadfile "./libs/utf8.lua")()
mimetype = (loadfile "./libs/mimetype.lua")()
redis = (loadfile "./libs/redis.lua")()
JSON = (loadfile "./libs/dkjson.lua")()
local lgi = require ('lgi')
local notify = lgi.require('Notify')
notify.init ("Telegram updates")
chats = {}
plugins = {}

function do_notify (user, msg)
	local n = notify.Notification.new(user, msg)
	n:show ()
end

function dl_cb (arg, data)
	-- vardump(data)
end
function vardump(value)
	print(serpent.block(value, {comment=false}))
end
function load_data(filename)
	local f = io.open(filename)
	if not f then
		return {}
	end
	local s = f:read('*all')
	f:close()
	local data = JSON.decode(s)
	return data
end

function save_data(filename, data)
	local s = JSON.encode(data)
	local f = io.open(filename, 'w')
	f:write(s)
	f:close()
end

function match_plugins(msg)
	for name, plugin in pairs(plugins) do
		match_plugin(plugin, name, msg)
	end
end

function whoami()
	local usr = io.popen("id -un"):read('*a')
	usr = string.gsub(usr, '^%s+', '')
	usr = string.gsub(usr, '%s+$', '')
	usr = string.gsub(usr, '[\n\r]+', ' ') 
	if usr:match("^root$") then
		tcpath = '/root/.telegram-cli'
	elseif not usr:match("^root$") then
		tcpath = '/home/'..usr..'/.telegram-cli'
	end
end

function save_self( )
  serialize_to_file(_self, './data/self.lua')
  print ('saved self into ./data/self.lua')
end

function create_self( )
  self = {
    names = {
    "solid",
    "سلید",
    "سولید",
    "سعید",
    "saeed",
    "saeid"
    },
    answers = {
    "وات؟ :/",
    "بلی؟",
    "بفرما",
    "بوگوی :|",
    "جونم؟",
    "جونز",
    "ژون؟ :/"
    },
}
  serialize_to_file(self, './data/self.lua')
  print('saved self into ./data/self.lua')
end

function load_self( )
  local f = io.open('./data/self.lua', "r")
  -- If self.lua doesn't exist
  if not f then
    print ("Created new self file: data/self.lua")
    create_self()
  else
    f:close()
  end
  local self = loadfile ("./data/self.lua")()
  for k, v in pairs(self.names) do
    --print("self names : " ..v)
  end
  return self
end

function save_config( )
	serialize_to_file(_config, './data/config.lua')
	print ('saved config into ./data/config.lua')
end

function create_config( )
  -- A simple config with basic plugins and ourselves as privileged user
	config = {
    enabled_plugins = {
    "self-manager",
    "groupmanager",
    "plugins",
    "self",
		"tools",
     "fun"
	},
    sudo_users = {602899187},
    admins = {},
    disabled_channels = {},
    moderation = {data = './data/moderation.json'},
    info_text = [[》Beyond Self Bot V3.0
An fun bot based on BDReborn

》https://github.com/BeyondTeam/BDSelf 

》Admins :
》@SoLiD ➣ Founder & Developer《
》@Makan ➣ Developer & Sponser《
》@ToOfan ➣ Developer《

》Special thanks to :
》@kuncen
》@Vysheng
》@MrHalix
》And Beyond Team Members

》Our channel :
》@BeyondTeam《

》Our website :
》http://BeyondTeam.ir
]],
  }
	serialize_to_file(config, './data/config.lua')
	print ('saved config into config.lua')
end

-- Returns the config from config.lua file.
-- If file doesn't exist, create it.
function load_config( )
	local f = io.open('./data/config.lua', "r")
  -- If config.lua doesn't exist
	if not f then
		print ("Created new config file: ./data/config.lua")
		create_config()
	else
		f:close()
	end
	local config = loadfile ("./data/config.lua")()
	for v,user in pairs(config.sudo_users) do
		print("SUDO USER: " .. user)
	end
	return config
end

whoami()
_config = load_config()
_self = load_self()
function load_plugins()
	local config = loadfile ("./data/config.lua")()
	for k, v in pairs(config.enabled_plugins) do
		print("Loaded Plugin	", v)
		local ok, err =  pcall(function()
		local t = loadfile("plugins/"..v..'.lua')()
		plugins[v] = t
		end)
		if not ok then
			print('\27[31mError loading plugins '..v..'\27[39m')
			print(tostring(io.popen("lua plugins/"..v..".lua"):read('*all')))
			print('\27[31m'..err..'\27[39m')
		end
	end
	print('\n'..#config.enabled_plugins..' Plugins Are Active\n\nStarting Self Robot...\n')
end

load_plugins()

local function is_channel_disabled( receiver )
 if not _config.disabled_channels then
  return false
 end

 if _config.disabled_channels[receiver] == nil then
  return false
 end

  return _config.disabled_channels[receiver]
end

local function enable_channel(msg_id, receiver)
	if not _config.disabled_channels then
		_config.disabled_channels = {}
	end

	if _config.disabled_channels[receiver] == nil or _config.disabled_channels[receiver] == false then
		return edit_msg(receiver, msg_id, "`Self Is Not Off :)`", "md")
	end
	
	_config.disabled_channels[receiver] = false

	save_config()
	return edit_msg(receiver, msg_id, "*Self Is On Now :D*","md")
end

function msg_valid(msg)
	 if msg.date_ < os.time() - 60 then
        print('\27[36mNot valid: old msg\27[39m')
		 return false
	 end
	if is_sudo(msg) and msg.content_.text_ then
	  if msg.content_.text_ == "/self on" or msg.content_.text_ == "/Self on" or msg.content_.text_ == "!self on" or msg.content_.text_ == "!Self on" then
	    enable_channel(msg.id_, msg.chat_id_)
	  end
	end
  if is_channel_disabled(msg.chat_id_) then
    print('\27[36m➣Self Is Off :/\27[39m')
   return false
	  end
    return true
end

function match_pattern(pattern, text, lower_case)
	if text then
		local matches = {}
		if lower_case then
			matches = { string.match(text:lower(), pattern) }
		else
			matches = { string.match(text, pattern) }
		end
		if next(matches) then
			return matches
		end
	end
end

-- Check if plugin is on _config.disabled_plugin_on_chat table
local function is_plugin_disabled_on_chat(plugin_name, receiver)
  local disabled_chats = _config.disabled_plugin_on_chat
  -- Table exists and chat has disabled plugins
  if disabled_chats and disabled_chats[receiver] then
    -- Checks if plugin is disabled on this chat
    for disabled_plugin,disabled in pairs(disabled_chats[receiver]) do
      if disabled_plugin == plugin_name and disabled then
        local warning = '_Plugin_ *'..check_markdown(disabled_plugin)..'* _is disabled on this chat_'
        print(warning)
						tdcli.sendMessage(receiver, "", 0, warning, 0, "md")
        return true
      end
    end
  end
  return false
end

function match_plugin(plugin, plugin_name, msg)
	if plugin.pre_process then
        --If plugin is for privileged users only
		local result = plugin.pre_process(msg)
		if result then
			print("pre process: ", plugin_name)
        -- tdcli.sendMessage(msg.chat_id_, "", 0, result, 0, "md")
		end
	end
	for k, pattern in pairs(plugin.patterns) do
		matches = match_pattern(pattern, msg.text or msg.media.caption)
		if matches then
      if is_plugin_disabled_on_chat(plugin_name, msg.chat_id_) then
        return nil
      end
			print("Message matches: ", pattern..' | Plugin: '..plugin_name)
			if plugin.run then
        if not warns_user_not_allowed(plugin, msg) then
				local result = plugin.run(msg, matches)
					if result then
						tdcli.sendMessage(msg.chat_id_, msg.id_, 0, result, 0, "md")
                 end
					end
			end
			return
		end
	end
end

function file_cb(msg)
	if msg.content_.ID == "MessagePhoto" then
		photo_id = ''
		local function get_cb(arg, data)
			photo_id = data.content_.photo_.sizes_[2].photo_.id_
			tdcli.downloadFile(photo_id, dl_cb, nil)
		end
		tdcli_function ({ ID = "GetMessage", chat_id_ = msg.chat_id_, message_id_ = msg.id_ }, get_cb, nil)
	elseif msg.content_.ID == "MessageVideo" then
		video_id = ''
		local function get_cb(arg, data)
			video_id = data.content_.video_.video_.id_
			tdcli.downloadFile(video_id, dl_cb, nil)
		end
		tdcli_function ({ ID = "GetMessage", chat_id_ = msg.chat_id_, message_id_ = msg.id_ }, get_cb, nil)
	elseif msg.content_.ID == "MessageAnimation" then
		anim_id, anim_name = '', ''
		local function get_cb(arg, data)
			anim_id = data.content_.animation_.animation_.id_
			anim_name = data.content_.animation_.file_name_
			 tdcli.downloadFile(anim_id, dl_cb, nil)
		end
		tdcli_function ({ ID = "GetMessage", chat_id_ = msg.chat_id_, message_id_ = msg.id_ }, get_cb, nil)
	elseif msg.content_.ID == "MessageVoice" then
		voice_id = ''
		local function get_cb(arg, data)
			voice_id = data.content_.voice_.voice_.id_
			tdcli.downloadFile(voice_id, dl_cb, nil)
		end
		tdcli_function ({ ID = "GetMessage", chat_id_ = msg.chat_id_, message_id_ = msg.id_ }, get_cb, nil)
	elseif msg.content_.ID == "MessageAudio" then
		audio_id, audio_name, audio_title = '', '', ''
		local function get_cb(arg, data)
			audio_id = data.content_.audio_.audio_.id_
			audio_name = data.content_.audio_.file_name_
			audio_title = data.content_.audio_.title_
			tdcli.downloadFile(audio_id, dl_cb, nil)
		end
		tdcli_function ({ ID = "GetMessage", chat_id_ = msg.chat_id_, message_id_ = msg.id_ }, get_cb, nil)
	elseif msg.content_.ID == "MessageSticker" then
		sticker_id = ''
		local function get_cb(arg, data)
			sticker_id = data.content_.sticker_.sticker_.id_
			tdcli.downloadFile(sticker_id, dl_cb, nil)
		end
		tdcli_function ({ ID = "GetMessage", chat_id_ = msg.chat_id_, message_id_ = msg.id_ }, get_cb, nil)
	elseif msg.content_.ID == "MessageDocument" then
		document_id, document_name = '', ''
		local function get_cb(arg, data)
			document_id = data.content_.document_.document_.id_
			document_name = data.content_.document_.file_name_
			tdcli.downloadFile(document_id, dl_cb, nil)
		end
		tdcli_function ({ ID = "GetMessage", chat_id_ = msg.chat_id_, message_id_ = msg.id_ }, get_cb, nil)
end
end
function tdcli_update_callback (data)
	-- print(serpent.block(data))
	if (data.ID == "UpdateNewMessage") then

		local msg = data.message_
		local d = data.disable_notification_
		local chat = chats[msg.chat_id_]
		local hash = 'msgs:'..msg.sender_user_id_..':'..msg.chat_id_
		redis:incr(hash)
		if redis:get('markread:'..msg.chat_id_) then
			tdcli.viewMessages(msg.chat_id_, {[0] = msg.id_}, dl_cb, nil)
    end
		if ((not d) and chat) then
			if msg.content_.ID == "MessageText" then
				do_notify (chat.title_, msg.content_.text_)
			else
				do_notify (chat.title_, msg.content_.ID)
			end
		end
    if msg_valid(msg) then
		var_cb(msg, msg)
		file_cb(msg)
	if msg.content_.ID == "MessageText" then
			msg.text = msg.content_.text_
			msg.edited = false
			msg.pinned = false
	elseif msg.content_.ID == "MessagePinMessage" then
		msg.pinned = true
	elseif msg.content_.ID == "MessagePhoto" then
		msg.photo_ = true 

	elseif msg.content_.ID == "MessageVideo" then
		msg.video_ = true

	elseif msg.content_.ID == "MessageAnimation" then
		msg.animation_ = true

	elseif msg.content_.ID == "MessageVoice" then
		msg.voice_ = true

	elseif msg.content_.ID == "MessageAudio" then
		msg.audio_ = true

	elseif msg.content_.ID == "MessageForwardedFromUser" then
		msg.forward_info_ = true

	elseif msg.content_.ID == "MessageSticker" then
		msg.sticker_ = true

	elseif msg.content_.ID == "MessageContact" then
		msg.contact_ = true
	elseif msg.content_.ID == "MessageDocument" then
		msg.document_ = true

	elseif msg.content_.ID == "MessageLocation" then
		msg.location_ = true
	elseif msg.content_.ID == "MessageGame" then
		msg.game_ = true
	elseif msg.content_.ID == "MessageChatAddMembers" then
			for i=0,#msg.content_.members_ do
				msg.adduser = msg.content_.members_[i].id_
		end
	elseif msg.content_.ID == "MessageChatJoinByLink" then
			msg.joinuser = msg.sender_user_id_
	elseif msg.content_.ID == "MessageChatDeleteMember" then
			msg.deluser = true
	end
end
	elseif data.ID == "UpdateMessageContent" then  
		cmsg = data
		local function edited_cb(arg, data)
			msg = data
			msg.media = {}
			if cmsg.new_content_.text_ then
				msg.text = cmsg.new_content_.text_
			end
			if cmsg.new_content_.caption_ then
				msg.media.caption = cmsg.new_content_.caption_
			end
			msg.edited = true
   if msg_valid(msg) then
			var_cb(msg, msg)
    end
 end
	tdcli_function ({ ID = "GetMessage", chat_id_ = data.chat_id_, message_id_ = data.message_id_ }, edited_cb, nil)
	elseif data.ID == "UpdateFile" then
		file_id = data.file_.id_
	elseif (data.ID == "UpdateChat") then
		chat = data.chat_
		chats[chat.id_] = chat
	elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
		tdcli_function ({ID="GetChats", offset_order_="9223372036854775807", offset_chat_id_=0, limit_=20}, dl_cb, nil)    
	end
end

