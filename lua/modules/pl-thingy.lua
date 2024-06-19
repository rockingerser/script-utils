if getgenv().__z_pl_admin_running__ then
	return
end

getgenv().__z_pl_admin_running__ = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Teams = game:GetService("Teams")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local NetworkClient = game:GetService("NetworkClient")
local AdminScreenGui = Instance.new("ScreenGui")
local AdminCmdBox = Instance.new("TextBox")
local AdminRoundCorners = Instance.new("UICorner")
local AdminStroke = Instance.new("UIStroke")
local AdminPadding = Instance.new("UIPadding")
local SpoofIndicatorPart = Instance.new("Part")
local SpoofIndicatorPartOutline = Instance.new("SelectionBox")
local RayPartBullet = Instance.new("Part")
local Remote = workspace.Remote
local PrisonItems = workspace.Prison_ITEMS
local Doors = workspace.Doors
local CarContainer = workspace.CarContainer
local Player = Players.LocalPlayer
local TeamEvent = Remote.TeamEvent
local GotArrested = Remote.arrestPlayer
local Arrest = Remote.arrest
local ItemHandler = Remote.ItemHandler
local ShootEvent = ReplicatedStorage.ShootEvent
local ReloadEvent = ReplicatedStorage.ReloadEvent
local SoundEvent = ReplicatedStorage.SoundEvent
local MeleeEvent = ReplicatedStorage.meleeEvent
local ReplicateBullets = ReplicatedStorage.ReplicateEvent
local ChatEvent = ReplicatedStorage.DefaultChatSystemChatEvents
local SayMessage = ChatEvent.SayMessageRequest
local Guards = Teams.Guards
local Inmates = Teams.Inmates
local Neutral = Teams.Neutral
local Criminals = Teams.Criminals
local CriminalSpawn = workspace["Criminals Spawn"]:FindFirstChildOfClass("SpawnLocation")
local RandGen = Random.new()
local SpoofsOrder = {}
local Spoofs = {}
local SpoofsNames = {}
local VelSpoofsOrder = {}
local VelSpoofs = {}
local VelSpoofsNames = {}
local KillingPlayers = {}
local FlingingPlayers = {}
local ArrestingPlayers = {}
local DrawingQueue = {}
local Turrets = {}
local LocalCharacter = nil
local LocalHumanoid = nil
local LocalRoot = nil
local CopyTeamEv = nil
local AntikillEnabled = false
local AntiarrestEnabled = false
local InvisibleEnabled = false
local InfiniteJumpEnabled = false
local TouchFlingEnabled = false
local FreezingServer = false
local LaggingEveryone = false
local SpamEnabled = false
local SpammingSounds = false
local RestoringState = false
local InfiniteYieldLoaded = false
local DexLoaded = false
local Secret =  HttpService:GenerateGUID()
local NeonTxtIns = nil
local SpamSentences = nil
local TargetBillboardTextPlayer = nil
local FlyLinearVel = nil
local FlyVecForce = nil
local FlyAttachment = nil
local FlyAttachment2 = nil
local FlySpeed = 60
local FlyBindName = HttpService:GenerateGUID()
local BiggestNumber = 3e15
local InvisiblePriority = 99
local InvisibleTouchFlingPriority = 150
local FlingPlayersPosPriority = 1800
local ArrestPriority = 2100
local TpKillPriority = 2400
local GetCarPriority = 2700
local GetItemPriority = 3000
local TouchFlingPriority = 99
local FlingPlayersVelPriority = 1500
local PistolName = "M9"
local TaserName = "Taser"
local ShotgunName = "Remington 870"
local AkName = "AK-47"
local KnifeName = "Crude Knife"
local HammerName = "Hammer"
local KeyCardName = "Key card"
local OtherGunThatBehavesLikeTheAkName = "M4A1"
local DrawCurrGun = PistolName
local BulletName = "RayPart"
local ChattedDebounce = false
local FlingForce = 1500
local DrawYield = .24
local CarSpawners = {}
local SpamSounds = {}
local Npcs = {}
local SpamDrawings = nil
local NumDraws = 0
local DrawingBullets = false
local JailLocations = {
	CFrame.new(-321, 84, 2046),
	CFrame.new(711, 102, 2373)
}
local TargetList = {
	Killing = {},
	PendingNuke = {},
	Oneshot = {},
	NoGuns = {},
	LoopKilling = {}
}
local DefaultState = {
	pistol = false,
	--taser = false,
	shotgun = false,
	ak = false,
	knife = false,
	hammer = false,
	keycard = false,
	otherGunThatBehavesLikeTheAk = false, -- Funny name. Is actually  the M4A1
	equippedTool = nil,
	cframe = nil,
	team = Inmates
}


local LookAlikes = {
	A = "Α",
	B = "Β",
	C = "Ϲ",
	D = "Ԁ",
	E = "Ε",
	F = "Ϝ",
	G = "Ԍ",
	H = "Η",
	I = "Ι",
	J = "Ј",
	K = "Κ",
	L = "Ꮮ",
	M = "Μ",
	N = "Ν",
	O = "Ο",
	P = "Ρ",
	Q = "Ϙ",
	R = "Ꭱ",
	S = "Ѕ",
	T = "Τ",
	U = "Ս",
	V = "Ѵ",
	W = "Ԝ",
	X = "Χ",
	Y = "Υ",
	Z = "Ζ",
	a = "ɑ",
	b = "Ь",
	c = "ϲ",
	d = "ԁ",
	e = "е",
	f = "ғ",
	g = "ɡ",
	h = "һ",
	i = "і",
	j = "ϳ",
	k = "κ",
	l = "I",
	m = "м",
	n = "ɴ",
	o = "ο",
	p = "р",
	q = "ԛ",
	r = "г",
	s = "ѕ",
	t = "τ",
	u = "υ",
	v = "ѵ",
	w = "ѡ",
	x = "х",
	y = "у",
	z = "ᴢ"
}

local CurrentState = DefaultState
local LaggingServer = false
local TimeRefresh = math.huge
local ServerLagRatio = 6

RayPartBullet.BrickColor = BrickColor.new("Cyan")
RayPartBullet.Material = Enum.Material.Neon
RayPartBullet.Transparency = .5
RayPartBullet.CanCollide = false
RayPartBullet.Anchored = true

coroutine.wrap(function()
	task.wait(12)
	NeonTxtIns = loadstring(game:HttpGet("https://raw.githubusercontent.com/rockingerser/script-utils/main/lua/modules/pl-neon-text.lua"))().new()
	NeonTxtIns.TextSize = 1.5
end)()

for _, Spawner in ipairs(PrisonItems.buttons:GetChildren()) do
	if Spawner.Name == "Car Spawner" then
		table.insert(CarSpawners, Spawner["Car Spawner"])
	end
end

for _, Door in ipairs(Doors:GetChildren()) do
	--table.insert(SpamSounds, { Door.scn.cardScanner.Sound })
end

AdminScreenGui.Name = HttpService:GenerateGUID()
AdminScreenGui.DisplayOrder = -1

AdminCmdBox.Name = HttpService:GenerateGUID()
AdminCmdBox.Position = UDim2.new(.5, 0, 0, 30)
AdminCmdBox.Size = UDim2.fromOffset(300, 30)
AdminCmdBox.PlaceholderText = "Type a command (!)"
AdminCmdBox.TextXAlignment = Enum.TextXAlignment.Left
AdminCmdBox.TextSize = 15
AdminCmdBox.BackgroundColor3 = Color3.new(1, 1, 1)
AdminCmdBox.ShowNativeInput = true
AdminCmdBox.ClearTextOnFocus = false
AdminCmdBox.AnchorPoint = Vector2.new(.5, 0)

AdminRoundCorners.Name = HttpService:GenerateGUID()
AdminRoundCorners.CornerRadius = UDim.new(0, 3)

AdminStroke.Name = HttpService:GenerateGUID()
AdminStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

AdminPadding.Name = HttpService:GenerateGUID()
AdminPadding.PaddingLeft = UDim.new(0, 9)

SpoofIndicatorPart.Name = HttpService:GenerateGUID()
SpoofIndicatorPart.Anchored = true
SpoofIndicatorPart.Size = Vector3.new(2, 2, 1)
SpoofIndicatorPart.CanCollide = false
SpoofIndicatorPart.Transparency = 1

SpoofIndicatorPartOutline.Name = HttpService:GenerateGUID()
SpoofIndicatorPartOutline.Adornee = SpoofIndicatorPart

SpoofIndicatorPartOutline.Parent = AdminScreenGui
AdminPadding.Parent = AdminCmdBox
AdminStroke.Parent = AdminCmdBox
AdminRoundCorners.Parent = AdminCmdBox
AdminCmdBox.Parent = AdminScreenGui
SpoofIndicatorPart.Parent = workspace

-- Import some admin modules
local CommandVM = loadstring(game:HttpGet("https://raw.githubusercontent.com/rockingerser/script-utils/main/lua/modules/admin-cmd-vm.lua"), true)()
local Parser = loadstring(game:HttpGet("https://raw.githubusercontent.com/rockingerser/script-utils/main/lua/modules/admin-cmd-parser.lua"), true)()

local vm = CommandVM.new()
local parser = Parser.new(vm)

-- Import basic commands
loadstring(game:HttpGet("https://raw.githubusercontent.com/rockingerser/script-utils/main/lua/modules/stdcmds.lua"), true)()(vm)

