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
local AdminScreenGui = Instance.new("ScreenGui")
local SpoofIndicatorPart = Instance.new("Part")
local SpoofIndicatorPartOutline = Instance.new("SelectionBox")
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
local SpoofsOrder = {}
local Spoofs = {}
local SpoofsNames = {}
local Secret =  HttpService:GenerateGUID()

AdminScreenGui.Name = HttpService:GenerateGUID()
AdminScreenGui.ZIndex = -1

SpoofIndicatorPart.Name = HttpService:GenerateGUID(false)
SpoofIndicatorPart.Anchored = true
SpoofIndicatorPart.Size = Vector3.new(2, 2, 1)
SpoofIndicatorPart.CanCollide = false
SpoofIndicatorPart.Transparency = 1


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

local function SpoofPosition(Name, Priority, Value)
    if SpoofsNames[Name] ~= nil then
        SpoofsNames[Names].value = Value
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

local function UnspoofPosition(Name)
    if SpoofsNames[Name] == nil then
        return
    end

    local SpoofToRemove = SpoofsNames[Name]
    local IndexOrder = table.find(Spoofs, SpoofToRemove)

    table.remove(SpoofsOrder, IndexOrder)
    table.remove(Spoofs, IndexOrder)
    SpoofsNames[Name] = nil
end

local function CharacterAdded(NewCharacter)
    local player = Players:GetPlayerFromCharacter(NewCharacter)
    local Humanoid = NewCharacter:WaitForChild("Humanoid")
    local Root = NewCharacter:WaitForChild("HumanoidRootPart")
    local SpoofsOldCFrame

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
        local SpoofsCurrent = Spoofs[1]
        SpoofIndicatorPartOutline.Transparency = 1
        if SpoofsCurrent then
            SpoofsOldCFrame = Root.CFrame
            SpoofIndicatorPartOutline.Transparency = 0
            SpoofIndicatorPartOutline.Color = Color3.fromHSV(os.clock() * .3 % 1, 1, 1)
            SpoofIndicatorPart.CFrame = SpoofsCurrent.value
            Root.CFrame = SpoofsCurrent.value
        end
    end)

    RunService:BindToRenderStep(Secret, 198, function()
        if SpoofsOldCFrame then
            Root.CFrame = SpoofsOldCFrame
            SpoofsOldCFrame = nil
        end
    end)

    coroutine.wrap(function()
        WaitFirst(Humanoid.Died, player.CharacterRemoving)

        SpoofServer:Disconnect()
        RunService:UnbindFromRenderStep(Secret)
    end)()
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
