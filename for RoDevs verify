local runService = game:GetService("RunService")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:wait()
local humanoid = character:WaitForChild("Humanoid")

local car

function newCharacter()
	character = player.Character
	humanoid = character:WaitForChild("Humanoid")
	
	humanoid.StateChanged:connect(function(old, new)
		if car and not (new == Enum.HumanoidStateType.Seated) then
			steerWheels(0)
			powerWheels(0)
			stopSounds()
			car = nil
		elseif not car and new == Enum.HumanoidStateType.Seated and humanoid.SeatPart and humanoid.SeatPart.Name == "DriveSeat" then
			car = humanoid.SeatPart.Parent
			runSounds()
		end
	end)
end
newCharacter()
player.CharacterAdded:connect(newCharacter)

--------------------------------[[ Runnung ]]------------------------------------

local lastSteer
function steerWheels(direction)
	if not car or not car.Parent or not car:FindFirstChild("SteerMotors") then return end
	lastSteer = tick()
	local thisSteer = lastSteer
	
	for _, folder in pairs(car.SteerMotors:GetChildren()) do
		local motor = folder.Motor.Value
		if motor then
			coroutine.resume(coroutine.create(function()	
				
				motor.DesiredAngle = car.Configuration.SteerAngle.Value * folder.DirectionFactor.Value * direction
				
				motor.MaxVelocity = 6 * car.Configuration.SteerVelocity.Value
				while car and (motor.DesiredAngle < 0 and motor.CurrentAngle > 0 or motor.DesiredAngle > 0 and motor.CurrentAngle < 0 
					and thisSteer == lastSteer and not (direction == 0)) do
					runService.RenderStepped:wait()
				end
				if thisSteer == lastSteer and car then
					motor.MaxVelocity = (direction == 0 and 2 or 1) * car.Configuration.SteerVelocity.Value
				end
				
			end))
		end
	end
end

function powerWheels(power)
	if not car or not car.Parent or not car:FindFirstChild("PowerWheels") then return end
	for _, folder in pairs(car.PowerWheels:GetChildren()) do
		local wheel = folder.Wheel.Value
		if wheel then
			wheel.BottomParamB = car.Configuration.MaxSpeed.Value * folder.DirectionFactor.Value * power
		end
	end
end



local throttle=0
local steer=0



function steerChanged()
	steerWheels(steer)
end


local lastThrottleChange=0
local currentPowerOutput = 0

function throttleChanged()
	local thisThrottleChange=tick()
	lastThrottleChange=thisThrottleChange
	
	local diffSign = (throttle - currentPowerOutput) / math.abs(throttle - currentPowerOutput) 
	
	local startThrottle = 0.3 * diffSign
	if math.abs(throttle) < 0.05 then
		startThrottle = 0
		throttle = 0
	elseif math.abs(throttle) < 0.4 then
		startThrottle = 0
	end
	

	for i = startThrottle, throttle, 0.008 * diffSign do	
		powerWheels(i)
		currentPowerOutput = i
	
		runService.RenderStepped:wait()
		
		if not(thisThrottleChange==lastThrottleChange) or not car then
			break
		end
	end
end

function runSounds()
	if car:FindFirstChild("RunSounds") then
		car.RunSounds:FireServer("Startup")
		wait(1)
		local currentPitch = car and (1 - car.Configuration.SoundPitchRange.MinValue) / (car.Configuration.SoundPitchRange.MaxValue - car.Configuration.SoundPitchRange.MinValue)
		while car do
			currentPitch = currentPitch + (math.abs(currentPowerOutput) - currentPitch) * 0.1
			car.RunSounds:FireServer("Set Pitch", currentPitch)
			wait()
		end
	end
end

function stopSounds()
	if car:FindFirstChild("RunSounds") then
		car.RunSounds:FireServer("Cut")
	end
end

--------------------------------[[ Bed network ownership ]]------------------------------------
local interactPermission = require(game.ReplicatedStorage.Interaction.InteractionPermission)


