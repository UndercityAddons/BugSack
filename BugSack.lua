-- The BugSack and BugGrabber team is:
-- Current Developer: Rabbit
-- Past Developers: Rowne, Ramble, industrial, Fritti, kergoth
-- Testers: Ramble, Sariash
--
-- Credits to AceGUI & LuaPad for the scrollbar knowledge.
--[[

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

]]

if not LibStub then
	print("BugSack requires LibStub.")
	return
end
local AL = LibStub:GetLibrary("AceLocale-3.0", true)
if not AL then
	print("BugSack requires AceLocale-3.0.")
	return
end
local BugGrabber = BugGrabber
if not BugGrabber then
	local msg = "|cffff4411BugSack requires the |r|cff44ff44!BugGrabber|r|cffff4411 addon, which you can download from the same place you got BugSack. Happy bug hunting!|r"
	local f = CreateFrame("Frame")
	f:SetScript("OnEvent", function()
		RaidNotice_AddMessage(RaidWarningFrame, msg, {r=1, g=0.3, b=0.1})
		print(msg)
		f:UnregisterEvent("PLAYER_ENTERING_WORLD")
		f:SetScript("OnEvent", nil)
		f = nil
	end)
	f:RegisterEvent("PLAYER_ENTERING_WORLD")
	return
end

local L = AL:GetLocale("BugSack"); AL = nil
local media = LibStub("LibSharedMedia-3.0", true)

BugSack = CreateFrame("Frame")
local BugSack = BugSack

-- Frame state variables
local sackCurrent = nil

