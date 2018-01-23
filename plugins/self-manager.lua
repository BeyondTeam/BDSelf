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
return edit_msg(msg.to.id, msg.id, text, "md")
elseif msg.to.type == 'pv' or msg.to.type == 'chat' then
    text = text..'_》Auto Leave :_ *'..autoleave..'*\n_》Messages Read :_ *'..markread..'*\n_》Pv Max Flood :_ *['..MSG_NUM_MAX..']*\n_》Pv Flood Time Check :_ *['..TIME_CHECK..']*\n_》Pv Flood Protection :_ *'..antiflood..'*\n*》*@BeyondTeam*《*'
return edit_msg(msg.to.id, msg.id, text, "md")
   end
end

local function disable_channel(msg_id, receiver)
 if not _config.disabled_channels then
  _config.disabled_channels = {}
 end
 
 _config.disabled_channels[receiver] = true

 save_config()
 return edit_msg(receiver, msg_id, "*Self Is Off Now :/*", "md")
end

local function pre_process(msg)
local chat_id = msg.to.id
local user_id = msg.from.id
local hash = 'autoleave' 

if not redis:get('autodeltime-self') then
	redis:setex('autodeltime-self', 14400, true)
     run_bash("rm -rf ~/.telegram-bot/cli/data/stickers/*")
     run_bash("rm -rf ~/.telegram-bot/cli/files/photos/*")
     run_bash("rm -rf ~/.telegram-bot/cli/files/animations/*")
     run_bash("rm -rf ~/.telegram-bot/cli/files/videos/*")
     run_bash("rm -rf ~/.telegram-bot/cli/files/music/*")
     run_bash("rm -rf ~/.telegram-bot/cli/files/voice/*")
     run_bash("rm -rf ~/.telegram-bot/cli/files/temp/*")
     run_bash("rm -rf ~/.telegram-bot/cli/data/temp/*")
     run_bash("rm -rf ~/.telegram-bot/cli/files/documents/*")
     run_bash("rm -rf ~/.telegram-bot/cli/data/profile_photos/*")
     run_bash("rm -rf ~/.telegram-bot/cli/files/video_notes/*")
	 run_bash("rm -rf ./data/photos/*")
end

  if tonumber(msg.from.id) ~= 0 then
    local hash = 'user_name:'..msg.from.id
    if msg.from.username then
     user_name = '@'..msg.from.username
  else
     user_name = msg.from.print_name
    end
      redis:set(hash, user_name)
   end

if msg.adduser and tonumber(msg.adduser) == tonumber(our_id) and not redis:get(hash) then
 tdbot.sendMessage(msg.to.id, "", 0, "_Don't invite me_ *JackAss :/*", 0, "md")
  tdbot.changeChatMemberStatus(msg.to.id, our_id, 'Left', dl_cb, nil)
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
  tdbot.sendMessage(chat_id, msg.id, 0, "_You are_ *blocked* _because of_ *flooding...!*", 0, "md")
    tdbot.blockUser(user_id, dl_cb, nil)
   tdbot.sendMessage(our_id, 0, 1, 'User [ '..user_name..' ] '..msg.from.id..' has been blocked because of flooding!', 1)
redis:setex('user:'..user_id..':flooder', 15, true)
redis:srem(flooder, user_id)
                        end
                    end
        if not is_offender then
if redis:get('user:'..user_id..':flooder') then
return
else
  tdbot.sendMessage(chat_id, msg.id, 0, "_Don't_ *flooding*, _Next time you will be_ *block...!*", 0, "md")
redis:setex('user:'..user_id..':flooder', 2, true)
redis:sadd(flooder, user_id)
                          end
                       end
                    end
                    redis:setex(hash, TIME_CHECK, msgs+1)
         end
    end
end

   if (is_silented_user(msg.to.id, msg.from.id) or redis:get("mute_gp:"..msg.to.id)) and not is_sudo(msg) then
   del_msg(msg.to.id, msg.id)
  end