function Bypass(text)
	local out = ""
	for Start, End in utf8.graphemes(text) do
		local Char = text:sub(Start, End)
		out = out..(if LookAlikes[Char] then LookAlikes[Char] else Char)
	end
	return out
end

function Chat(msg, bigtext, channel)
	local OutMsg = msg

	if bigtext then
		OutMsg = ""
		for Start, End in utf8.graphemes(msg) do
			OutMsg = OutMsg..msg:sub(Start, End)..if End - Start < 2 then "̲" else ""
		end
	end

	SayMessage:FireServer(if typeof(channel) == "Instance" and channel:IsA("Player") then "/w "..channel.Name.." "..OutMsg else OutMsg, if typeof(channel) == "string" then channel else "All")
end

function CreateDummy(Size)
	local Character = Instance.new("Model")
	local Humanoid = Instance.new("Humanoid")
	local Animator = Instance.new("Animator")
	local Head = Instance.new("Part")
	local RightArm = Instance.new("Part")
	local LeftArm = Instance.new("Part")
	local Torso = Instance.new("Part")
	local HumanoidRootPart = Instance.new("Part")
	local RightLeg = Instance.new("Part")
	local LeftLeg = Instance.new("Part")
	local RootJoint = Instance.new("Motor6D")
	local Neck = Instance.new("Motor6D")
	local RightShoulder = Instance.new("Motor6D")
	local LeftShoulder = Instance.new("Motor6D")
	local RightHip = Instance.new("Motor6D")
	local LeftHip = Instance.new("Motor6D")

	Character.Name = HttpService:GenerateGUID()

	Humanoid.RigType = Enum.HumanoidRigType.R6
	Humanoid.HipHeight = 1

	Animator.Parent = Humanoid

	Head.Name = "Head"
	Head.Position = Vector3.new(0, 1.5 * Size, 0)
	Head.Size = Vector3.one * Size
	Head.Transparency = 1
	Head.Parent = Character

	RightArm.Name = "Right Arm"
	RightArm.Position = Vector3.new(1.5 * Size, 0, 0)
	RightArm.Size = Vector3.new(1, 2, 1) * Size
	RightArm.Transparency = 1
	RightArm.Parent = Character

	LeftArm.Name = "Left Arm"
	LeftArm.Position = Vector3.new(-1.5 * Size, 0, 0)
	LeftArm.Size = Vector3.new(1, 2, 1) * Size
	LeftArm.Transparency = 1
	LeftArm.Parent = Character

	Torso.Name = "Torso"
	Torso.Size = Vector3.new(2, 2, 1) * Size
	Torso.Transparency = 1
	Torso.Parent = Character

	HumanoidRootPart.Name = "HumanoidRootPart"
	HumanoidRootPart.Size = Vector3.new(2, 2, 1) * Size
	HumanoidRootPart.Transparency = 1
	HumanoidRootPart.Parent = Character
	Character.PrimaryPart = HumanoidRootPart

	RightLeg.Name = "Right Leg"
	RightLeg.Position = Vector3.new(.5, -2, 0) * Size
	RightLeg.Size = Vector3.new(1, 2, 1) * Size
	RightLeg.Transparency = 1
	RightLeg.Parent = Character

	LeftLeg.Name = "Left Leg"
	LeftLeg.Size = Vector3.new(1, 2, 1) * Size
	LeftLeg.Transparency = 1
	LeftLeg.Parent = Character

	RootJoint.Name = "Root Joint"
	RootJoint.Part0 = HumanoidRootPart
	RootJoint.Part1 = Torso
	RootJoint.Parent = HumanoidRootPart

	Neck.Name = "Neck"
	Neck.Part0 = Torso
	Neck.Part1 = Head
	Neck.C0 = CFrame.new(0, Size, 0)
	Neck.C1 = CFrame.new(0, -.5 * Size, 0)
	Neck.Parent = Torso

	RightShoulder.Name = "Right Shoulder"
	RightShoulder.Part0 = Torso
	RightShoulder.Part1 = RightArm
	RightShoulder.C0 = CFrame.new(Size, Size, 0)
	RightShoulder.C1 = CFrame.new(-.5 * Size, Size, 0)
	RightShoulder.Parent = Torso

	LeftShoulder.Name = "Left Shoulder"
	LeftShoulder.Part0 = Torso
	LeftShoulder.Part1 = LeftArm
	LeftShoulder.C0 = CFrame.new(-Size, Size, 0)
	LeftShoulder.C1 = CFrame.new(.5 * Size, Size, 0)
	LeftShoulder.Parent = Torso

	RightHip.Name = "Right Hip"
	RightHip.Part0 = Torso
	RightHip.Part1 = RightLeg
	RightHip.C0 = CFrame.new(Size, -Size, 0)
	RightHip.C1 = CFrame.new(.5 * Size, Size, 0)
	RightHip.Parent = Torso

	LeftHip.Name = "Left Hip"
	LeftHip.Part0 = Torso
	LeftHip.Part1 = LeftLeg
	LeftHip.C0 = CFrame.new(-Size, -Size, 0)
	LeftHip.C1 = CFrame.new(-.5 * Size, Size, 0)
	LeftHip.Parent = Torso

	Humanoid.Parent = Character

	return Character
end

function NpcRandomWalk(Humanoid)
	Humanoid:Move(CFrame.Angles(0, RandGen:NextNumber(-math.pi, math.pi), 0).LookVector)
	task.wait(.9)
	Humanoid:Move(Vector3.zero)
end

function NpcSeatedAction(Humanoid)
	task.wait(RandGen:NextNumber(0, 6))
	Humanoid.Jump = true
end

function NpcDefaultAction(Humanoid)
	NpcRandomWalk(Humanoid)
end

function NpcRandomAction(Humanoid)
	local State = Humanoid:GetState()

	if State == Enum.HumanoidStateType.Dead then
		return RunService.PostSimulation:Wait()
	end

	if State == Enum.HumanoidStateType.Seated then
		return NpcSeatedAction(Humanoid)
	end

	NpcDefaultAction(Humanoid)
end

function NpcDefaultBehavior(Humanoid)
	local Character = Humanoid.Parent
	for _, Part in ipairs(Character:GetChildren()) do
		if Part:IsA("BasePart") then
			Part.Touched:Connect(function(Hit)
				if Hit.Name == BulletName then
					Humanoid:TakeDamage(9)
					Hit.CanTouch = false
				end
			end)
		end
	end
end

function JeffTheKillerStep(Humanoid)
	local Closest = 300
	local TargetRoot = nil
	local TargetHum = nil

	for _, player in ipairs(Players:GetPlayers()) do
	end
end

function WaitFirst(...)
	local Event = Instance.new("BindableEvent")
	local Events = {}

	for _, event in ipairs({...}) do
		table.insert(Events,
		event:Connect(function(...)
			for _, EventTarget in ipairs(Events) do
				EventTarget:Disconnect()
			end

			Event:Fire(event, ...)
			Event:Destroy()
		end))
	end

	return Event.Event:Wait()
end

function SaveState()
	if RestoringState then
		return CurrentState
	end

	CurrentState = {
		pistol = Player.Team ~= Guards and GetToolInBackpack(PistolName) ~= nil,
		shotgun = GetToolInBackpack(ShotgunName) ~= nil,
		ak = GetToolInBackpack(AkName) ~= nil,
		knife = GetToolInBackpack(KnifeName) ~= nil,
		hammer = GetToolInBackpack(HammerName) ~= nil,
		keycard = false,
		otherGunThatBehavesLikeTheAk = false,
		equippedTool = LocalCharacter:FindFirstChildOfClass("Tool"),
		team = Player.Team
	}

	if LocalRoot.Position.Y > workspace.FallenPartsDestroyHeight then
		CurrentState.cframe = LocalRoot.CFrame
	end
	
	return CurrentState
end



function RestoreState(NoRespawn)
	if CurrentState.team == Neutral or Player.Team == Neutral then
		return
	end

	RestoringState = true

	if CurrentState.team == Criminals and not NoRespawn then
		local ShouldSwitchToGuards = #Guards:GetPlayers() < 8
		if ShouldSwitchToGuards then
			SwitchToTeam(Guards, true)
		end
		if Player.Team ~= Guards or not ShouldSwitchToGuards then
			SwitchToTeam(Inmates, true)
			--print("pe")
		end
	end

	if not NoRespawn then
		SwitchToTeam(CurrentState.team, CurrentState.team ~= Criminals or Player.Team ~= Inmates)
	end
	print(CurrentState.team)
	
	local Root = Player.Character:WaitForChild("HumanoidRootPart")
	LocalRoot = Root

	if CurrentState.pistol then
		coroutine.wrap(GetItem)(PistolName)
	end
	if CurrentState.shotgun then
		coroutine.wrap(GetItem)(ShotgunName)
	end
	if CurrentState.ak then
		coroutine.wrap(GetItem)(AkName)
	end
	if CurrentState.knife then
		coroutine.wrap(GetItem)(KnifeName)
	end
	if CurrentState.hammer then
		coroutine.wrap(GetItem)(HammerName)
	end

	Player.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.GettingUp)

	if CurrentState.cframe then
		local cframe = CurrentState.cframe
		local OldTime = os.clock()
		repeat
			if (Root.Position - cframe.Position).Magnitude > 15 then
				Root.CFrame = cframe
			end
			RunService.PreSimulation:Wait()
		until os.clock() - OldTime > .21
	end

	RestoringState = false
end

function InvalidPlayer(player)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return true
	end
	return false
end

function SpoofPosition(Name, Priority, Value)
	if SpoofsNames[Name] ~= nil then
		SpoofsNames[Name].value = Value
		return
	end

	local IndexOrder = 1

	for _, OtherPriority in ipairs(SpoofsOrder) do
		if Priority < OtherPriority then
			IndexOrder += 1
			continue
		end
		break
	end

	table.insert(SpoofsOrder, IndexOrder, Priority)
	local SpoofData = {
		priority = Priority,
		value = Value
	}

	table.insert(Spoofs, IndexOrder, SpoofData)
	SpoofsNames[Name] = SpoofData
end

function SpoofVelocity(Name, Priority, Value)
	if VelSpoofsNames[Name] ~= nil then
		VelSpoofsNames[Name].value = Value
		return
	end

	local IndexOrder = 1

	for _, OtherPriority in ipairs(SpoofsOrder) do
		if Priority < OtherPriority then
			IndexOrder += 1
			continue
		end
		break
	end

	table.insert(VelSpoofsOrder, IndexOrder, Priority)
	local SpoofData = {
		priority = Priority,
		value = Value
	}

	table.insert(VelSpoofs, IndexOrder, SpoofData)
	VelSpoofsNames[Name] = SpoofData
end

function TpCar(Car, Cframe)
	Car.WorldPivot = LocalRoot.CFrame
	Car:PivotTo(Cframe)
end

function SitInCar(CarModel)
	local Body = CarModel:WaitForChild("Body", 3)
	if Body == nil then
		return false
	end
	local VehicleSeat = Body:WaitForChild("VehicleSeat", 3)
	if VehicleSeat == nil then
		return false
	end

	while CarModel.Parent == CarContainer and VehicleSeat.Occupant == nil and not VehicleSeat:GetAttribute("Used") do
		firetouchinterest(LocalRoot, VehicleSeat, 0)
		firetouchinterest(LocalRoot, VehicleSeat, 1)
		RunService.PostSimulation:Wait()
	end

	if VehicleSeat.Occupant == LocalHumanoid then
		VehicleSeat:SetAttribute("Used", true)
		return true
	end
	return false
end

function CarGetFreeSeats(Car)
	local Seats = {}
	for _, Seat in ipairs(Car:WaitForChild("Body"):GetChildren()) do
		if Seat:IsA("Seat") and Seat.Occupant == nil then
			table.insert(Seats, Seat)
		end
	end
	return Seats
end

function GetCar(callback)
	if LocalHumanoid:GetState() == Enum.HumanoidStateType.Seated then
		LocalHumanoid:ChangeState(Enum.HumanoidStateType.Running)
	end

	if typeof(callback) ~= "function" then
		callback = function(Car, OldCFrame)
			TpCar(Car, OldCFrame)
			task.wait(.15)
			LocalHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end

	local OldCFrame

	for _, Car in ipairs(CarContainer:GetChildren()) do
		OldCFrame = LocalRoot.CFrame
		if SitInCar(Car) then
			return callback(Car, OldCFrame)
		end
	end

	local CarSpawned, SpawnCarEvent = nil, nil
	local SpawnCar = Instance.new("BindableEvent")

	CarSpawned = CarContainer.ChildAdded:Connect(function(Car)
		if SitInCar(Car) then
			CarSpawned:Disconnect()
			SpawnCarEvent:Disconnect()
			return callback(Car, OldCFrame)
		end
		SpawnCar:Fire()
	end)

	SpawnCarEvent = SpawnCar.Event:Connect(function()
		for _, Spawner in ipairs(CarSpawners) do
			if Spawner.BrickColor.Name == "Cyan" then
				OldCFrame = LocalRoot.CFrame
				SpoofPosition("getcartask", GetCarPriority, Spawner.CFrame)
				repeat
					if LocalHumanoid:GetState() == Enum.HumanoidStateType.Seated then
						LocalHumanoid:ChangeState(Enum.HumanoidStateType.Running)
					end
					ItemHandler:InvokeServer(Spawner)
				until Spawner.BrickColor.Name == "Deep blue"
				return UnspoofPosition("getcartask")
			end
		end
	end)

	SpawnCar:Fire()
end

function SitPlayerInCar(player, callback)
	if InvalidPlayer(player) then
		return
	end

	if typeof(callback) ~= "function" then
		callback = function() end
	end
	GetCar(function(Car, OldCFrame)
		local TargetRoot = GetCharLimb("HumanoidRootPart", false, player)
		local TargetHum = GetCharLimb("Humanoid", false, player)
		if TargetRoot and TargetHum then
			local FreeSeats = CarGetFreeSeats(Car)
			local OldTime = os.clock()
			workspace.CurrentCamera.CameraSubject = TargetHum
			repeat
				TpCar(Car, TargetRoot.CFrame * CFrame.Angles(
					RandGen:NextNumber(-math.pi, math.pi),
					RandGen:NextNumber(-math.pi, math.pi),
					RandGen:NextNumber(-math.pi, math.pi)
				))
				RunService.PostSimulation:Wait()
			until TargetHum.SeatPart and table.find(FreeSeats, TargetHum.SeatPart) or os.clock() - OldTime > 3
			return callback(Car, OldCFrame, if table.find(FreeSeats, TargetHum.SeatPart) then TargetHum else nil)
		end

		callback(Car, OldCFrame, nil)
	end)
end