function setVehicleOwnership(seat, partList, networkOwnershipRequestList)	
	if not seat or partList and partList[seat] or seat.Parent:FindFirstChild("OwnershipOverride") then
		return
	end
	
	local thisIsFirstCall = networkOwnershipRequestList == nil
	networkOwnershipRequestList = networkOwnershipRequestList or {}
	
	partList = partList or {}
	partList[seat] = true
	
	--game.ReplicatedStorage.Interaction.ClientRequestOwnership:FireServer(seat)
	table.insert(networkOwnershipRequestList, seat)
	for _, wheel in pairs(getWheels(seat.Parent)) do
		--game.ReplicatedStorage.Interaction.ClientRequestOwnership:FireServer(wheel)

		table.insert(networkOwnershipRequestList, wheel)
	end
	
	local gottenBeds = {}
	local gottenParts = {}
	
	for _, part in pairs(seat:GetConnectedParts(true)) do
		
		if part.Parent then
			if part:FindFirstChild("HitchedTrailer") then
				if part.HitchedTrailer.Value and part.HitchedTrailer.Value.PrimaryPart then
					setVehicleOwnership(part.HitchedTrailer.Value.PrimaryPart, partList, networkOwnershipRequestList)
				else
					part.HitchedTrailer:Destroy()
				end
				for _, v in pairs(part:GetChildren()) do
					if v.Name == "HitchConnectionInstance" then
						if v.Value and v.Value.Parent then
							--game.ReplicatedStorage.Interaction.ClientRequestOwnership:FireServer(v.Value)
							table.insert(networkOwnershipRequestList, v.Value)
						else
							v:Destroy()
						end
					end
				end
			end
		
			for _, bed in pairs(part.Parent:GetChildren()) do			
				
				if bed.Name == "BedInfo" and not gottenBeds[bed] then		
					gottenBeds[bed] = true
	
					local centerPos = (seat.Parent.Main.CFrame * bed.CFrame.Value).p				
					local size = bed.Size.Value.magnitude * Vector3.new(1, 1, 1) * 0.6
					local regionCount = 2
					
					for x = 0, regionCount - 1 do
						for y = 0, regionCount - 1 do
							for z = 0, regionCount - 1 do
							
								local pos = centerPos - size
								local size = size / regionCount
								pos = pos + size * 2 * Vector3.new(x, y, z) + size
								
								local region = Region3.new(pos - size, pos + size)
								
								if game.ReplicatedStorage.OwnershipDebug.Value then
									game.ReplicatedStorage.OwnershipDebug.BedRegionDebug:FireServer(pos, size)
								end
							
								for _, v in pairs(workspace:FindPartsInRegion3(region, seat.Parent, 100)) do
									if not gottenParts[v] then
										gottenParts[v] = true
										
										local p = findHighestParent(v)
										if not v.Anchored and p and not p.Parent:IsA("Tool") and not (v.Name == "HitchButton") and interactPermission:UserCanInteract(player, p.Parent) then
											if not p.Parent:FindFirstChild("CarRequire") and not p.Parent:FindFirstChild("TrailerRequire") then
											--game.ReplicatedStorage.Interaction.ClientRequestOwnership:FireServer(v)
												table.insert(networkOwnershipRequestList, v)
											end
										end
									end
								end
								
							end
						end
					end
			
				end
			end
		end
	end

	if thisIsFirstCall then
		game.ReplicatedStorage.Interaction.ClientRequestOwnershipList:FireServer(networkOwnershipRequestList)
	end
end

script.SetVehicleOwnership.Event:connect(setVehicleOwnership)


function getWheels(parent, list)
	list = list or {}
	for _, v in pairs(parent:GetChildren()) do
		if v.Name == "Wheel" and v:IsA("BasePart") then
			table.insert(list, v)
		end
		getWheels(v, list)
	end
	return list
end


function findHighestParent(child)
	if not child or not child.Parent then
		return nil
	end
	if child.Parent:FindFirstChild("Owner") then
		return child
	elseif child.Parent == workspace or not child.Parent then
		return nil
	else
		return findHighestParent(child.Parent)
	end
end

--------------------------------[[ User Input ]]------------------------------------

wait(1)

local input = require(script.Parent.UserInput)

input.SteerChange(function(v)
	if car then
		steer = v
		steerChanged()
	end
end)

input.ThrottleChange(function(v)
	if car then
		throttle = v
		throttleChanged()
	end
end)

input.VehicleToggleLights(function()
	if car then
		local remote = car:FindFirstChild("LampRemote", true)
		if remote then
			game.ReplicatedStorage.Interaction.RemoteProxy:FireServer(remote)
		end
	end
end)
