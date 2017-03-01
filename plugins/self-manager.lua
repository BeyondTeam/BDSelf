local function show_bot_settings(msg)
   local text = '*》Self Bot Settings :《*\n'

   local hash = 'autoleave'
    if not redis:get(hash) then
        autoleave = '[Enable]'
    else
        autoleave = '[Disable]'
    end

   local hash = 'anti-flood'
    if not redis:get(hash) then
        antiflood = '[Enable]'
    else
        antiflood = '[Disable]'
    end

   local hash = 'markread'
    if redis:get(hash) == "on" then
        markread = '[Yes]'
    else
        markread = '[No]'
    end

   local hash = 'flood_max'
    if not redis:get(hash) then
        MSG_NUM_MAX = 5
    else
        MSG_NUM_MAX = tonumber(redis:get(hash))
    end

    local hash = 'flood_time'
    if not redis:get(hash) then
        TIME_CHECK = 2
    else
        TIME_CHECK = tonumber(redis:get(hash))
    end
    local hash = 'mute_gp:'..msg.to.id
    if redis:get(hash) then
        muteall = '[Enable]'
    else
        muteall = '[Disable]'
    end
if msg.to.type == 'channel' then
    text = text..'_》Auto Leave :_ *'..autoleave..'*\n_》Mute All :_ *'..muteall..'*\n_》Messages Read :_ *'..markread..'*\n_》Pv Max Flood :_ *['..MSG_NUM_MAX..']*\n_》Pv Flood Time Check :_ *['..TIME_CHECK..']*\n_》Pv Flood Protection :_ *'..antiflood..'*\n*》*@BeyondTeam*《*'
return text
elseif msg.to.type == 'pv' or msg.to.type == 'chat' then
    text = text..'_》Auto Leave :_ *'..autoleave..'*\n_》Messages Read :_ *'..markread..'*\n_》Pv Max Flood :_ *['..MSG_NUM_MAX..']*\n_》Pv Flood Time Check :_ *['..TIME_CHECK..']*\n_》Pv Flood Protection :_ *'..antiflood..'*\n*》*@BeyondTeam*《*'
return text
   end
end

local function enable_channel(receiver)
	if not _config.disabled_channels then
		_config.disabled_channels = {}
	end

	if _config.disabled_channels[receiver] == nil or _config.disabled_channels[receiver] == false then
		return "`Self Is Not Off :)`"
	end
	
	_config.disabled_channels[receiver] = false

	save_config()
	return tdcli.sendMessage(receiver, "", 0, "*Self Is On Now :D*", 0, "md")
end

local function disable_channel( receiver )
 if not _config.disabled_channels then
  _config.disabled_channels = {}
 end
 
 _config.disabled_channels[receiver] = true

 save_config()
 return "*Self Is Off Now :/*"
end

local function pre_process(msg)
local chat_id = msg.to.id
local user_id = msg.from.id
local hash = 'autoleave' 

	if is_sudo(msg) then
	  if msg.content_.text_ == "/self on" or msg.content_.text_ == "/Self on" or msg.content_.text_ == "!self on" or msg.content_.text_ == "!Self on" then
	  
	    enable_channel(msg.chat_id_)
	  end
	end

if tonumber(msg.adduser) == our_id and not redis:get(hash) then
 tdcli.sendMessage(msg.to.id, "", 0, "_Don't invite me_ *JackAss :/*", 0, "md")
  tdcli.changeChatMemberStatus(msg.to.id, our_id, 'Left', dl_cb, nil)