-----------------------
end
-------------------
local function run(msg, matches)
local receiver = msg.to.id
	-- Enable a channel
	if not is_sudo(msg) then
	return nil
	end
 if matches[1] == 'on' then
  return enable_channel(receiver)
 end
 if matches[1] == 'off' then
  return disable_channel(msg.id, receiver)
 end
-----------------------
     if matches[1] == 'autoleave' and is_sudo(msg) then
local hash = 'autoleave'
--Enable Auto Leave
     if matches[2] == 'on' then
     if not redis:get(hash) then
   return edit_msg(msg.to.id, msg.id, 'Auto leave is already enabled', "md")
      else
    redis:del(hash)
   return edit_msg(msg.to.id, msg.id, 'Auto leave has been enabled', "md")
     end
--Disable Auto Leave
     elseif matches[2] == 'off' then
     if redis:get(hash) then
   return edit_msg(msg.to.id, msg.id, 'Auto leave is already disabled', "md")
      else
    redis:set(hash, true)
   return edit_msg(msg.to.id, msg.id, 'Auto leave has been disabled', "md")
         end
      end
   end

     if matches[1] == 'antiflood' and is_sudo(msg) then
local hash = 'anti-flood'
--Enable Anti-flood
     if matches[2] == 'on' then
  if not redis:get(hash) then
    return edit_msg(msg.to.id, msg.id, '_Private_ *flood protection* _is already_ *enabled*', "md")
    else
    redis:del(hash)
   return edit_msg(msg.to.id, msg.id, '_Private_ *flood protection* _has been_ *enabled*', "md")
      end
--Disable Anti-flood
     elseif matches[2] == 'off' then
  if redis:get(hash) then
    return edit_msg(msg.to.id, msg.id, '_Private_ *flood protection* _is already_ *disabled*', "md")
    else
    redis:set(hash, true)
   return edit_msg(msg.to.id, msg.id, '_Private_ *flood protection* _has been_ *disabled*', "md")
                   end
             end
       end
                if matches[1] == 'pvfloodtime' and is_sudo(msg) then
                    if not matches[2] then
                    else
                        hash = 'flood_time'
                        redis:set(hash, matches[2])
            return edit_msg(msg.to.id, msg.id, '_Private_ *flood check time* _has been set to :_ *'..matches[2]..'*', "md")
                    end
          elseif matches[1] == 'pvsetflood' and is_sudo(msg) then
                    if not matches[2] then
                    else
                        hash = 'flood_max'
                        redis:set(hash, matches[2])
            return edit_msg(msg.to.id, msg.id, '_Private_ *flood sensitivity* _has been set to :_ *'..matches[2]..'*', "md")
                    end
                 end

       if matches[1] == 'settings' and is_sudo(msg) then
      return show_bot_settings(msg)
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

*!silent* `[id | username | reply]`
_Add User To Silent List_

*!unsilent* `[id | username | reply]`
_Remove User From Silent List_

*!delall* `[id | username | reply]`
_Delete All Messages Of User_

*!mute* `all`
_Mute Group_

*!unmute* `all`
_UnMute Group_

*!set*`[name | des | link]`
_Set Group Name , Description , Link_

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

*!silentlist*
_Show Silent List_

*!clean silentlist*
_Clean Silent List_

*!pvsetflood* `[msgs]`
_Tet The Maximum Messages In A Floodtime To Be Considered As Flood_

*!pvfloodtime* `[secs]`
_Set The Time That Bot Uses To Check Flood_

*!helpfun*
_Show Fun Help_

*!helptools*
_Show Tools Help_

*Good Luck ;)*]]

tdbot.sendMessage(msg.from.id, "", 0, text, 0, "md")
            return edit_msg(msg.to.id, msg.id, '_Help was send in your private message_', "md")
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
		"^[!/][Ss]elf (off)" 
}, 
	run = run,
moderated = true,
	pre_process = pre_process
}
