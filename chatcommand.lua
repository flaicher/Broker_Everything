
-- some usefull namespace to locals
local addon, ns = ...
local C, L = ns.LC.color, ns.L
local ACD = LibStub("AceConfigDialog-3.0");

--
-- Chat command handler
--

local commands = {
	options     = {
		desc = L["Open options panel"],
		func = ns.ToggleBlizzOptionPanel
	},
	broker = "options",
	config = "options",
	reset       = {
		desc = L["Reset all module settings"],
		func = ns.resetConfigs
	},
	list        = {
		desc = L["List of available modules with his status"],
		func = function()
			ns.print(L["Cfg"], L["Data modules:"])
			for k, v in ns.pairsByKeys(ns.modules) do
				if v and v.noBroker~=true and ns.profile[k] then
					local stat = {"red","Off"}
					if ns.profile[k].enabled==true then
						stat = {"green","On"}
					end
					ns.print(L["Cfg"], (k==L[k] and "%s | %s" or "%s | %s - ( %s )"):format(C(stat[1],stat[2]),C("ltyellow",k),L[k]))
				end
			end
		end,
	},
	equip = {
		desc = L["Equip a set."],
		func = function(cmd)
			local num = C_EquipmentSet.GetNumEquipmentSets()
			if cmd == nil then
				ns.print(BAG_FILTER_EQUIPMENT,L["Usage: /be equip <SetName>"])
				ns.print(BAG_FILTER_EQUIPMENT,L["Available Sets:"])

				if num>0 then
					for i=0, num-1 do -- very rare in wow... equipment set index starts with 0 instead of 1
						local eName, icon, setID, isEquipped, totalItems, equippedItems, inventoryItems, missingItems, ignoredSlots = C_EquipmentSet.GetEquipmentSetInfo(i);
						ns.print(BAG_FILTER_EQUIPMENT,C((isEquipped and "yellow") or (missingItems>0 and "red") or "ltblue",eName))
					end
				else
					ns.print(BAG_FILTER_EQUIPMENT,L["No sets found"])
				end
			else
				local validEquipment
				for i=1, C_EquipmentSet.GetNumEquipmentSets() do
					local eName, _, _, isEquipped, _, _, _, _ = C_EquipmentSet.GetEquipmentSetInfo(i)
					if cmd==eName then validEquipment = true end
				end
				if (not validEquipment) then
					ns.print(BAG_FILTER_EQUIPMENT,L["Name of Equipmentset are invalid"])
				else
					ns.toggleEquipment(cmd)
				end
			end
		end
	},
	version = {
		desc = L["Display current version of Broker_Everything"],
		func = function()
			ns.print(GAME_VERSION_LABEL,GetAddOnMetadata(addon,"Version"));
		end
	}
}

function ns.AddChatCommand(key,data)
	if not commands[key] then
		commands[key] = data;
	end
end

SlashCmdList["BROKER_EVERYTHING"] = function(cmd)
	local cmd, arg = strsplit(" ", cmd, 2)
	cmd = cmd:lower()

	if cmd=="" then
		ns.print(INFO, L["Chat command list for /be & /broker_everything"])
		local cmds = {};
		for i,v in pairs(ns.commands)do tinsert(cmds,i); end
		table.sort(cmds);
		for _,name in pairs(cmds) do
			local obj = ns.commands[name];
			if type(obj)=="string" then
				ns.print(INFO, ("%s - alias of %s"):format(C("yellow",name),C("yellow",obj)))
			else
				ns.print(INFO, ("%s - %s"):format(C("yellow",name),obj.desc))
			end
		end
		return
	end

	if ns.commands[cmd]~=nil and type(ns.commands[cmd])=="string" then
		cmd = ns.commands[cmd];
	end

	if ns.commands[cmd]~=nil and type(ns.commands[cmd].func)=="function" then
		ns.commands[cmd].func(arg);
	end

	cmd = cmd:gsub("^%l", string.upper)
	for k, v in pairs(ns.profile) do
		if k == cmd then
			local x = ns.profile[cmd].enabled
			print(tostring(x))
			if x == true then
				ns.profile[cmd].enabled = false
				print(tostring(ns.profile[cmd].enabled))
					ns.print(L["Cfg"], L["Disabling %s on next reload."]:format(cmd)) -- cmd
				else
					ns.profile[cmd].enabled = true
					ns.print(L["Cfg"], L["Enabling %s on next reload."]:format(cmd)) -- cmd
			end
		end
	end

end


SLASH_BROKER_EVERYTHING1 = "/broker_everything"
SLASH_BROKER_EVERYTHING2 = "/be"