function JailPlayer(player)
	SitPlayerInCar(player, function(Car, OldCFrame)
		TpCar(Car, JailLocations[RandGen:NextInteger(1, #JailLocations)])
		task.wait(.15)
		LocalHumanoid.Sit = false
		LocalRoot.CFrame = OldCFrame
	end)
end

function VoidPlayer(player)
	SitPlayerInCar(player, function(Car, OldCFrame)
		TpCar(Car, CFrame.new(BiggestNumber, BiggestNumber, BiggestNumber))
		task.wait(.15)
		LocalHumanoid.Sit = false
		LocalRoot.CFrame = OldCFrame
	end)
end

function CarKillPlayer(player)
	SitPlayerInCar(player, function(_, OldCFrame, SeatedHum)
		TpCar(Car, CFrame.new(BiggestNumber, workspace.FallenPartsDestroyHeight + 9, BiggestNumber))
		task.wait(.15)
		LocalHumanoid.Sit = false
		LocalRoot.CFrame = OldCFrame
	end)
end

function UnspoofPosition(Name)
	if SpoofsNames[Name] == nil then
		return
	end

	local SpoofToRemove = SpoofsNames[Name]
	local IndexOrder = table.find(Spoofs, SpoofToRemove)

	table.remove(SpoofsOrder, IndexOrder)
	table.remove(Spoofs, IndexOrder)
	SpoofsNames[Name] = nil
end

function UnspoofVelocity(Name)
	if VelSpoofsNames[Name] == nil then
		return
	end

	local SpoofToRemove = VelSpoofsNames[Name]
	local IndexOrder = table.find(VelSpoofs, SpoofToRemove)

	table.remove(VelSpoofsOrder, IndexOrder)
	table.remove(VelSpoofs, IndexOrder)
	VelSpoofsNames[Name] = nil
end

function Draw3D(Data)
	local ShouldBeginDraw = #DrawingQueue == 0
	for _, Bullet in ipairs(Data) do
		table.insert(DrawingQueue, Bullet)
	end

	if ShouldBeginDraw and not DrawingBullets then
		DrawingBullets = true
		coroutine.wrap(function()
			while true do
				while GetToolInBackpack(DrawCurrGun) == nil do
					GetItem(DrawCurrGun)
				end

				local Gun = GetToolInBackpack(DrawCurrGun)

				for _, Bullet in ipairs(DrawingQueue) do
					if Bullet.Cframe and Bullet.Distance then
						local RayPart = RayPartBullet:Clone()
						RayPart.CFrame = Bullet.Cframe
						RayPart.Size = Vector3.new(.12, .12, Bullet.Distance)
						RayPart.Parent = workspace.Terrain
					end
				end
				ShootEvent:FireServer(DrawingQueue, Gun)

				-- Prevent lagging the server
				if NumDraws % 15 == 14 then
					ReloadEvent:FireServer(Gun)
					if DrawCurrGun == PistolName then
						DrawCurrGun = AkName
					else
						DrawCurrGun = PistolName
					end
				end

				NumDraws += 1
				table.clear(DrawingQueue)
				task.wait(DrawYield)

				workspace.Terrain:ClearAllChildren()

				if #DrawingQueue == 0 then
					DrawingBullets = false
					break
				end
			end
		end)()
	end
end

function Draw3DGenerateBlock(Cframe, Size)
	local HalfSize = Size / 2
	return {
		{
			RayObject = Ray.new(Vector3.zero, Vector3.zero),
			Distance = Size.X,
			Cframe = Cframe * CFrame.new(0, HalfSize.Y, HalfSize.Z) * CFrame.Angles(0, math.pi / 2, 0)
		},
		{
			RayObject = Ray.new(Vector3.zero, Vector3.zero),
			Distance = Size.X,
			Cframe = Cframe * CFrame.new(0, -HalfSize.Y, HalfSize.Z) * CFrame.Angles(0, math.pi / 2, 0)
		},
		{
			RayObject = Ray.new(Vector3.zero, Vector3.zero),
			Distance = Size.X,
			Cframe = Cframe * CFrame.new(0, HalfSize.Y, -HalfSize.Z) * CFrame.Angles(0, math.pi / 2, 0)
		},
		{
			RayObject = Ray.new(Vector3.zero, Vector3.zero),
			Distance = Size.X,
			Cframe = Cframe * CFrame.new(0, -HalfSize.Y, -HalfSize.Z) * CFrame.Angles(0, math.pi / 2, 0)
		},
		
		{
			RayObject = Ray.new(Vector3.zero, Vector3.zero),
			Distance = Size.Z,
			Cframe = Cframe * CFrame.new(HalfSize.X, HalfSize.Y, 0)
		},
		{
			RayObject = Ray.new(Vector3.zero, Vector3.zero),
			Distance = Size.Z,
			Cframe = Cframe * CFrame.new(HalfSize.X, -HalfSize.Y, 0)
		},

		{
			RayObject = Ray.new(Vector3.zero, Vector3.zero),
			Distance = Size.Z,
			Cframe = Cframe * CFrame.new(-HalfSize.X, HalfSize.Y, 0)
		},
		{
			RayObject = Ray.new(Vector3.zero, Vector3.zero),
			Distance = Size.Z,
			Cframe = Cframe * CFrame.new(-HalfSize.X, -HalfSize.Y, 0)
		},

		{
			RayObject = Ray.new(Vector3.zero, Vector3.zero),
			Distance = Size.Y,
			Cframe = Cframe * CFrame.new(HalfSize.X, 0, HalfSize.Z) * CFrame.Angles(math.pi / 2, 0, 0)
		},
		{
			RayObject = Ray.new(Vector3.zero, Vector3.zero),
			Distance = Size.Y,
			Cframe = Cframe * CFrame.new(-HalfSize.X, 0, HalfSize.Z) * CFrame.Angles(math.pi / 2, 0, 0)
		},

		{
			RayObject = Ray.new(Vector3.zero, Vector3.zero),
			Distance = Size.Y,
			Cframe = Cframe * CFrame.new(HalfSize.X, 0, -HalfSize.Z) * CFrame.Angles(math.pi / 2, 0, 0)
		},
		{
			RayObject = Ray.new(Vector3.zero, Vector3.zero),
			Distance = Size.Y,
			Cframe = Cframe * CFrame.new(-HalfSize.X, 0, -HalfSize.Z) * CFrame.Angles(math.pi / 2, 0, 0)
		}
	}
end

function Draw3DBullet(From, To, Hit)
	return {
		{
			RayObject = Ray.new(Vector3.zero, Vector3.zero),
			Distance = (From - To).Magnitude,
			Cframe = CFrame.lookAt(
				From:Lerp(To, .5),
				To,
				Vector3.yAxis
			),
			Hit = Hit
		}
	}
end

function Draw3DOutlineCharacter(Character)
	local Out = {}

	for _, Part in ipairs(Character:GetChildren()) do
		if Part:IsA("BasePart") and Part.Name ~= "HumanoidRootPart" then
			for _, Bullet in ipairs(Draw3DGenerateBlock(Part.CFrame, Part.Size)) do
				table.insert(Out, Bullet)
			end
		end
	end

	return Out
end

function HasLethalTools(player)
	local Tools = { player.Character:FindFirstChildOfClass("Tool") }

	for _, Tool in ipairs(player.Backpack:GetChildren()) do
		table.insert(Tools, Tool)
	end

	for _, Lethal in ipairs(Tools) do
		print(Lethal)
		if Lethal.Name == PistolName or Lethal.Name == ShotgunName or Lethal.Name == AkName or Lethal.Name == OtherGunThatBehavesLikeTheAkName or Lethal.Name == KnifeName or Lethal.Name == HammerName then
			return true
		end
	end

	return false
end

function CharacterAdded(NewCharacter)
	local player = Players:GetPlayerFromCharacter(NewCharacter)
	local Humanoid = NewCharacter:WaitForChild("Humanoid")
	local Root = NewCharacter:WaitForChild("HumanoidRootPart")
	local Head = NewCharacter:WaitForChild("Head")
	local Backpack = player:WaitForChild("Backpack")
	local MySounds = {}
	local Tools = {}
	local SpoofsOldCFrame = nil
	local SpoofsOldVel = nil
	local Arrested = false
	local HealthChanged = nil
	local NoGunsCheck = nil
	local RootSoundAdded = nil


	local function ToolSoundAdded(Sound)
		if Humanoid:GetState() ~= Enum.HumanoidStateType.Dead and Sound:IsA("Sound") and Sound:FindFirstAncestorOfClass("Tool") and Sound:FindFirstAncestorOfClass("Tool").Name == KeyCardName then
			local SoundArg = {
				Sound,
				Sound:FindFirstAncestorOfClass("Tool")
			}

			table.insert(MySounds, SoundArg)
			table.insert(SpamSounds, SoundArg)
		end
	end

	Humanoid.Died:Once(function()
		HealthChanged:Disconnect()
		NoGunsCheck:Disconnect()
		RootSoundAdded:Disconnect()

		if PassCheck(player, TargetList.PendingNuke) then
			KillPlayers(Players:GetPlayers())
		end

		for _, Sound in ipairs(MySounds) do
			table.remove(SpamSounds, table.find(SpamSounds, Sound))
		end

		if player == Player and AntikillEnabled then
			SaveState()
			if Arrested then
				player.CharacterAdded:Wait()
			end
			RestoreState()
		end
	end)

	HealthChanged = Humanoid.HealthChanged:Connect(function()
		if PassCheck(player, TargetList.Oneshot) then
			KillPlayers(player)
		end
	end)
	NoGunsCheck = Backpack.ChildAdded:Connect(function(Gun)
		if table.find(Tools, Gun) == nil then
			table.insert(Tools, Gun)
			for _, Des in ipairs(Gun:GetDescendants()) do
				ToolSoundAdded(Des)
			end
			Gun.DescendantAdded:Connect(ToolSoundAdded)
		end

		if player.Team ~= Guards and PassCheck(player, TargetList.NoGuns) and HasLethalTools(player) then
			KillPlayers(player)
		end
	end)

	for _, Tool in ipairs(Backpack:GetChildren()) do
		table.insert(Tools, Tool)
		for _, Des in ipairs(Tool:GetDescendants()) do
			ToolSoundAdded(Des)
		end
		Tool.DescendantAdded:Connect(ToolSoundAdded)
	end

	ToolSoundAdded(Head:WaitForChild("punchSound"))

	for _, Sound in ipairs(Root:GetChildren()) do
		ToolSoundAdded(Sound)
	end

	RootSoundAdded = Root.ChildAdded:Connect(ToolSoundAdded)

	if player ~= Player then
		return
	end

	LocalCharacter = NewCharacter
	LocalHumanoid = Humanoid
	LocalRoot = Root

	local SpoofServer = RunService.PostSimulation:Connect(function()
		local SpoofsCurrent = Spoofs[1]
		local VelSpoofsCurrent = VelSpoofs[1]

		SpoofIndicatorPartOutline.Transparency = 1
		if SpoofsCurrent then
			SpoofsOldCFrame = Root.CFrame
			SpoofIndicatorPartOutline.Transparency = 0
			SpoofIndicatorPartOutline.Color3 = Color3.fromHSV(os.clock() % 1, 1, 1)
			SpoofIndicatorPart.CFrame = SpoofsCurrent.value
			Root.CFrame = SpoofsCurrent.value
		end
		if VelSpoofsCurrent then
			SpoofsOldVel = Root.AssemblyLinearVelocity
			Root.AssemblyLinearVelocity = VelSpoofsCurrent.value
		end
	end)

	RunService:BindToRenderStep(Secret, 198, function()
		if SpoofsOldCFrame then
			Root.CFrame = SpoofsOldCFrame
			SpoofsOldCFrame = nil
		end
		if SpoofsOldVel then
			Root.AssemblyLinearVelocity = SpoofsOldVel
			SpoofsOldVel = nil
		end
	end)

	Root.Touched:Connect(function(Hit)
		local TargetPlayer = Players:GetPlayerFromCharacter(Hit.Parent)
		if TouchFlingEnabled and InvisibleEnabled and TargetPlayer then
			FlingPlayers(TargetPlayer)
		end
	end)

	GotArrested.OnClientEvent:Once(function()
		if AntiarrestEnabled then
			Arrested = true
			--SaveState()
			Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
			--Player.CharacterAdded:Wait()
			--RestoreState()
		end
	end)

	coroutine.wrap(function()
		WaitFirst(Humanoid.Died, player.CharacterRemoving)

		SpoofServer:Disconnect()
		RunService:UnbindFromRenderStep(Secret)
	end)()
end

function PlayerAdded(NewPlayer)
	NewPlayer.CharacterAdded:Connect(CharacterAdded)
	if NewPlayer.Character then
		CharacterAdded(NewPlayer.Character)
	end
end

function GetCharacter(Wait, TargetPlayer)
	TargetPlayer = TargetPlayer or Player
	if not TargetPlayer.Character and Wait then
		return Player.CharacterAdded:Wait()
	end
	return TargetPlayer.Character
end

function GetCharLimb(Name, Wait, TargetPlayer)
	TargetPlayer = TargetPlayer or Player
	if Wait then
		while GetCharacter(false, TargetPlayer) == nil or GetCharacter(false, TargetPlayer):FindFirstChild(Name) == nil do
			RunService.PostSimulation:Wait()
		end
	end

	local Char = GetCharacter(false, TargetPlayer)
	if Char == nil then
		return
	end

	return Char:FindFirstChild(Name)
end

function GetToolInBackpack(ToolName, player)
	player = player or Player
	local Character = player.Character
	if Character and Character:FindFirstChild(ToolName) then
		return Character[ToolName]
	end
	if Player:FindFirstChild("Backpack") then
		return Player.Backpack:FindFirstChild(ToolName)
	end
end

function SwitchToTeam(Team, Yield)
	if Team == Criminals then
		local Step = RunService.PostSimulation:Connect(function()
			local Head = LocalCharacter:FindFirstChild("Head")
			if Head and LocalCharacter.Parent == workspace then
				firetouchinterest(Head, CriminalSpawn, 0)
				firetouchinterest(Head, CriminalSpawn, 1)
			end
		end)

		if Yield then
			if Player.Team == Inmates then
				Player:GetPropertyChangedSignal("TeamColor"):Wait()
			else
				Player.CharacterAdded:Wait()
			end
		else
			RunService.PostSimulation:Wait()
		end

		Step:Disconnect()

		return
	end

	if Team ~= Guards and Team ~= Inmates and Team ~= Neutral then
		return
	end

	TeamEvent:FireServer(Team.TeamColor.Name)
	if Yield then
		if Team == Guards and Player.Team ~= Team and #Guards:GetPlayers() < 8 then
			local Event = Instance.new("BindableEvent")
			local TeamPlAdded, CharAdded  = nil, nil


			TeamPlAdded = Guards.PlayerAdded:Connect(function(player)
				if player == Player then
					return TeamPlAdded:Disconnect()
				end
				if #Guards:GetPlayers() == 8 then
					Event:Fire()
					TeamPlAdded:Disconnect()
					CharAdded:Disconnect()
				end
			end)

			CharAdded = Player.CharacterAdded:Connect(function()
				Event:Fire()
				TeamPlAdded:Disconnect()
				CharAdded:Disconnect()
			end)

			Event.Event:Wait()
			Event:Destroy()
			return
		end

		if Team ~= Guards or Player.Team == Team then
			Player.CharacterAdded:Wait()
		end
	end
end

function KillMyself()
	local Humanoid = GetCharLimb("Humanoid")
	if Humanoid == nil then
		return
	end
	Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
end

function GetItem(ItemName)
	if Player:FindFirstChild("Backpack") == nil or Player.Team == Guards and (ItemName == KnifeName or ItemName == HammerName) then
		RunService.PostSimulation:Wait()
		return
	end
	local Item = (
		PrisonItems.giver:FindFirstChild(ItemName) or
		PrisonItems.single[ItemName]
	).ITEMPICKUP
	local Character = GetCharacter()

	if Character == nil then
		RunService.PostSimulation:Wait()
		return
	end

	local Root = Character:FindFirstChild("HumanoidRootPart")
	local Humanoid = Character:FindFirstChild("Humanoid")

	if Root == nil or Humanoid == nil then
		RunService.PostSimulation:Wait()
		return
	end

	SpoofPosition("getitemtask"..ItemName, GetItemPriority, Item.CFrame)
	while Player.Backpack:FindFirstChild(ItemName) == nil and Character.Parent == workspace and Item:IsDescendantOf(workspace) do
		ItemHandler:InvokeServer(Item)
	end
	RunService.PostSimulation:Wait()
	UnspoofPosition("getitemtask"..ItemName)
end

function GunKillPlayers(players, taser)
	--[[if Player.Team ~= Criminals then
		SwitchToTeam(Criminals, true)
	end]]

	local Gun
	local Shoots = {}
	local ShouldReset = false
	local NumHits = if taser then
		1
	else
		6

	if taser then
		if Player.Team ~= Guards then
			SaveState()
			SwitchToTeam(Guards, true)
			ShouldReset = true
		end
		if Player.Team ~= Guards then
			return
		end
		Player:WaitForChild("Backpack"):WaitForChild("Taser")
	else
		while GetToolInBackpack(PistolName) == nil do
			GetItem(PistolName)
		end
	end
	Gun = GetToolInBackpack(
		if taser then
			"Taser"
		else
			PistolName
	)

	for _, player in ipairs(players) do
		local TargetHumanoid = GetCharLimb("Humanoid", false, player)
		local TargetHead = GetCharLimb("Head", false, player)

		if TargetHead and TargetHumanoid and TargetHumanoid:GetState() ~= Enum.HumanoidStateType.Dead then
			for i = 0, NumHits do
				table.insert(Shoots, {
					RayObject = Ray.new(Vector3.zero, Vector3.zero),
					Distance = 1024,
					Cframe = TargetHead.CFrame * CFrame.Angles(
						RandGen:NextNumber(0, math.pi * 2),
						RandGen:NextNumber(0, math.pi * 2),
						RandGen:NextNumber(0, math.pi * 2)
					) * CFrame.new(0, 0, 512),
					Hit = TargetHead
				})
			end
		end
	end

	ShootEvent:FireServer(Shoots, Gun)
	ReloadEvent:FireServer(Gun)

	if ShouldReset then
		RestoreState()
	end
end

function TpKillPlayers(players)
	if #KillingPlayers == 0 then
		for _, player in ipairs(players) do
			table.insert(KillingPlayers, player)
		end
		
		repeat
			local TargetPlayer = table.remove(KillingPlayers, 1)
			print(TargetPlayer)
			local TargetCharacter = TargetPlayer.Character

			if TargetCharacter == nil then
				continue
			end
			local TargetHumanoid = TargetCharacter:FindFirstChild("Humanoid")
			local TargetRoot = TargetCharacter:FindFirstChild("HumanoidRootPart")
			if TargetHumanoid == nil or TargetRoot == nil then
				continue
			end

			while TargetCharacter.Parent == workspace and TargetRoot:IsDescendantOf(workspace) and TargetHumanoid:GetState() ~= Enum.HumanoidStateType.Dead do
				SpoofPosition("tpkilltask", TpKillPriority, TargetRoot.CFrame)
				for i = 0, 9 do
					MeleeEvent:FireServer(TargetPlayer)
				end
				RunService.PostSimulation:Wait()
			end
			RunService.PostSimulation:Wait()
		until #KillingPlayers == 0
		UnspoofPosition("tpkilltask")
		return
	end
	for _, player in ipairs(players) do
		table.insert(KillingPlayers, players)
	end
end

function KillPlayers(players, IsAList)
	local ArraySameTeamPlayers = {}
	local ArrayOtherTeamPlayers = {}
	local ShouldKillMyself = false


	players = if IsAList then
		GetPlayersFromTargetList(players)
	else
		Insert({}, players)

	for _, player in ipairs(players) do
		if player == Player then
			ShouldKillMyself = true
			continue
		end
		if player.Team == Neutral then
			continue
		end
		table.insert(if player.Team == Player.Team then ArraySameTeamPlayers else ArrayOtherTeamPlayers, player)
	end

	if #ArraySameTeamPlayers > 0 then
		TpKillPlayers(ArraySameTeamPlayers)
	end
	if #ArrayOtherTeamPlayers > 0 then
		GunKillPlayers(ArrayOtherTeamPlayers)
	end
	if ShouldKillMyself then
		LocalHumanoid:ChangeState(Enum.HumanoidStateType.Dead)
	end
end

function Insert(Table, playersOrT)
	if typeof(playersOrT) ~= "table" then
		playersOrT = {
			[1] = playersOrT
		}
	end

	local ProcessedPlayers = {}

	if typeof(Table.Players) ~= "table" then
		Table.Players = {}
	end

	if typeof(Table.Teams) ~= "table" then
		Table.Teams = {}
	end

	for _, playerOrT in pairs(playersOrT) do
		if typeof(playerOrT) ~= "Instance" then
			continue
		end
		if playerOrT:IsA("Player") and table.find(Table.Players, playerOrT) == nil then
			table.insert(Table.Players, playerOrT)
			table.insert(ProcessedPlayers, playerOrT)
		elseif playerOrT:IsA("Team") and table.find(Table.Teams, playerOrT) == nil then
			table.insert(Table.Teams, playerOrT)
			for _, player in ipairs(playerOrT:GetPlayers()) do
				if table.find(ProcessedPlayers, player) then
					continue
				end
				table.insert(ProcessedPlayers, player)
			end
		end
	end

	return ProcessedPlayers
end

function Remove(Table, playersOrT)
	if typeof(playersOrT) ~= "table" then
		playersOrT = {
			[1] = playersOrT
		}
	end

	local ProcessedPlayers = {}

	if typeof(Table.Players) ~= "table" then
		Table.Players = {}
	end

	if typeof(Table.Teams) ~= "table" then
		Table.Teams = {}
	end

	for _, playerOrT in pairs(playersOrT) do
		if typeof(playerOrT) ~= "Instance" then
			continue
		end
		if playerOrT:IsA("Player") and table.find(Table.Players, playerOrT) then
			table.remove(Table.Players, table.find(Table.Players, playerOrT))
			table.insert(ProcessedPlayers, playerOrT)
		elseif playerOrT:IsA("Team") and table.find(Table.Teams, playerOrT) then
			table.remove(Table.Teams, table.find(Table.Teams, playerOrT))
			for _, player in ipairs(playerOrT:GetPlayers()) do
				if table.find(ProcessedPlayers, player) then
					continue
				end
				table.insert(ProcessedPlayers, player)
			end
		end
	end

	return ProcessedPlayers
end

function PassCheck(player, Table)
	if Table.Teams and table.find(Table.Teams, player.Team) or Table.Players and table.find(Table.Players, player) then
		return true
	end
	return false
end

function GetPlayersFromTargetList(Table)
	local players = {}

	if Table.Players then
		for _, player in ipairs(Table.Players) do
			table.insert(players, player)
		end
	end

	if Table.Teams then
		for _, team in ipairs(Table.Teams) do
			for _, player in ipairs(team:GetPlayers()) do
				table.insert(players, player)
			end
		end
	end

	return players
end

function AddNuke(players)
	Insert(TargetList.PendingNuke, players)
end

function RemoveNuke(players)
	Remove(TargetList.PendingNuke, players)
end

function OneshotPlayers(players)
	Insert(TargetList.Oneshot, players)
end

function UnoneshotPlayers(players)
	Remove(TargetList.Oneshot, players)
end

function NoGunsPlayers(players)
	Insert(TargetList.NoGuns, players)
end

function UnNoGunsPlayers(players)
	Remove(TargetList.NoGuns, players)
end

function LoopkillPlayers(players)
	Insert(TargetList.LoopKilling, players)
end

function BillboardTextPlayer(player, text)
	if NeonTxtIns == nil then
		return
	end
	
	TargetBillboardTextPlayer = player
	NeonTxtIns.Text = text
end

coroutine.wrap(function()
		while true do
			task.wait(DrawYield)
			if typeof(TargetBillboardTextPlayer) ~= "Instance" or not TargetBillboardTextPlayer:IsA("Player") then
				continue
			end
			local TargetCharacter = TargetBillboardTextPlayer.Character
			if TargetCharacter == nil then
				continue
			end
			local TargetHead = TargetCharacter:FindFirstChild("Head")
			if TargetHead == nil then
				continue
			end
			NeonTxtIns.CFrame = TargetHead.CFrame * CFrame.new(0, 3, 0)
			pcall(NeonTxtIns.Render, NeonTxtIns)
			Draw3D(NeonTxtIns.RenderedBullets)
		end
end)()

function UnLoopkillPlayers(players)
	Remove(TargetList.LoopKilling, players)
end

function Invisible()
	InvisibleEnabled = true
	repeat
		SpoofPosition("i'm invisible", InvisiblePriority, CFrame.new(
			RandGen:NextNumber(-BiggestNumber, BiggestNumber),
			RandGen:NextNumber(-3, BiggestNumber),
			RandGen:NextNumber(-BiggestNumber, BiggestNumber)
		))
		RunService.PreSimulation:Wait()
	until not InvisibleEnabled
	UnspoofPosition("i'm invisible")
end

function Visible()
	InvisibleEnabled = false
end

function Antikill()
	AntikillEnabled = true
end

function Unantikill()
	AntikillEnabled = false
end

function Antiarrest()
	AntiarrestEnabled = true
end

function Unantiarrest()
	AntiarrestEnabled = false
end

function Team(Team)
	if Player.Team == Inmates and LocalHumanoid:GetState() == Enum.HumanoidStateType.Dead then
		SwitchToTeam(Inmates, true)
	end
	SaveState()
	SwitchToTeam(Team, true)
	RestoreState(true)
end

function InfJump()
	InfiniteJumpEnabled = true
end

function UninfJump()
	InfiniteJumpEnabled = false
end

function GotoPlayer(player)
	if InvalidPlayer(player) or GetCharLimb(player, false, "HumanoidRootPart") then
		return
	end
	LocalRoot.CFrame = player.Character.HumanoidRootPart.CFrame
end

function InfiniteYield()
	if InfiniteYieldLoaded then
		return
	end
	InfiniteYieldLoaded = true
	loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"), true)()
end

function Dex()
	if DexLoaded then
		return
	end
	DexLoaded = true
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV3.lua"), true)()
end

function Spam(PmSpam)
	if SpamEnabled then
		return
	end
	SpamEnabled = true

	if SpamSentences == nil then
		SpamSentences = HttpService:JSONDecode(game:HttpGet("https://raw.githubusercontent.com/rockingerser/script-utils/main/json/sentences.json"))
		table.insert(SpamSentences, Bypass("\99\117\109"))
		table.insert(SpamSentences, Bypass("\98\111\111\98\115"))
		table.insert(SpamSentences, Bypass("\112\111\114\110"))
	end

	if SpamDrawings == nil then
		SpamDrawings = HttpService:JSONDecode(game:HttpGet("https://raw.githubusercontent.com/rockingerser/script-utils/main/json/drawings.json"))
	end



	repeat
		local players = Players:GetPlayers()
		local player = if PmSpam then players[RandGen:NextInteger(1, #players)] else nil

		if RandGen:NextInteger(0, 3) == 0 then
			task.wait(15)
			if not SpamEnabled then
				break
			end

			local Drawing = SpamDrawings[RandGen:NextInteger(1, #SpamDrawings)]

			for _, Line in ipairs(Drawing) do
				Chat(Line, false, player)
				task.wait()
			end

			continue
		end

		for i = 0, 7 do
			Chat(SpamSentences[RandGen:NextInteger(1, #SpamSentences)], true, player)
			task.wait(.6)
		end
		task.wait(15)
	until not SpamEnabled
end

function Unspam()
	SpamEnabled = false
end

function GetGuns()
	coroutine.wrap(GetItem)(PistolName)
	GetItem(ShotgunName)
	GetItem(AkName)
	GetItem(KnifeName)
	GetItem(HammerName)
end

function Sus()
	GetGuns()
	local Pistol = GetToolInBackpack(PistolName)
	local Shotgun = GetToolInBackpack(ShotgunName)
	local Ak = GetToolInBackpack(AkName)
	local Hammer = GetToolInBackpack(HammerName)
	local Knife = GetToolInBackpack(KnifeName)

	--[[Pistol.Parent = Player.Backpack
	Shotgun.Parent = Player.Backpack
	Ak.Parent = Player.Backpack]]

	Pistol.Grip = CFrame.new(1, 2, 0)
	Shotgun.Grip = CFrame.new(1, 2, 2.7)
	Ak.Grip = CFrame.new(1, 2, 7.2)

	if Hammer then
		Hammer.Grip = CFrame.Angles(math.pi / 2, 0, 0) * CFrame.new(1, 1.8, 12.1)
		Knife.Grip = CFrame.Angles(math.pi / 2, 0, 0) CFrame.new(1, 2, 14.1)
		
		Hammer.Parent = LocalCharacter
		Knife.Parent = LocalCharacter
	end

	Pistol.Parent = LocalCharacter
	Shotgun.Parent = LocalCharacter
	Ak.Parent = LocalCharacter
end

function TazePlayers(players)
	local ActualPlayers = Insert({}, players)
	local TazeablePlayers = {}

	for _, player in ipairs(ActualPlayers) do
		if player.Team == Guards or player == Player then
			continue
		end
		table.insert(TazeablePlayers, player)
	end

	GunKillPlayers(TazeablePlayers, true)
end

function ArrestPlayers(players)
	local PlayersToArrest = Insert({}, players)
	local ShouldBeginArrest = #ArrestingPlayers == 0

	for _, player in ipairs(PlayersToArrest) do
		if table.find(ArrestingPlayers, player) or player.Team == Guards then
			continue
		end
		table.insert(ArrestingPlayers, player)
	end

	if ShouldBeginArrest then
		while #ArrestingPlayers > 0 do
			local TargetPlayer = table.remove(ArrestingPlayers, 1)
			local TargetHead = GetCharLimb("Head", true, TargetPlayer)

			local ArrestStep = RunService.PreSimulation:Connect(function()
				SpoofPosition("arrestplayertask", ArrestPriority, TargetHead.CFrame)
				Arrest:InvokeServer(TargetHead)
			end)

			TargetHead:WaitForChild("handcuffedGui", 3)
			ArrestStep:Disconnect()
		end
		UnspoofPosition("arrestplayertask")
	end
end

function TouchFling()
	if TouchFlingEnabled then
		return
	end
	TouchFlingEnabled = true
	
	repeat
		SpoofVelocity("touchflingtask", TouchFlingPriority, CFrame.Angles(0, RandGen:NextNumber(-math.pi, math.pi), 0):VectorToWorldSpace(Vector3.new(0, 60, FlingForce)))
		RunService.PostSimulation:Wait()
	until not TouchFlingEnabled

	UnspoofVelocity("touchflingtask")
end

function UntouchFling()
	TouchFlingEnabled = false
end

function FreezeServer()
	NetworkClient:SetOutgoingKBPSLimit(999999999)
	
	while GetToolInBackpack(AkName) == nil do
		GetItem(AkName)
	end

	local Ak = GetToolInBackpack(AkName)

	ReloadEvent:FireServer(Ak)
	for i = 0, 9999 do
		ShootEvent:FireServer({}, Ak)
	end
end

function LagServer()
	LaggingServer = true
end

function UnlagServer()
	LaggingServer = false
end

function FlingPlayers(players)
	local ShouldBeginFling = #FlingingPlayers == 0
	local PlayersToFling = Insert({}, players)

	for _, player in ipairs(PlayersToFling) do
		if table.find(FlingingPlayers, player) then
			continue
		end
		table.insert(FlingingPlayers, player)
	end

	if ShouldBeginFling then
		repeat
			local TargetPlayer = table.remove(FlingingPlayers, 1)
			local TargetRoot = GetCharLimb("HumanoidRootPart", false, TargetPlayer)
			local TargetHum = GetCharLimb("Humanoid", false, TargetPlayer)
			local OldTime = os.clock()

			if TargetRoot == nil or TargetHum == nil then
				continue
			end

			repeat
				if TargetHum:GetState() == Enum.HumanoidStateType.FallingDown or TargetHum:GetState() == Enum.HumanoidStateType.Dead or not TargetRoot:IsDescendantOf(workspace) then
					break
				end

				local TargetRootVel = TargetRoot.AssemblyLinearVelocity.Magnitude * 1.5

				SpoofVelocity("flingplayertask", FlingPlayersVelPriority, CFrame.Angles(0, RandGen:NextNumber(-math.pi, math.pi), 0):VectorToWorldSpace(Vector3.new(0, 60, FlingForce)))
				SpoofPosition("flingplayertask", FlingPlayersPosPriority, CFrame.new(TargetRoot.Position + TargetHum.MoveDirection * RandGen:NextNumber(TargetRootVel * .3, TargetRootVel)) * CFrame.Angles(
					RandGen:NextNumber(-math.pi, math.pi),
					RandGen:NextNumber(-math.pi, math.pi),
					RandGen:NextNumber(-math.pi, math.pi)
				))

				RunService.PreSimulation:Wait()
			until os.clock() - OldTime > 2.1
		until #FlingingPlayers == 0

		UnspoofPosition("flingplayertask")
		UnspoofVelocity("flingplayertask")
	end
end

function AnnoyingSounds()
	if SpammingSounds then
		return
	end

	local SoundConnections = getconnections(SoundEvent.OnClientEvent)
	local SoundNum = 0

	SpammingSounds = true

	NetworkClient:SetOutgoingKBPSLimit(999999)
	repeat
		if #SpamSounds == 0 then
			RunService.PostSimulation:Wait()
			continue
		end

		local Sound = SpamSounds[SoundNum % #SpamSounds + 1]

		for _, Connection in pairs(SoundConnections) do
			Connection:Fire(unpack(Sound))
		end

		SoundEvent:FireServer(unpack(Sound))
		SoundNum += 1

		if SoundNum % 300 == 3 then
			task.wait(.6)
		end
	until not SpammingSounds
end

function UnannoyingSounds()
	SpammingSounds = false
end

function CreateTurret(Name)
	RemoveTurret(Name)

	local RangeDetector = Instance.new("Part")
	RangeDetector.Name = HttpService:GenerateGUID(false)
	RangeDetector.Size = Vector3.one * 300
	RangeDetector.CanCollide = false
	RangeDetector.Anchored = true
	RangeDetector.Transparency = 1
	RangeDetector.Shape = Enum.PartType.Ball
	RangeDetector.CFrame = LocalRoot.CFrame
	RangeDetector.Parent = workspace

	Turrets[Name or RangeDetector.Name] = {
		RangeDetector,
		os.clock(),
		0
	}
end

function RemoveTurret(Name)
	if Turrets[Name] then
		Turrets[Name][1]:Destroy()
		Turrets[Name] = nil
	end
end

function RemoveTurrets()
	for Name in pairs(Turrets) do
		RemoveTurret(Name)
	end
end

function CreateNpc(Size, Name)
	RemoveNpc(Name)

	Name = Name or HttpService:GenerateGUID()

	local Character = CreateDummy(Size or 1)
	local Humanoid = Character.Humanoid

	Npcs[Name] = {
		Character
	}

	Character.Parent = workspace
	Character:PivotTo(LocalRoot.CFrame * CFrame.new(0, 5, 0))

	Humanoid.Died:Once(function()
		task.wait(3)
		RemoveNpc(Name)
	end)

	NpcDefaultBehavior(Humanoid)
	while Character.Parent == workspace do
		task.wait(.9)
		NpcRandomAction(Humanoid)
	end
end

function RemoveNpc(Name)
	if Npcs[Name] == nil then
		return
	end

	Npcs[Name][1]:Destroy()
	Npcs[Name] = nil
end

function RemoveNpcs()
	for NpcName in pairs(Npcs) do
		RemoveNpc(NpcName)
	end
end

function AntiLag()
	for _, Connection in pairs(getconnections(ReplicateBullets.OnClientEvent)) do
		Connection:Disable()
	end
	for _, Connection in pairs(getconnections(SoundEvent.OnClientEvent)) do
		Connection:Disable()
	end
end

function UnantiLag()
	for _, Connection in pairs(getconnections(ReplicateBullets.OnClientEvent)) do
		Connection:Enable()
	end
	for _, Connection in pairs(getconnections(SoundEvent.OnClientEvent)) do
		Connection:Enable()
	end
end

function SetDrawTime(NewTime)
	if typeof(NewTime) == "number" then
		NewTime = math.clamp(NewTime, .09, 6)
		DrawYield = NewTime
	end
end

function ChatBypass(msg)
	Chat(Bypass(msg))
end

function CopyTeam(player)
	Team(player.Team)
end

function LoopCopyTeam(player)
	UnloopCopyTeam()
	CopyTeam(player)
	CopyTeamEv = player:GetPropertyChangedSignal("TeamColor"):Connect(function()
		CopyTeam(player)
	end)
end

function UnloopCopyTeam()
	if CopyTeamEv == nil or not CopyTeamEv.Connected then
		return
	end
	CopyTeamEv:Disconnect()
end

function NetOwner()
	for _, player in ipairs(Players:GetPlayers()) do
		if player == Player then
			sethiddenproperty(player, "MaxSimulationRadius", 1000)
			sethiddenproperty(player, "SimulationRadius", 1000)
			continue
		end

		sethiddenproperty(player, "MaxSimulationRadius", .01)
		sethiddenproperty(player, "MaxSimulationRadius", .01)
	end
end

function Fly(Speed)
	Unfly()
	SetFlySpeed(Speed)

	FlyLinearVel = Instance.new("LinearVelocity")
	FlyVecForce = Instance.new("VectorForce")
	FlyAttachment = Instance.new("Attachment")
	FlyAttachment2 = Instance.new("Attachment")

	local Root = GetCharLimb("HumanoidRootPart", true)
	local Humanoid = GetCharLimb("Humanoid", true)

	FlyLinearVel.Name = HttpService:GenerateGUID()
	FlyLinearVel.Attachment0 = FlyAttachment
	FlyLinearVel.RelativeTo = Enum.ActuatorRelativeTo.World
	FlyVecForce.Attachment0 = FlyAttachment2
	FlyVecForce.ApplyAtCenterOfMass = true
	FlyVecForce.RelativeTo = Enum.ActuatorRelativeTo.World

	FlyVecForce.Name = HttpService:GenerateGUID()
	FlyAttachment.Name = HttpService:GenerateGUID()
	FlyAttachment2.Name = HttpService:GenerateGUID()

	FlyLinearVel.Parent = GetCharacter()
	FlyVecForce.Parent = GetCharacter()
	FlyAttachment.Parent = Root
	FlyAttachment2.Parent = Root

	RunService:BindToRenderStep(FlyBindName, 150, function()
		local Camera = workspace.CurrentCamera
		local MovVector = Camera.CFrame:VectorToObjectSpace(Humanoid.MoveDirection)
		local BackVector = -Camera.CFrame.LookVector
		local RightVector = Camera.CFrame.RightVector
		local AssemblyMass = Root.AssemblyMass

		-- Prevent auto-flinging yourself when seated on anchored seats
		if Root:IsGrounded() then
			AssemblyMass = 0
		end

		Root.CFrame = CFrame.new(Root.CFrame.Position) * Camera.CFrame.Rotation

		FlyLinearVel.VectorVelocity = (BackVector * MovVector.Z + RightVector * MovVector.X) * FlySpeed
		FlyVecForce.Force = Vector3.new(0, AssemblyMass * workspace.Gravity, 0)

		if Humanoid.SeatPart == nil then
			Humanoid.PlatformStand = true
		end
	end)

	Player.CharacterAdded:Once(function()
		if FlyLinearVel == nil then
			return
		end
		Fly(FlySpeed)
	end)
end

function Unfly()
	if FlyLinearVel then
		FlyLinearVel:Destroy()
		FlyLinearVel = nil
	end

	if FlyVecForce then
		FlyVecForce:Destroy()
		FlyVecForce = nil
	end

	if FlyAttachment then
		FlyAttachment:Destroy()
		FlyAttachment = nil
	end

	if FlyAttachment2 then
		FlyAttachment2:Destroy()
		FlyAttachment2 = nil
	end

	RunService:UnbindFromRenderStep(FlyBindName)
	LocalHumanoid.PlatformStand = false
end

function SetFlySpeed(NewSpeed)
	if typeof(NewSpeed) == "number" then
		FlySpeed = NewSpeed
	end
end

coroutine.wrap(function()
	while task.wait(DrawYield) do
		for _, Turret in pairs(Turrets) do
			local ShootStart = Turret[1].CFrame * CFrame.new(0, 3.75, 0)
			local Delta = os.clock() - Turret[2]
			Turret[2] = os.clock()
			Turret[3] += Delta

			Draw3D(Draw3DGenerateBlock(Turret[1].CFrame, Vector3.new(3, 5, 3)))
			Draw3D(Draw3DGenerateBlock(ShootStart, Vector3.new(2, 2.5, 2)))

			while Turret[3] > .9 do
				Turret[3] -= .9
				for _, Part in ipairs(workspace:GetPartsInPart(Turret[1])) do
					if Part.Name ~= "Torso" then
						continue
					end
					local TargetPlayer = Players:GetPlayerFromCharacter(Part.Parent)

					if TargetPlayer and TargetPlayer.Team ~= Player.Team then
						local Params = RaycastParams.new()
						Params.RespectCanCollide = true
						Params.FilterType = Enum.RaycastFilterType.Exclude
						Params.FilterDescendantsInstances = {
							Part.Parent
						}

						if workspace:Raycast(ShootStart.Position, Part.Position - ShootStart.Position, Params) then
							continue
						end

						Draw3D(Draw3DBullet(
							ShootStart.Position,
							Part.Position,
							Part
						))
					end
				end
			end
		end

		for Name, Npc in pairs(Npcs) do
			Draw3D(Draw3DOutlineCharacter(Npc[1]))
		end
	end
end)()

Players.PlayerAdded:Connect(PlayerAdded)
UserInputService.JumpRequest:Connect(function()
	if InfiniteJumpEnabled then
		LocalHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

vm:CreateCommand({
	name = "kill",
	callback = KillPlayers,
	args = {
		{
			name = "players"
		}
	}
})

vm:CreateCommand({
	name = "nuke",
	callback = AddNuke,
	args = {
		{
			name = "players"
		}
	}
})

vm:CreateCommand({
	name = "removenuke",
	callback = RemoveNuke,
	args = {
		{
			name = "players"
		}
	}
})

vm:CreateCommand({
	name = "oneshot",
	callback = OneshotPlayers,
	args = {
		{
			name = "players"
		}
	}
})

vm:CreateCommand({
	name = "unoneshot",
	callback = UnoneshotPlayers,
	args = {
		{
			name = "players"
		}
	}
})

vm:CreateCommand({
	name = "noguns",
	callback = NoGunsPlayers,
	args = {
		{
			name = "players"
		}
	}
})

vm:CreateCommand({
	name = "unnoguns",
	callback = UnNoGunsPlayers,
	args = {
		{
			name = "players"
		}
	}
})

vm:CreateCommand({
	name = "inmates",
	callback = function()
		return Inmates
	end
})
vm:CreateCommand({
	name = "guards",
	callback = function()
		return Guards
	end
})

vm:CreateCommand({
	name = "criminals",
	callback = function()
		return Criminals
	end
})

vm:CreateCommand({
	name = "team",
	callback = Team,
	args = {
		{
			name = "newTeam"
		}
	}
})

vm:CreateCommand({
	name = "billtext",
	callback = BillboardTextPlayer,
	args = {
		{
			name = "player"
		},
		{
			name = "text"
		}
	}
})

vm:CreateCommand({
	name = "loopkill",
	callback = LoopkillPlayers,
	args = {
		{
			name = "players"
		}
	}
})

vm:CreateCommand({
	name = "unloopkill",
	callback = UnLoopkillPlayers,
	args = {
		{
			name = "players"
		}
	}
})

vm:CreateCommand({
	name = "invisible",
	callback = Invisible
})

vm:CreateCommand({
	name = "visible",
	callback = Visible
})

vm:CreateCommand({
	name = "antikill",
	callback = Antikill
})

vm:CreateCommand({
	name = "unantikill",
	callback = Unantikill
})

vm:CreateCommand({
	name = "antiarrest",
	callback = Antiarrest
})

vm:CreateCommand({
	name = "unantiarrest",
	callback = Unantiarrest
})

vm:CreateCommand({
	name = "pistol",
	callback = function()
		GetItem(PistolName)
	end
})

vm:CreateCommand({
	name = "shotgun",
	callback = function()
		GetItem(ShotgunName)
	end
})

vm:CreateCommand({
	name = "ak",
	callback = function()
		GetItem(AkName)
	end
})

vm:CreateCommand({
	name = "infjump",
	callback = InfJump
})

vm:CreateCommand({
	name = "uninfjump",
	callback = UninfJump
})

vm:CreateCommand({
	name = "car",
	callback = GetCar
})

vm:CreateCommand({
	name = "goto",
	callback = GotoPlayer,
	args = {
		{
			name = "player"
		}
	}
})

vm:CreateCommand({
	name = "iy",
	callback = InfiniteYield
})

vm:CreateCommand({
	name = "dex",
	callback = Dex
})

vm:CreateCommand({
	name = "wallace",
	callback = Spam
})

vm:CreateCommand({
	name = "unwallace",
	callback = Unspam
})

vm:CreateCommand({
	name = "guns",
	callback = GetGuns
})

vm:CreateCommand({
	name = "algointeresante",
	callback = Sus
})

vm:CreateCommand({
	name = "taze",
	callback = TazePlayers,
	args = {
		{
			name = "players"
		}
	}
})

vm:CreateCommand({
	name = "jail",
	callback = JailPlayer,
	args = {
		{
			name = "player"
		}
	}
})

vm:CreateCommand({
	name = "vanish",
	callback = VoidPlayer,
	args = {
		{
			name = "player"
		}
	}
})

vm:CreateCommand({
	name = "carkill",
	callback = CarKillPlayer,
	args = {
		{
			name = "player"
		}
	}
})

vm:CreateCommand({
	name = "arrest",
	callback = ArrestPlayers,
	args = {
		{
			name = "players"
		}
	}
})

vm:CreateCommand({
	name = "touchfling",
	callback = TouchFling
})

vm:CreateCommand({
	name = "untouchfling",
	callback = UntouchFling
})

vm:CreateCommand({
	name = "freezeserver",
	callback = FreezeServer
})

vm:CreateCommand({
	name = "lagspikes",
	callback = LagServer
})

vm:CreateCommand({
	name = "unlagspikes",
	callback = UnlagServer
})

vm:CreateCommand({
	name = "fling",
	callback = FlingPlayers
})

vm:CreateCommand({
	name = "spamsounds",
	callback = AnnoyingSounds
})

vm:CreateCommand({
	name = "unspamsounds",
	callback = UnannoyingSounds
})

vm:CreateCommand({
	name = "turret",
	callback = CreateTurret,
	args = {
		{
			name = "turretname"
		}
	}
})

vm:CreateCommand({
	name = "removeturret",
	callback = RemoveTurret,
	args = {
		{
			name = "turretname"
		}
	}
})

vm:CreateCommand({
	name = "removeturrets",
	callback = RemoveTurrets
})

vm:CreateCommand({
    name = "antilag",
    callback = AntiLag
})

vm:CreateCommand({
    name = "unantilag",
    callback = UnantiLag
})

vm:CreateCommand({
    name = "npc",
    callback = CreateNpc,
    args = {
        {
            name = "size"
        },
		{
			name = "name"
		}
    }
})

vm:CreateCommand({
    name = "removenpc",
    callback = RemoveNpc,
    args = {
        {
            name = "name"
        }
    }
})

vm:CreateCommand({
    name = "removenpcs",
    callback = RemoveNpcs
})

vm:CreateCommand({
    name = "drawtime",
    callback = SetDrawTime,
    args = {
        {
            name = "newdrawtime"
        }
    }
})

vm:CreateCommand({
    name = "bypass",
    callback = ChatBypass
})

vm:CreateCommand({
    name = "copyteam",
    callback = CopyTeam,
    args = {
        {
            name = "player"
        }
    }
})

vm:CreateCommand({
    name = "loopcopyteam",
    callback = LoopCopyTeam,
    args = {
        {
            name = "player"
        }
    }
})

vm:CreateCommand({
    name = "unloopcopyteam",
    callback = UnloopCopyTeam
})

vm:CreateCommand({
    name = "fly",
    callback = Fly,
    args = {
        {
            name = "speed"
        }
    }
})

vm:CreateCommand({
    name = "flyspeed",
    callback = SetFlySpeed,
    args = {
        {
            name = "speed"
        }
    }
})

vm:CreateCommand({
    name = "unfly",
    callback = Unfly
})

Player.Chatted:Connect(function(msg)
	if ChattedDebounce then
		return
	end
	ChattedDebounce = true

	coroutine.wrap(function()
		task.wait(.6)
		ChattedDebounce = false
	end)()

	if msg:sub(1, 1) == parser.CmdPrefix then
		local ok, code = pcall(parser.ParseString, parser, msg)
		if ok then
			vm:Execute(code)
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	for _, List in ipairs(TargetList) do
		Remove(List, player)
	end
end)

AdminCmdBox.FocusLost:Connect(function(EnterPressed)
	if not EnterPressed then
		return
	end

	local ok, code = pcall(parser.ParseString, parser,
		if AdminCmdBox.Text:sub(1, 1) == parser.CmdPrefix then
			AdminCmdBox.Text
		else 
			parser.CmdPrefix..AdminCmdBox.Text
	)

	if ok then
		AdminCmdBox.Text = ""
		vm:Execute(code)
	end
end)

AdminScreenGui.Parent = CoreGui

coroutine.wrap(function()
	while task.wait(3) do
		KillPlayers(TargetList.LoopKilling, true)
	end
end)()

Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
	if LaggingServer and RandGen:NextInteger(3, 9) == 3 then
		while GetToolInBackpack(AkName) == nil do
			GetItem(AkName)
		end

		local Ak = GetToolInBackpack(AkName)
		local NumShots = math.max(math.ceil(ServerLagRatio / math.max(os.clock() - TimeRefresh, 1) * RandGen:NextNumber(1, 6)), 1)

		print(NumShots)

		for i = 0, NumShots do
			ShootEvent:FireServer({}, Ak)
			ReloadEvent:FireServer(Ak)
		end
	end
	TimeRefresh = os.clock()
end)

for _, player in ipairs(Players:GetPlayers()) do
	PlayerAdded(player)
end
