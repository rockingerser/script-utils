local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Teams = game:GetService("Teams")
local Remote = workspace.Remote
local Player = Players.LocalPlayer
local TeamEvent = Remote.TeamEvent
local ItemHandler = Remote.ItemHandler
local ShootEvent = ReplicatedStorage.ShootEvent
local ReloadEvent = ReplicatedStorage.ReloadEvent
local Guards = Teams.Guards
local Inmates = Teams.Inmates
local Neutral = Teams.Neutral
local Criminals = Teams.Criminals
local CriminalSpawn = workspace["Criminals Spawn"]:FindFirstChildOfClass("SpawnLocation")
local RandGen = Random.new()
local CharSpoofsOrder = {}
local CharSpoofs = {}
local CharSpoofsCurrent = {}
local CharSpoofsOldValues = {}
local HumSpoofsOrder = {}
local HumSpoofs = {}
local HumSpoofsCurrent = {}
local HumSpoofsOldValues = {}
local Secret = HttpService:GenerateGUID()

local function WaitFirst(...)
    local Event = Instance.new("BindableEvent")
    local Events = {}

    for _, event in ipairs({...}) do
        table.insert(Events, event)
        event:Connect(function(...)
            for _, EventTarget in ipairs(Events) do
                EventTarget:Disconnect()
            end

            Event:Fire(event, ...)
            Event:Destroy()
        end)
    end

    return Event.Event:Wait()
end

local function SpoofProperty(Name, Priority, Property, Value, Type)
    if Type ~= "character" and Type ~= "humanoid" then
        error(string.format("Invalid type %q", Type))
    end

    local TypeChar = Type == "character"
    local SpoofsOrder = if TypeChar then CharSpoofsOrder else HumSpoofsOrder
    local Spoofs = if TypeChar then CharSpoofs else HumSpoofs
    local SpoofsCurrent = if TypeChar then CharSpoofsCurrent else HumSpoofsCurrent
    local IndexOrder = 1

    if Spoofs[Property] == nil then
        Spoofs[Property] = {}
        SpoofsOrder[Property] = {}
    end

    if Spoofs[Property][Name] ~= nil then
        return
    end

    for _, OtherPriority in ipairs(SpoofsOrder[Property]) do
        if Priority < OtherPriority then
            IndexOrder += 1
            continue
        end
        break
    end

    table.insert(SpoofsOrder[Property], IndexOrder, Priority)
    table.insert(Spoofs[Property], IndexOrder, Value)

    if IndexOrder == 1 then
        SpoofsCurrent[Property] = Value
    end
end

local function UnspoofProperty(Name, Property, Type)

end

local function CharacterAdded(NewCharacter)
    local player = Players:GetPlayerFromCharacter(NewCharacter)
    local Humanoid = NewCharacter:WaitForChild("Humanoid")

    if player ~= Player then
        local HealthChanged = nil
        HealthChanged = Humanoid.HealthChanged:Connect(function()
            if player.Team == Inmates then
                HealthChanged:Disconnect()
                GunKillPlayers(player)
            end
        end)
        
        return
    end

    local SpoofServer = RunService.PostSimulation:Connect(function()
        for Key, Value in pairs(CharSpoofsCurrent) do
            CharSpoofsOldValues[Key] = NewCharacter[Key]
            NewCharacter[Key] = Value
        end
    end)

    RunService:BindToRenderStep(Secret, 198, function()
        for Key, Value in pairs(CharSpoofsOldValues) do
            NewCharacter[Key] = Value
            CharSpoofsOldValues[Key] = nil
        end
    end)

    coroutine.wrap(function()
        WaitFirst(Humanoid.Died, player.CharacterRemoving)

        SpoofServer:Disconnect()
        RunService:UnbindFromRenderStep(Secret)
    end)()

    table.clear(CharSpoofsOldValues)
    table.clear(HumSpoofsOldValues)
end

local function PlayerAdded(NewPlayer)
    NewPlayer.CharacterAdded:Connect(CharacterAdded)
    if NewPlayer.Character then
        CharacterAdded(NewPlayer.Character)
    end
end

local function GetCharacter(Wait, TargetPlayer)
    TargetPlayer = TargetPlayer or Player
    if not TargetPlayer.Character and Wait then
        return Player.CharacterAdded:Wait()
    end
    return TargetPlayer.Character
end

local function GetCharLimb(Name, Wait, TargetPlayer)
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

local function GetToolInBackpack(ToolName)
    local Character = GetCharacter()
    if Character and Character:FindFirstChild(ToolName) then
        return Character[ToolName]
    end
    return Player.Backpack:FindFirstChild(ToolName)
end

local function SwitchToTeam(Team, Yield)
    if Team == Criminals then
        local From = GetCharLimb("Head", true)

        firetouchinterest(From, CriminalSpawn, 0)
        firetouchinterest(From, CriminalSpawn, 1)
        if Yield then
            Player:GetPropertyChangedSignal("Team"):Wait()
        end
        return
    end

    TeamEvent:FireServer(Team.Color.Name)
    if Yield then
        if Team == Guards and #Guards:GetPlayers() < 8 then
            local Event = Instance.new("BindableEvent")
            local TeamPlAdded = nil
            TeamPlAdded = Guards.PlayerAdded:Connect(function(player)
                if player == Player or #Guards:GetPlayers() == 8 then
                    Event:Fire()
                    TeamPlAdded:Disconnect()
                end
            end)

            Event.Event:Wait()
            Event:Destroy()
            return
        end

        if Team ~= Guards then
            Player:GetPropertyChangedSignal("Team"):Wait()
        end
    end
end

local function KillMyself()
    local Humanoid = GetCharLimb("Humanoid")
    if Humanoid == nil then
        return
    end
    Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
end

local function GetItem(ItemName)
    local Item = workspace.Prison_ITEMS.giver[ItemName].ITEMPICKUP
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

    while Player.Backpack:FindFirstChild(ItemName) == nil and Character.Parent == workspace and Item:IsDescendantOf(workspace) do
        Root.CFrame = Item.CFrame
        ItemHandler:InvokeServer(Item)
    end
end

local function GunKillPlayers(players)
    if Player.Team ~= Criminals then
        SwitchToTeam(Criminals, true)
    end

    local Gun
    local Shoots = {}

    while GetToolInBackpack("M9") == nil do
        GetItem("M9")
    end
    Gun = GetToolInBackpack("M9")

    for _, player in ipairs(players) do
        local TargetHumanoid = GetCharLimb("Humanoid", false, player)
        local TargetHead = GetCharLimb("Head", false, player)

        if TargetHead and TargetHumanoid and TargetHumanoid:GetState() ~= Enum.HumanoidStateType.Dead then
            for i = 0, 6 do
                table.insert(Shoots, {
                    RayObject = Ray.new(Vector3.zero, Vector3.zero),
                    Distance = 1024,
                    CFrame = TargetHead.CFrame * CFrame.Angles(
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
end

Players.PlayerAdded:Connect(PlayerAdded)

for _, player in ipairs(Players:GetPlayers()) do
    PlayerAdded(player)
end
