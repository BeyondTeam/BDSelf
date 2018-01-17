--[[
################################
#                              #
#        Self Plugin           #
#                              #
#                              #
#     by @SoLiD ⇨Saeid⇦       #
#                              #
#                              #
#   Team Channel @BeyondTeam   #
#	                       #
#                              #
#     Update: 2 March 2017     #
#                              #
#       Special Thx To         # 
#     @Exacute for idea        #
#                              #
################################
]]
do
local function self_names( name )
  for k,v in pairs(_self.names) do
    if string.lower(name) == v then
      return k
    end
  end
  -- If not found
  return false
end

local function self_answers( answer )
  for k,v in pairs(_self.answers) do
    if answer == v then
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

local function namelist(msg)
local namelist = _self.names
local text = "*Names list :*\n"
for i=1,#namelist do
    text = text..i.." - "..namelist[i].."\n"
end
return edit_msg(msg.to.id, msg.id, text, "md")
end

local function answerlist(msg)
local answerlist = _self.answers
local text = "*Answers list :*\n"
for i=1,#answerlist do
    text = text..i.." - "..answerlist[i].."\n"
end
return edit_msg(msg.to.id, msg.id, text, "md")
end

local function set_name(msg, name)
  -- Check if name founded
  if self_names(name) then
    return edit_msg(msg.to.id, msg.id, '_Name_ *'..name..'* _founded_', "md")
  end
    -- Add to the self table
    table.insert(_self.names, name)
    save_self()
    reload_plugins( )
    -- Reload the plugins
    return edit_msg(msg.to.id, msg.id, '_New name_ *'..name..'* _added to name list_', "md")
end

local function set_answer(msg, answer)
  -- Check if name founded
  if self_answers(answer) then
    return edit_msg(msg.to.id, msg.id, '_Word_ *'..answer..'* _founded_', "md")
  end
    -- Add to the self table
    table.insert(_self.answers, answer)
    save_self()
    reload_plugins( )
    -- Reload the plugins
    return edit_msg(msg.to.id, msg.id, '_New word_ *'..answer..'* _added to answer list_', "md")
end

local function rem_name(msg, name)
  local k = self_names(name)
  -- Check if name not founded
  if not k then
    return edit_msg(msg.to.id, msg.id, '_Name_ *'..name..'* _not founded_', "md")
  end
  -- remove and reload
  table.remove(_self.names, k)
  save_self( )
  reload_plugins(true)
  return edit_msg(msg.to.id, msg.id, '_Name_ *'..name..'* _removed from name list_', "md")
end

local function rem_answer(msg, answer)
  local k = self_answers(answer)
  -- Check if answer not founded
  if not k then
    return edit_msg(msg.to.id, msg.id, '_Word_ *'..answer..'* _not founded_', "md")
  end
  -- remove and reload
  table.remove(_self.answers, k)
  save_self( )
  reload_plugins(true)
  return edit_msg(msg.to.id, msg.id, '_Word_ *'..answer..'* _removed from answer list_', "md")
end

local function run(msg, matches)
local answer = _self.answers
local text = answer[math.random(#answer)]

			if matches[1]:lower() == "addname" and is_sudo(msg) then
      local name = matches[2]
      return set_name(msg, name)
      elseif matches[1]:lower() == "remname" and is_sudo(msg) then
      local name = matches[2]
      return rem_name(msg, name)
			elseif matches[1]:lower() == "setanswer" and is_sudo(msg) then
      local answer = matches[2]
      return set_answer(msg, answer)
      elseif matches[1]:lower() == "remanswer" and is_sudo(msg) then
      local answer = matches[2]
      return rem_answer(msg, answer)
         elseif matches[1]:lower() == 'namelist' and is_sudo(msg) then
  return tdcli.sendMessage(msg.to.id, msg.id, 0, namelist(msg), 0, "md")
         elseif matches[1]:lower() == 'answerlist' and is_sudo(msg) then
  return tdcli.sendMessage(msg.to.id, msg.id, 0, answerlist(msg), 0, "md")
    end
if self_names(matches[1]) then
 local chat = tostring(msg.to.id)
    if not is_sudo(msg) then
  return tdcli.sendMessage(msg.to.id, msg.id, 0, text, 0, "md")
      end
   end 
end
return {
patterns = {
"^[!/]([Aa]ddname) (.*)$",
"^[!/]([Rr]emname) (.*)$",
"^[!/]([Nn]amelist)$",
"^[!/]([Ss]etanswer) (.*)$",
"^[!/]([Rr]emanswer) (.*)$",
"^[!/]([Aa]nswerlist)$",
"^(.*)$"
},
run = run
}

end
--End self.lua By @SoLiD