local show = nil
do
	local countLabel, sessionLabel, textArea = nil, nil, nil, nil
	local nextButton, prevButton = nil, nil
	local function createBugSack()
		local window = CreateFrame("Frame", "BugSackFrame", UIParent)
		UIPanelWindows["BugSackFrame"] = { area = "center", pushable = 0, whileDead = 1 }
		HideUIPanel(BugSackFrame)

		window:SetFrameStrata("FULLSCREEN_DIALOG")
		window:SetWidth(500)
		window:SetHeight(500 / 1.618)
		window:SetPoint("CENTER")
		window:SetMovable(true)
		window:EnableMouse(true)
		window:SetClampedToScreen(true)
		window:RegisterForDrag("LeftButton")
		window:SetScript("OnDragStart", window.StartMoving)
		window:SetScript("OnDragStop", window.StopMovingOrSizing)
		window:SetScript("OnShow", function()
			PlaySound("igQuestLogOpen")
		end)
		window:SetScript("OnHide", function()
			PlaySound("igQuestLogClose")
		end)

		local titlebg = window:CreateTexture(nil, "BORDER")
		titlebg:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Title-Background")
		titlebg:SetPoint("TOPLEFT", 9, -6)
		titlebg:SetPoint("BOTTOMRIGHT", window, "TOPRIGHT", -28, -24)

		local dialogbg = window:CreateTexture(nil, "BACKGROUND")
		dialogbg:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-CharacterTab-L1")
		dialogbg:SetPoint("TOPLEFT", 8, -12)
		dialogbg:SetPoint("BOTTOMRIGHT", -6, 8)
		dialogbg:SetTexCoord(0.255, 1, 0.29, 1)

		local topleft = window:CreateTexture(nil, "BORDER")
		topleft:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
		topleft:SetWidth(64)
		topleft:SetHeight(64)
		topleft:SetPoint("TOPLEFT")
		topleft:SetTexCoord(0.501953125, 0.625, 0, 1)

		local topright = window:CreateTexture(nil, "BORDER")
		topright:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
		topright:SetWidth(64)
		topright:SetHeight(64)
		topright:SetPoint("TOPRIGHT")
		topright:SetTexCoord(0.625, 0.75, 0, 1)

		local top = window:CreateTexture(nil, "BORDER")
		top:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
		top:SetHeight(64)
		top:SetPoint("TOPLEFT", topleft, "TOPRIGHT")
		top:SetPoint("TOPRIGHT", topright, "TOPLEFT")
		top:SetTexCoord(0.25, 0.369140625, 0, 1)

		local bottomleft = window:CreateTexture(nil, "BORDER")
		bottomleft:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
		bottomleft:SetWidth(64)
		bottomleft:SetHeight(64)
		bottomleft:SetPoint("BOTTOMLEFT")
		bottomleft:SetTexCoord(0.751953125, 0.875, 0, 1)

		local bottomright = window:CreateTexture(nil, "BORDER")
		bottomright:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
		bottomright:SetWidth(64)
		bottomright:SetHeight(64)
		bottomright:SetPoint("BOTTOMRIGHT")
		bottomright:SetTexCoord(0.875, 1, 0, 1)

		local bottom = window:CreateTexture(nil, "BORDER")
		bottom:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
		bottom:SetHeight(64)
		bottom:SetPoint("BOTTOMLEFT", bottomleft, "BOTTOMRIGHT")
		bottom:SetPoint("BOTTOMRIGHT", bottomright, "BOTTOMLEFT")
		bottom:SetTexCoord(0.376953125, 0.498046875, 0, 1)

		local left = window:CreateTexture(nil, "BORDER")
		left:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
		left:SetWidth(64)
		left:SetPoint("TOPLEFT", topleft, "BOTTOMLEFT")
		left:SetPoint("BOTTOMLEFT", bottomleft, "TOPLEFT")
		left:SetTexCoord(0.001953125, 0.125, 0, 1)

		local right = window:CreateTexture(nil, "BORDER")
		right:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
		right:SetWidth(64)
		right:SetPoint("TOPRIGHT", topright, "BOTTOMRIGHT")
		right:SetPoint("BOTTOMRIGHT", bottomright, "TOPRIGHT")
		right:SetTexCoord(0.1171875, 0.2421875, 0, 1)

		local close = CreateFrame("Button", nil, window, "UIPanelCloseButton")
		close:SetPoint("TOPRIGHT", 2, 1)
		close:SetScript("OnClick", BugSack.CloseSack)

		local title = window:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		title:SetAllPoints(titlebg)
		title:SetJustifyH("CENTER")
		title:SetText("BugSack")
		title:Hide()

		local options = CreateFrame("Button", nil, window)
		options:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
		options:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
		options:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
		options:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
		options:SetWidth(32)
		options:SetHeight(32)
		options:SetText("")
		options:SetPoint("TOPLEFT", 12, -29)
		options:Disable()
		options:Hide()

		sessionLabel = window:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		--sessionLabel:SetPoint("LEFT", options, "RIGHT", 16)
		sessionLabel:SetJustifyH("LEFT")
		sessionLabel:SetPoint("TOPLEFT", titlebg, "TOPLEFT", 6, -3)

		countLabel = window:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		--countLabel:SetPoint("TOPRIGHT", window, "TOPRIGHT", -12, -38)
		countLabel:SetPoint("TOPRIGHT", titlebg, "TOPRIGHT", -6, -3)
		countLabel:SetJustifyH("RIGHT")

		nextButton = CreateFrame("Button", "BugSackNextButton", window, "UIPanelButtonTemplate2")
		nextButton:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -11, 16)
		--nextButton:SetHeight(32)
		nextButton:SetWidth(130)
		nextButton:SetText(L["Next >"])
		nextButton:SetScript("OnClick", function()
			sackCurrent = sackCurrent + 1
			show()
		end)
		
		prevButton = CreateFrame("Button", "BugSackPrevButton", window, "UIPanelButtonTemplate2")
		prevButton:SetPoint("BOTTOMLEFT", window, "BOTTOMLEFT", 14, 16)
		--prevButton:SetHeight(32)
		prevButton:SetWidth(130)
		prevButton:SetText(L["< Previous"])
		prevButton:SetScript("OnClick", function()
			sackCurrent = sackCurrent - 1
			show()
		end)
		
		if BugSack.Serialize then
			sendButton = CreateFrame("Button", "BugSackSendButton", window, "UIPanelButtonTemplate2")
			sendButton:SetPoint("TOPLEFT", prevButton, "TOPRIGHT")
			sendButton:SetPoint("BOTTOMRIGHT", nextButton, "BOTTOMLEFT")
			sendButton:SetText(L["Send bugs"])
			sendButton:SetScript("OnClick", function()
				local db = BugGrabber:GetDB()
				local eo = db[sackCurrent]
				local popup = StaticPopup_Show("BugSackSendBugs", eo.session)
				popup.data = eo.session
				window:Hide()
			end)
		end

		local scroll = CreateFrame("ScrollFrame", "BugSackFrameScroll2", window, "UIPanelScrollFrameTemplate")
		--scroll:SetPoint("TOPLEFT", options, "BOTTOMLEFT", 4, -3)
		scroll:SetPoint("TOPLEFT", options, "TOPLEFT", 4, -7)
		scroll:SetPoint("BOTTOMRIGHT", nextButton, "TOPRIGHT", -24, 8)

		textArea = CreateFrame("EditBox", "BugSackFrameScrollText2", scroll)
		textArea:SetAutoFocus(false)
		textArea:SetMultiLine(true)
		textArea:SetFontObject(ChatFontNormal) --GameFontHighlightSmall)
		textArea:SetMaxLetters(99999)
		textArea:EnableMouse(true)
		textArea:SetScript("OnEscapePressed", textArea.ClearFocus)
		-- XXX why the fuck doesn't SetPoint work on the editbox?
		textArea:SetWidth(450)

		scroll:SetScrollChild(textArea)
	end

	local sessionFormat = "%s (%d) - %s" -- Today (123) - <source>
	local countFormat = "%d/%d" -- 1/10
	local sourceFormat = L["Sent by %s (%s)"]
	local localFormat = L["Local (%s)"]

	function show(eo)
		if createBugSack then
			createBugSack()
			createBugSack = nil
		end

		if not eo and sackCurrent == 0 then
			countLabel:SetText()
			sessionLabel:SetText(("%s (%d)"):format(L["Today"], BugGrabber:GetSessionId()))
			textArea:SetText(L["You have no bugs, yay!"])
			nextButton:Disable()
			prevButton:Disable()
			if sendButton then sendButton:Disable() end
		else
			local db = BugGrabber:GetDB()
			if not eo then eo = db[sackCurrent] end
			local source = nil
			if eo.source then source = sourceFormat:format(eo.source, eo.type)
			else source = localFormat:format(eo.type) end
			if eo.session == BugGrabber:GetSessionId() then
				sessionLabel:SetText(sessionFormat:format(L["Today"], eo.session, source))
			else
				sessionLabel:SetText(sessionFormat:format(eo.time, eo.session, source))
			end
			countLabel:SetText(countFormat:format(sackCurrent, #db))
			textArea:SetText(BugSack:FormatError(eo))
			if sackCurrent >= #db then
				nextButton:Disable()
			else
				nextButton:Enable()
			end
			if sackCurrent <= 1 then
				prevButton:Disable()
			else
				prevButton:Enable()
			end
			if sendButton then sendButton:Enable() end
		end
		ShowUIPanel(BugSackFrame)
	end
end

local function print(t)
	DEFAULT_CHAT_FRAME:AddMessage("BugSack: " .. t)
end

function BugSack:Taint(addon)
	if type(addon) ~= "string" then return end
	local printer = AceLibrary("AceConsole-2.0")
	local result = {}
	for k,v in pairs(_G) do
		local secure, tainter = issecurevariable(k)
		if not secure and tainter and tainter:find(addon) then
			result[#result + 1] = tostring(k)
		end
	end
	if #result > 0 then
		table.sort(result)
		printer:Print("Globals found for " .. addon .. ":")
		printer:Print(table.concat(result, ", "))
	else
		printer:Print("No taint found for " .. addon .. ".")
	end
end

do
	local errors = {}
	function BugSack:GetErrors(sessionId)
		-- XXX I've never liked this function, maybe a BugGrabber redesign is in order, where we have one subtable in the DB per session ID.
		if sessionId then
			wipe(errors)
			local db = BugGrabber:GetDB()
			for i, e in next, db do
				if sessionId == e.session then
					errors[#errors + 1] = e
				end
			end
			return errors
		else
			return BugGrabber:GetDB()
		end
	end
end

function BugSack:GetFilter()
	return self.db.filterAddonMistakes
end

function BugSack:ToggleFilter()
	self.db.filterAddonMistakes = not self.db.filterAddonMistakes
	if not self.db.filterAddonMistakes then
		BugGrabber:RegisterAddonActionEvents()
	else
		BugGrabber:UnregisterAddonActionEvents()
	end
end

function BugSack:CloseSack()
	HideUIPanel(BugSackFrame)
end

function BugSack:OpenSack()
	-- XXX we should show the most recent error (from this session) that has not previously been shown in the sack
	-- XXX so, 5 errors are caught, the user clicks the icon, we start it at the first of those 5 errors.
	-- Show the most recent error
	sackCurrent = #BugGrabber:GetDB()
	show()
end

--local errorFormat = [[|cff999999[%s-x%d@%s]|r: %s]]
local errorFormat = [[|cff999999%dx|r %s]]
function BugSack:FormatError(err)
	local m = err.message
	if type(m) == "table" then
		m = table.concat(m, "")
	end
	return errorFormat:format(err.counter or -1, self:ColorError(m))
	--return errorFormat:format(err.time or "unknown", err.counter or -1, err.source or "local", self:ColorError(m or ""))
end

function BugSack:ColorError(err)
	local ret = err
	ret = ret:gsub("|([^chHr])", "||%1") -- pipe char
	ret = ret:gsub("|$", "||") -- pipe char
	ret = ret:gsub("\nLocals:\n", "\n|cFFFFFFFFLocals:|r\n")
	ret = ret:gsub("[Ii][Nn][Tt][Ee][Rr][Ff][Aa][Cc][Ee]\\[Aa][Dd][Dd][Oo][Nn][Ss]\\", "")
	ret = ret:gsub("%{\n +%}", "{}") -- locals: empty table spanning lines
	ret = ret:gsub("([ ]-)([%a_][%a_%d]+) = ", "%1|cffffff80%2|r = ") -- local
	ret = ret:gsub("= (%d+)\n", "= |cffff7fff%1|r\n") -- locals: number
	ret = ret:gsub("<function>", "|cffffea00<function>|r") -- locals: function
	ret = ret:gsub("<table>", "|cffffea00<table>|r") -- locals: table
	ret = ret:gsub("= nil\n", "= |cffff7f7fnil|r\n") -- locals: nil
	ret = ret:gsub("= true\n", "= |cffff9100true|r\n") -- locals: true
	ret = ret:gsub("= false\n", "= |cffff9100false|r\n") -- locals: false
	ret = ret:gsub("= \"([^\n]+)\"\n", "= |cff8888ff\"%1\"|r\n") -- locals: string
	ret = ret:gsub("defined %@(.-):(%d+)", "@ |cffeda55f%1|r:|cff00ff00%2|r:") -- Files/Line Numbers of locals
	ret = ret:gsub("\n(.-):(%d+):", "\n|cffeda55f%1|r:|cff00ff00%2|r:") -- Files/Line Numbers
	ret = ret:gsub("%-%d+%p+.-%\\", "|cffffff00%1|cffeda55f") -- Version numbers
	ret = ret:gsub("%(.-%)", "|cff999999%1|r") -- Parantheses
	ret = ret:gsub("([`'])(.-)([`'])", "|cff8888ff%1%2%3|r") -- Other quotes
	return ret
end

function BugSack:Reset()
	BugGrabber:Reset()
	print(L["All stored bugs have been exterminated painfully."])

	if BugSackLDB then
		BugSackLDB:Update()
	end
end

-- The Error catching function.
do
	local lastError = nil
	function BugSack:OnError()
		if not lastError or GetTime() > (lastError + 2) then
			if media then
				local sound = media:Fetch("sound", self.db.soundMedia) or "Interface\\AddOns\\BugSack\\Media\\error.wav"
				PlaySoundFile(sound)
			elseif not self.db.mute then
				PlaySoundFile("Interface\\AddOns\\BugSack\\Media\\error.wav")
			end
			if self.db.auto then
				self:OpenSack()
			end
			if self.db.chatframe then
				print(L["There's a bug in your soup!"])
			end
			lastError = GetTime()
		end
		if BugSackLDB then
			BugSackLDB:Update()
		end
	end
end

-- Sends the current session errors to another player using AceComm-3.0
function BugSack:SendBugsToUser(player, session)
	if type(player) ~= "string" or player:trim():len() < 2 then
		error("Player needs to be a valid string.")
	end
	if not self.Serialize then return end

	local errors = self:GetErrors(session)
	if not errors or #errors == 0 then return end
	local sz = self:Serialize(errors)
	self:SendCommMessage("BugSack", sz, "WHISPER", player, "BULK")

	print(L["%d bugs have been sent to %s. He must have BugSack to be able to examine them."]:format(#errors, player))
end

function BugSack:OnBugComm(prefix, message, distribution, sender)
	if prefix ~= "BugSack" or not self.Deserialize then return end

	local good, deSz = self:Deserialize(message)
	if not good then
		print("Failure to deserialize incoming data from " .. sender .. ".")
		return
	end

	-- Store recieved errors in the current session database with a source set to the sender
	local s = BugGrabber:GetSessionId()
	for i, err in next, deSz do
		err.source = sender
		err.session = s
		BugGrabber:StoreError(err)
	end

	print(L["You've received %d bugs from %s."]:format(#deSz, sender))

	wipe(deSz)
	deSz = nil
end

BugSack:SetScript("OnEvent", function(self, event, addon)
	if event == "ADDON_LOADED" and addon == "BugSack" then
		local ac = LibStub("AceComm-3.0", true)
		if ac then ac:Embed(self) end
		local as = LibStub("AceSerializer-3.0", true)
		if as then as:Embed(self) end

		local popup = _G.StaticPopupDialogs
		if type(popup) ~= "table" then popup = {} end
		if type(popup["BugSackSendBugs"]) ~= "table" then
			popup["BugSackSendBugs"] = {
				text = L["Send all bugs from the currently viewed session (%d) in the sack to the player specified below."],
				button1 = L["Send"],
				button2 = CLOSE,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				hasEditBox = true,
				OnAccept = function(self, data)
					local recipient = self.editBox:GetText()
					BugSack:SendBugsToUser(recipient, data)
				end,
				OnShow = function(self)
					self.button1:Disable()
				end,
				EditBoxOnTextChanged = function(self, data)
					if self:GetText():len() > 1 then
						self:GetParent().button1:Enable()
					else
						self:GetParent().button1:Disable()
					end
				end,
				enterClicksFirstButton = true,
				OnCancel = function() show() end, -- Need to wrap it so we don't pass |self| as an error argument to show().
			}
		end

		if type(BugSackDB) ~= "table" then BugSackDB = {} end
		local sv = BugSackDB
		if type(sv.mute) ~= "boolean" then sv.mute = false end
		if type(sv.auto) ~= "boolean" then sv.auto = false end
		if type(sv.chatframe) ~= "boolean" then sv.chatframe = false end
		if type(sv.filterAddonMistakes) ~= "boolean" then sv.filterAddonMistakes = true end
		if type(sv.soundMedia) ~= "string" then sv.soundMedia = "BugSack: Fatality" end
		self.db = sv

		if media then
			media:Register("sound", "BugSack: Fatality", "Interface\\AddOns\\BugSack\\Media\\error.wav")
		end
	elseif event == "PLAYER_LOGIN" then
		-- Make sure we grab any errors fired before bugsack loaded.
		local session = self:GetErrors(BugGrabber:GetSessionId())
		if #session > 0 then self:OnError() end

		if self.RegisterComm then
			self:RegisterComm("BugSack", "OnBugComm")
		end

		-- Set up our error event handler
		BugGrabber.RegisterCallback(self, "BugGrabber_BugGrabbed", "OnError")
		BugGrabber.RegisterCallback(self, "BugGrabber_EventGrabbed", "OnError")

		if not self:GetFilter() then
			BugGrabber:RegisterAddonActionEvents()
		else
			BugGrabber:UnregisterAddonActionEvents()
		end
	end
end)
BugSack:RegisterEvent("ADDON_LOADED")
BugSack:RegisterEvent("PLAYER_LOGIN")

-- vim:set ts=4:
