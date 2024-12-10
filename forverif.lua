local player = game.Players.LocalPlayer
local Character = player.Character or game.Players.LocalPlayer.CharacterAdded:wait()
local originWalkSpeed = Character:WaitForChild("Humanoid").WalkSpeed

player.CharacterAdded:connect(function()
	Character = player.Character
end)

wait(1)

local selectButton = require(player:WaitForChild("PlayerGui"):WaitForChild("Scripts"):WaitForChild("SetSelectedButton"))

local PromptChatRemote = game.ReplicatedStorage.NPCDialog.PromptChat
local PlayerChattedRemote = game.ReplicatedStorage.NPCDialog.PlayerChatted
local setChatRemote = game.ReplicatedStorage.NPCDialog.SetChattingValue

local buttomBumper = require(script.Parent.Parent:WaitForChild("BumpButton"))

local NPCDialog = script.Parent:WaitForChild("NPCBillboard")
local UserChat = script.Parent:WaitForChild("Chat")
local PromptUserChat = script.Parent:WaitForChild("PromptChat")

local ChatOptionBackup = UserChat:WaitForChild("Choices"):WaitForChild("ChatChoice")
ChatOptionBackup.Parent = nil
local ChatOptionLineHeight = ChatOptionBackup.Size.Y.Offset

local responses = {}
local responseIndex = 1

local ChattingValue = game.Players.LocalPlayer:WaitForChild("IsChatting")
ChattingValue.Value = 0

local CurrentDialog = nil
local SelectedDialog = nil

local currentNPC = nil
local yielding = false

function PromptChat(active, NPC, dialog)
	
	if active and not (player.PlayerGui.MouseoverInteractionEngaged.Value or player.PlayerGui.IsPlacingStructure.Value or player.PlayerGui.ClientInfoIsOpen.Value or game.ReplicatedStorage.Notices.ClientNoticeIsOpen.Value) then
		setPlatformControls()
		SelectedDialog = dialog or NPC.Dialog
		NPCDialog.Adornee = NPC.Character.Head
		PromptUserChat.PromptText.Text = "Chat with "..NPC.Name
		setPromptVisibility(dialog == nil)
		currentNPC = NPC
		responseIndex = 1

		setChatting(1)
		if dialog then
			chatSelectionMade()
		end
	elseif not active and currentNPC and currentNPC.Character == NPC.Character then
		
		CurrentDialog = nil
		SelectedDialog = nil
		setPromptVisibility(false)
		setBillboardVisibility(false)
		setChatOptionsVisibility(false)
		currentNPC = nil
		setChatting(0)
		if not game.Players.LocalPlayer.IsBuyingLand.Value then
			Character.Humanoid.WalkSpeed = originWalkSpeed
			bindJump()
		end
		
		
		yielding = false
	end

	--
end

PromptChatRemote.OnClientEvent:connect(PromptChat)
for _, v in pairs({player.PlayerGui.MouseoverInteractionEngaged, player.PlayerGui.IsPlacingStructure, player.PlayerGui.ClientInfoIsOpen, game.ReplicatedStorage.Notices.ClientNoticeIsOpen}) do
	v.Changed:connect(function()
		if v.Value then
			PromptChat(false, currentNPC)
		end
	end)
end


player.PlayerGui.MouseoverInteractionEngaged.Changed:connect(function()
	if currentNPC and player.PlayerGui.MouseoverInteractionEngaged.Value then
		setPromptVisibility(false)
	elseif currentNPC and not player.PlayerGui.MouseoverInteractionEngaged.Value then
		setPromptVisibility(true)
	end
end)


function setChatting(v)
	setChatRemote:InvokeServer(v)
end
setChatting(0)


local lastAdvanceTick
function advanceChat()
	lastAdvanceTick = tick()
	local thisAdvanceTick = lastAdvanceTick
	setBillboardVisibility(false)
	setPromptVisibility(false)
	setChatOptionsVisibility(false)

	if not CurrentDialog then
		PromptChat(false, currentNPC)
		return
	end
	Character.Humanoid.WalkSpeed = 0
	unbindjump()
	setChatting(2)
	
	wait(0.1)

	if not CurrentDialog then
		if lastAdvanceTick == thisAdvanceTick then
			PromptChat(false, currentNPC)
		end
		return
	end
	NPCDialog.Text.Text = CurrentDialog.ResponseDialog
	
	setBillboardVisibility(true)
	
	wait(1.5)
	
	if not CurrentDialog then
		if lastAdvanceTick == thisAdvanceTick then
			PromptChat(false, currentNPC)
		end
		return
	end
	
	if ChattingValue.Value==0 then
		yielding = false
		chatSelectionMade()
		return
	end
	
	responses = {}
	responseIndex = 1
	local ommitGoodbyeExit = false
	
	
	for _, response in pairs(CurrentDialog:GetChildren()) do
		if response:IsA("DialogChoice") then
			local newChoice = {}
			newChoice.DialogObject = response
			newChoice.Button = ChatOptionBackup:clone()
			newChoice.Button.Text = response.UserDialog
			table.insert(responses,newChoice)
		elseif response.Name == "OmmitGoodbyeExit" then
			ommitGoodbyeExit = true
		end
	end

	
	local firstResponse = nil
	
	if #responses >= 1 then
		if not ommitGoodbyeExit then
			local exitChoice = {}
			exitChoice.Button = ChatOptionBackup:clone()
			exitChoice.Button.Text = "Goodbye!"
			table.insert(responses,exitChoice)
		end

		UserChat.Position = UDim2.new(0, 100, 1, -80 - 50 * #responses)
	
		for index, response in pairs(responses) do
			response.Button.Position = UDim2.new(0, 0, 0, (index - 1) * ChatOptionLineHeight)
			response.Button.Parent = UserChat.Choices
			
			response.Button.MouseButton1Click:connect(function()
				responseIndex = index
				SelectedDialog = response.DialogObject
				chatSelectionMade()
			end)
			
			firstResponse = firstResponse or response.Button
		end
	
		selectButton(firstResponse)
		
		
		UserChat.Size = UDim2.new(0, UserChat.Size.X.Offset, 0, #responses * ChatOptionLineHeight)
		setChatOptionsVisibility(true)
		
		--setPlatformControls()
		--wait(0.4)
		
		chatSelectionScroll(0)
	else
		SelectedDialog = nil
		yielding = false
		chatSelectionMade()
	end

	yielding = false
end



function chatSelectionMade()
		
	--[[print("Chat condition a: "..tostring(player.PlayerGui.IsPlacingStructure.Value)) 
	print("Chat condition b: "..tostring(player.PlayerGui.ClientInfoIsOpen.Value)) 
	print("Chat condition c: "..tostring(player.PlayerGui.MouseoverInteractionEngaged.Value))
	print("Chat condition d: "..tostring(ChattingValue.Value))
	print("Chat condition e: "..tostring(SelectedDialog))
	print("Chat condition f: "..tostring(yielding))
	print()]]
	
	
	if ChattingValue.Value > 0 and SelectedDialog and not yielding and not (player.PlayerGui.MouseoverInteractionEngaged.Value or player.PlayerGui.IsPlacingStructure.Value or player.PlayerGui.ClientInfoIsOpen.Value) then
		yielding = true
		if not CurrentDialog then
			SelectedDialog = PlayerChattedRemote:InvokeServer(currentNPC, "Initiate") or SelectedDialog
			if not buttomBumper.Bump(PromptUserChat) then
				return
			end
		else
			SelectedDialog = PlayerChattedRemote:InvokeServer(currentNPC, SelectedDialog.Name) or SelectedDialog
			if responses[responseIndex] then
				if not buttomBumper.Bump(responses[responseIndex].Button) then
					return
				end
			end
		end
		CurrentDialog = SelectedDialog
		advanceChat()
	elseif ChattingValue.Value > 0 and not yielding then
		if responses[responseIndex] then
			if not buttomBumper.Bump(responses[responseIndex].Button) then
				return
			end
		end 
			
		yielding = true
		CurrentDialog = nil
		SelectedDialog = nil
		
		if currentNPC then
			PlayerChattedRemote:InvokeServer(currentNPC, "EndChat")
		end
		advanceChat() 
	end
end

PromptUserChat.MouseButton1Click:connect(chatSelectionMade) --Just for initial prompt


function chatSelectionScroll(v)
	if ChattingValue.Value == 0 or #responses < 1 then return end
	responseIndex = responseIndex + v
	if responseIndex < 1 then
		responseIndex = #responses
	elseif responseIndex > #responses then
		responseIndex = 1
	end
	
	SelectedDialog = responses[responseIndex].DialogObject
	
	for _, v in pairs(responses) do
		--v.Button.BackgroundTransparency = 1
		v.Button.Text = " "..v.Button.Text.." "
	end

end

function setPlatformControls()
	if input.IsGamePadEnabled() then
		PromptUserChat.PlatformButton.Image = PromptUserChat.PlatformButton.Gamepad.Value
		PromptUserChat.PlatformButton.KeyLabel.Text = ""
	else
		PromptUserChat.PlatformButton.Image = PromptUserChat.PlatformButton.PC.Value
		PromptUserChat.PlatformButton.KeyLabel.Text = "E"
		--[[PromptUserChat.PlatformButton.Image = ""
		UserChat.PlatformButton.Image = ""
		PromptUserChat.PlatformButton.KeyLabel.Text = ""
		UserChat.PlatformButton.KeyLabel.Text = ""]]
	end
end

--------------------------------[[ Other selection capture ]]------------------------------------

local selectedButton = script.Parent.Parent.Scripts.SetSelectedButton.SelectedButton

selectedButton.Changed:connect(function()
	if  ChattingValue.Value > 0 then
		if not selectedButton.Value or not selectedButton.Value:IsDescendantOf(script.Parent) then
			SelectedDialog = nil
			chatSelectionMade()
		end
	end
end)


--------------------------------[[ Transitions ]]------------------------------------

function setPromptVisibility(v)
	PromptUserChat.Visible = v
end

function setBillboardVisibility(v)
	NPCDialog.Enabled = v
end

function setChatOptionsVisibility(v)
	UserChat.Visible = v
	if not v then
		for _, response in pairs(UserChat.Choices:GetChildren()) do
			response:Destroy()
		end
	end
end

--------------------------------[[ User Input ]]------------------------------------



local contextActionService = game:GetService("ContextActionService")

function bindJump()
	--[[local function jump()
		local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.Jump = true
		end
	end
	contextActionService:BindAction("jumpAction", jump, false, Enum.PlayerActions.CharacterJump)]]
end

function unbindjump()
	--[[contextActionService:UnbindAction("jumpAction")
		
	--]]
end


wait(1)

input = require(script.Parent.Parent.Scripts.UserInput)

input.InteractSelectionMade(function ()
	if ChattingValue.Value == 1 then
		chatSelectionMade()
	end
end)
--input.InteractSelectionScroll(chatSelectionScroll)
