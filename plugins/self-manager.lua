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
	msg.text = msg.content_.text_
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
   if redis:get("mute_gp:"..msg.chat_id_) then
   del_msg(msg.chat_id_, msg.id_)
  end
-----------------------
end
-------------------
local function run(msg, matches)
     if msg.chat_id_:match("-100") then
    gpid = string.gsub(msg.chat_id_, "-100", "")
     elseif msg.chat_id_:match("-") then
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
end

if matches[1] == 'help' and is_sudo(msg) then

text = [[
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
_Disabeled Chatting in Group

*!chat clean*
_Clean Name And Answers_

*!delmyusername*
_Delete Username_

*!delmyname*
_Delete name_

*!markread* `[on | off]`
_Change Markread Status_

*!typing* `[on | off]`
_Change Typing Status_

*!autoleave `[on | off]`
_Set Auto Leave Status_

*!self `[on | off]`
_Set Self Bot Status In Group_

*!pin* `(reply)`
_Pin Your Message In Group_

*!unpin* `(reply)`
_Unpin Your Message In Group_

*!id* `(reply)`
_Show User Id_

*!del* (reply)
_Delete Message_

*!import* `(link)`
_Join With Link_

*!inv `[id | username | reply]`

*!kick* `[id | username | reply]`

*!delall `[id | username | reply]`

*!mute* [`all | id | username | reply]`
_Mute Actions_

*!unmute* `[all | id | username | reply]`
_UnMute Actions_

*!set*`[name | des | link]`

*!addplugin _text_ `name.lua`
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

*!block* `[id | username]`
_Block User_

*!unblock* `[id | username]`
_UnBlock User_

*Good Luck ;)*]]

tdcli.sendMessage(msg.sender_user_id_, '', 0, text, 0, 'md')
            return "_Help was send in your private message_"

end

return {
	description = "Plugin to manage channels. Enable or disable channel.", 
	usage = {
		"/channel enable: enable current channel",
		"/channel disable: disable current channel" },
	patterns = {
		"^[!/#](autoleave) (.*)$",
		"^[!/#](settings)$",
		"^[!/#](help)$",
		"^[!/][Ss]elf (on)",
		"^[!/][Ss]elf (off)" }, 
	run = run,
	--privileged = true,
	--moderated = true,
	pre_process = pre_process
}