end

    local hash = 'flood_max'
    if not redis:get(hash) then
        MSG_NUM_MAX = 5
    else
        MSG_NUM_MAX = tonumber(redis:get(hash))
    end

    local hash = 'flood_time'
    if not redis:get(hash) then
        TIME_CHECK = 2
    else
        TIME_CHECK = tonumber(redis:get(hash))
    end
    if msg.to.type == 'pv' then
        --Checking flood
        local hashse = 'anti-flood'
        if not redis:get(hashse) then
            print('anti-flood enabled')
            -- Check flood
                if not is_sudo(msg) then
                    -- Increase the number of messages from the user on the chat
                    local hash = 'flood:'..user_id..':msg-number'
                    local msgs = tonumber(redis:get(hash) or 0)
                    if msgs > MSG_NUM_MAX then
          local flooder = 'flooder'
          local is_offender = redis:sismember(flooder, user_id)
   if msg.from.username then
    user_name = "@"..msg.from.username
       else
    user_name = msg.from.first_name
   end
        if is_offender then
if redis:get('user:'..user_id..':flooder') then
return
else
  tdcli.sendMessage(chat_id, msg.id, 0, "_You are_ *blocked* _because of_ *flooding...!*", 0, "md")
    tdcli.blockUser(user_id, dl_cb, nil)
   tdcli.sendMessage(our_id, 0, 1, 'User [ '..user_name..' ] '..msg.from.id..' has been blocked because of flooding!', 1)
redis:setex('user:'..user_id..':flooder', 15, true)
redis:srem(flooder, user_id)
                        end
                    end
        if not is_offender then
if redis:get('user:'..user_id..':flooder') then
return
else
  tdcli.sendMessage(chat_id, msg.id, 0, "_Don't_ *flooding*, _Next time you will be_ *block...!*", 0, "md")
redis:setex('user:'..user_id..':flooder', 2, true)
redis:sadd(flooder, user_id)
                          end
                       end
                    end
                    redis:setex(hash, TIME_CHECK, msgs+1)
         end
    end
end
   if redis:get("mute_gp:"..msg.to.id) and not is_sudo(msg) then
   del_msg(msg.to.id, msg.id)
  end
-----------------------
end
-------------------
local function run(msg, matches)
local receiver = msg.chat_id_
	-- Enable a channel
	if not is_sudo(msg) then
	return nil
	end
 if matches[1] == 'on' then
  return enable_channel(receiver)
 end
 if matches[1] == 'off' then
  return disable_channel(receiver)
 end
-----------------------
     if matches[1] == 'autoleave' and is_sudo(msg) then
local hash = 'autoleave'
--Enable Auto Leave
     if matches[2] == 'on' then
     if not redis:get(hash) then
   return 'Auto leave is already enabled'
      else
    redis:del(hash)
   return 'Auto leave has been enabled'
     end
--Disable Auto Leave
     elseif matches[2] == 'off' then
     if redis:get(hash) then
   return 'Auto leave is already disabled'
      else
    redis:set(hash, true)
   return 'Auto leave has been disabled'
         end
      end
   end

     if matches[1] == 'antiflood' and is_sudo(msg) then
local hash = 'anti-flood'
--Enable Anti-flood
     if matches[2] == 'on' then
  if not redis:get(hash) then
    return '_Private_ *flood protection* _is already_ *enabled*'
    else
    redis:del(hash)
   return reply_msg(msg.id, '_Private_ *flood protection* _has been_ *enabled*', ok_cb, false)
      end
--Disable Anti-flood
     elseif matches[2] == 'off' then
  if redis:get(hash) then
    return '_Private_ *flood protection* _is already_ *disabled*'
    else
    redis:set(hash, true)
   return '_Private_ *flood protection* _has been_ *disabled*'
                   end
             end
       end
                if matches[1] == 'pvfloodtime' and is_sudo(msg) then
                    if not matches[2] then
                    else
                        hash = 'flood_time'
                        redis:set(hash, matches[2])
            return '_Private_ *flood check time* _has been set to :_ *'..matches[2]..'*'
                    end
          elseif matches[1] == 'pvsetflood' and is_sudo(msg) then
                    if not matches[2] then
                    else
                        hash = 'flood_max'
                        redis:set(hash, matches[2])
            return '_Private_ *flood sensitivity* _has been set to :_ *'..matches[2]..'*'
                    end
                 end

       if matches[1] == 'settings' and is_sudo(msg) then
      return show_bot_settings(msg)
                 end

       if matches[1] == 'edit' and matches[2] and is_sudo(msg) then
       tdcli.editMessageText(msg.chat_id_, msg.reply_id, nil, matches[2], 1, 'md', dl_cb, nil)
