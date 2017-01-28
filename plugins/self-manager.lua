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
    local hash = 'mute_gp:'..msg.chat_id_
    if redis:get(hash) then
        muteall = '[Enable]'
    else
        muteall = '[Disable]'
    end
if gp_type(msg.chat_id_) == 'channel' then
    text = text..'_》Auto Leave :_ *'..autoleave..'*\n_》Mute All :_ *'..muteall..'*\n_》Messages Read :_ *'..markread..'*\n_》Pv Max Flood :_ *['..MSG_NUM_MAX..']*\n_》Pv Flood Time Check :_ *['..TIME_CHECK..']*\n_》Pv Flood Protection :_ *'..antiflood..'*\n*》*@BeyondTeam*《*'
return text
elseif gp_type(msg.chat_id_) == 'pv' or gp_type(msg.chat_id_) == 'chat' then
    text = text..'_》Auto Leave :_ *'..autoleave..'*\n_》Messages Read :_ *'..markread..'*\n_》Pv Max Flood :_ *['..MSG_NUM_MAX..']*\n_》Pv Flood Time Check :_ *['..TIME_CHECK..']*\n_》Pv Flood Protection :_ *'..antiflood..'*\n*》*@BeyondTeam*《*'
return text
   end
end

local function enable_chat(chat_id)
 local hash = 'on-off:'..chat_id

	if not redis:get(hash) then
		return "*Self Is Not Off :)*"
	end
	
	redis:del(hash)
	return "_Self Is On Now_ *:D*"
end

local function disable_chat( chat_id )
 local hash = 'on-off:'..chat_id
	redis:set(hash, true)
	return "*Self Is Off Now :/*"
end

local function pre_process(msg)
local chat_id = msg.chat_id_
local user_id = msg.sender_user_id_
local function check_invite(arg, data)
local hash = 'autoleave' 
if tonumber(data.id_) == our_id and not redis:get(hash) then
 tdcli.sendMessage(arg.chat_id, "", 0, "_Don't invite me_ *JackAss :/*", 0, "md")
  tdcli.changeChatMemberStatus(arg.chat_id, our_id, 'Left', dl_cb, nil)
end
end
	if msg.adduser then
			tdcli_function ({
	      ID = "GetUser",
      	user_id_ = msg.adduser
    	}, check_invite, {chat_id=msg.chat_id_,msg_id=msg.id_})
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
    if gp_type(chat_id) == 'pv' then
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
        if is_offender then
if redis:get('user:'..user_id..':flooder') then
return
else
  tdcli.sendMessage(chat_id, msg.id_, 0, "_You are_ *blocked* _because of_ *flooding...!*", 0, "md")
    tdcli.blockUser(user_id, dl_cb, nil)
  local function flooder_cb(arg, data)
   if data.username_ then
    user_name = "@"..data.username_
       else
    user_name = data.first_name_
   end
   tdcli.sendMessage(our_id, 0, 1, 'User [ '..user_name..' ] '..data.id_..' has been blocked because of flooding!', 1)
    end
tdcli_function ({
    ID = "GetUser",
    user_id_ = user_id
  }, flooder_cb, {chat_id=chat_id})
redis:setex('user:'..user_id..':flooder', 15, true)
redis:srem(flooder, user_id)
                        end
                    end
        if not is_offender then
if redis:get('user:'..user_id..':flooder') then
return
else
  tdcli.sendMessage(chat_id, msg.id_, 0, "_Don't_ *flooding*, _Next time you will be_ *block...!*", 0, "md")
redis:setex('user:'..user_id..':flooder', 2, true)
redis:sadd(flooder, user_id)
                          end
                       end
                    end
                    redis:setex(hash, TIME_CHECK, msgs+1)
              end
        end
   end
   if redis:get("mute_gp:"..msg.chat_id_) and not is_sudo(msg) then
   del_msg(msg.chat_id_, msg.id_)
  end
-----------------------
end
-------------------
local function run(msg, matches)
  local chat = tostring(msg.chat_id_)
     if chat:match("-100") then
    gpid = string.gsub(msg.chat_id_, "-100", "")
     elseif chat:match("-") then
    gpid = string.gsub(msg.chat_id_, "-", "")
   end
	-- Enable a channel
	if not is_sudo(msg) then
	return nil
	end
	if matches[1] == 'on' then
		return enable_chat(gpid)
	end
	-- Disable a channel
	if matches[1] == 'off' then
		return disable_chat(gpid)
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

if matches[1] == 'help' and is_sudo(msg) then

local text = [[
*Commands:*

*!help*
_Send Help In Your Pv_

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

*!delmyusername*
_Delete Username_

*!delmyname*
_Delete name_

*!markread* `[on | off]`
_Change Markread Status_

*!autoleave* `[on | off]`
_Set Auto Leave Status_

*!self* `[on | off]`
_Set Self Bot Status In Group_

*!pin* `(reply)`
_Pin Your Message In Group_

*!unpin* `(reply)`
_Unpin Your Message In Group_

*!id* `[reply | username]`
_Show User Id_

*!del* (reply)
_Delete Message_

*!import* `(link)`
_Join With Link_

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

*!setmyusername* `[username]`
_Set Your Username_

*!setmyname* `[name]`
_Set Your Name_

*!addcontact* `[phone | firstname | lastname]`
_Added A New Contact_

*!delcontact* `[phone]`
_Delete Contact_

*!block* `[reply | id | username]`
_Block User_

*!unblock* `[reply | id | username]`
_UnBlock User_

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
		"^[!/#](settings)$",
		"^[!/#](help)$",
		"^[!/][Ss]elf (on)",
		"^[!/][Ss]elf (off)" }, 
	run = run,
	pre_process = pre_process
}