del_msg(msg.to.id, msg.id)
   end

if matches[1] == 'help' and is_sudo(msg) then

local text = [[
*Commands:*

*!settings*
_Send Self Bot Settings_

*!gpid*
_Show Group Id_

*!tosuper*
_Change Chat To Channel_

*!chatlist*
_Show Name List_

*!chat + name answer*
_Set Chat Name And Answer_

*!chat - name*
_Disabeled Chatting in Group_

*!chat clean*
_Clean Name And Answers_

*!delmy*`[name | username]`
_Delete Name Or Username_

*!markread* `[on | off]`
_Change Markread Status_

*!autoleave* `[on | off]`
_Set Auto Leave Status_

*!antiflood* `[on | off]`
_Set Anfi Flood Status_

*!self* `[on | off]`
_Set Self Bot Status In Group_

*!pin* `(reply)`
_Pin Your Message In Group_

*!unpin*
_Unpin Your Message In Group_

*!id* `[reply | username]`
_Show User Id_

*!del* (reply)
_Delete Message_

*!inv* `[id | username | reply]`
_Invite User To Group_

*!kick* `[id | username | reply]`
_Kick User From Group_

*!delall* `[id | username | reply]`
_Delete All Messages Of User_

*!mute* `all`
_Mute Group_

*!unmute* `all`
_UnMute Group_

*!set*`[name | des | link]`
_Set Group Name , Description , Link_

*!addplugin* _text_ `name.lua`
_Create Your Own Plugin_

*!delplugin* `name`
_Delete Plugin_

*!setmy*`[name | username]` *(name|username)*
_Set Your Name or Your Username_

*!addcontact* `[phone | firstname | lastname]`
_Added A New Contact_

*!delcontact* `[phone]`
_Delete Contact_

*!addname* `[name]`
_Add New Name To Name List_

*!remname* `[name]`
_Remove Name From Name List_

*!setanswer* `[answer]`
_Add New Answer To Answer List_

*!remanswer* `[answer]`
_Remove Answer From Answer List_

*!namelist*
_Show Names List_

*!answerlist*
_Show Answers List_

*!pvsetflood* `[msgs]`
_Tet The Maximum Messages In A Floodtime To Be Considered As Flood_

*!pvfloodtime* `[secs]`
_Set The Time That Bot Uses To Check Flood_

*!block* `[reply | id | username]`
_Block User_

*!unblock* `[reply | id | username]`
_UnBlock User_

*!sendfile* `[folder] [file]`
_Send file from folder_

*!sendplug* `[plug]`
_Send plugin_

*!save* `[plugin name] [reply]`
_Save plugin by reply_

*!savefile* `[adress/filename] [reply]`
_Save File by reply to specific folder_

*!edit* `[text] [reply]`
_Edit Your meesage by reply to specific message_

*!clear cache*
_Clear All Cache Of .telegram-cli/data_

*!helpfun*
_Show Fun Help_

*Good Luck ;)*]]

tdcli.sendMessage(msg.sender_user_id_, "", 0, text, 0, "md")
            return '_Help was send in your private message_'
end
end

return {
	description = "Plugin to manage channels. Enable or disable channel.", 
	usage = {
		"/channel enable: enable current channel",
		"/channel disable: disable current channel" },
	patterns = {
     "^[!/#](antiflood) (.*)$",
     "^[!/#](pvfloodtime) (%d+)$",
     "^[!/#](pvsetflood) (%d+)$",
		"^[!/#](autoleave) (.*)$",
		"^[!/#](edit) (.*)$",
		"^[!/#](settings)$",
		"^[!/#](help)$",
		"^[!/][Ss]elf (on)",
		"^[!/][Ss]elf (off)" }, 
	run = run,
	pre_process = pre_process
}
