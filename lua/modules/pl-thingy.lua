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
local MeleeEvent = ReplicatedStorage.meleeEvent
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
local KillingPlayers = {}
local PendingNuke = {}
local OneshotPlayers = {}
local LocalCharacter = nil
local LocalHumanoid = nil
local LocalRoot = nil
local Secret =  HttpService:GenerateGUID()

AdminScreenGui.Name = HttpService:GenerateGUID()
--dminScreenGui.ZIndex = -1

SpoofIndicatorPart.Name = HttpService:GenerateGUID(false)
SpoofIndicatorPart.Anchored = true
SpoofIndicatorPart.Size = Vector3.new(2, 2, 1)
SpoofIndicatorPart.CanCollide = false
SpoofIndicatorPart.Transparency = 1

SpoofIndicatorPartOutline.Adornee = SpoofIndicatorPart
SpoofIndicatorPartOutline.Parent = SpoofIndicatorPart
SpoofIndicatorPart.Parent = workspace

-- Import some admin modules
local CommandVM = loadstring(game:HttpGet("https://pastebin.com/raw/27Lnax7E"), true)()
local Parser = loadstring(game:HttpGet("https://pastebin.com/raw/t7RunsQs"), true)()
-- HTTP 429 Prevention
task.wait(6)

local vm = CommandVM.new()
local parser = Parser.new(vm)

-- Import basic commands
loadstring(game:HttpGet("https://pastebin.com/raw/V1e3Zsub"), true)()(vm)

function Chat(msg, channel)
    SayMessage:FireServer(msg, channel or "All")
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

function CharacterAdded(NewCharacter)
    local player = Players:GetPlayerFromCharacter(NewCharacter)
    local Humanoid = NewCharacter:WaitForChild("Humanoid")
    local Root = NewCharacter:WaitForChild("HumanoidRootPart")
    local SpoofsOldCFrame

    Humanoid.Died:Once(function()
        if table.find(PendingNuke, player) then
            table.remove(PendingNuke, table.find(PendingNuke, player))
            KillPlayers(Players:GetPlayers())
        end
    end)

    if player ~= Player then
        Humanoid.HealthChanged:Connect(function()
            if table.find(OneshotPlayers, player) then
                KillPlayers(player)
            end
        end)
        return
    end

    LocalCharacter = NewCharacter
    LocalHumanoid = Humanoid
    LocalRoot = Root

    local SpoofServer = RunService.PostSimulation:Connect(function()
        local SpoofsCurrent = Spoofs[1]
        SpoofIndicatorPartOutline.Transparency = 1
        if SpoofsCurrent then
            SpoofsOldCFrame = Root.CFrame
            SpoofIndicatorPartOutline.Transparency = 0
            SpoofIndicatorPartOutline.Color3 = Color3.fromHSV(os.clock() * .3 % 1, 1, 1)
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

function GetToolInBackpack(ToolName)
    local Character = GetCharacter()
    if Character and Character:FindFirstChild(ToolName) then
        return Character[ToolName]
    end
    return Player.Backpack:FindFirstChild(ToolName)
end

function SwitchToTeam(Team, Yield)
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

function KillMyself()
    local Humanoid = GetCharLimb("Humanoid")
    if Humanoid == nil then
        return
    end
    Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
end

function GetItem(ItemName)
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

    SpoofPosition("getitemtask", 3000, Item.CFrame)
    while Player.Backpack:FindFirstChild(ItemName) == nil and Character.Parent == workspace and Item:IsDescendantOf(workspace) do
        ItemHandler:InvokeServer(Item)
    end
    UnspoofPosition("getitemtask")
end

function GunKillPlayers(players, taser)
    --[[if Player.Team ~= Criminals then
        SwitchToTeam(Criminals, true)
    end]]

    local Gun
    local Shoots = {}

    --[[if taser then

    else]]
        while GetToolInBackpack("M9") == nil do
            GetItem("M9")
        end
    --end
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
                SpoofPosition("tpkilltask", 102, TargetRoot.CFrame)
                for i = 0, 9 do
                    MeleeEvent:FireServer(TargetPlayer)
                end
                RunService.PostSimulation:Wait()
            end
        until #KillingPlayers == 0
        UnspoofPosition("tpkilltask")
        return
    end
    for _, player in ipairs(players) do
        table.insert(KillingPlayers, players)
    end
end

function KillPlayers(players)
    local ArraySameTeamPlayers = {}
    local ArrayOtherTeamPlayers = {}
    local ShouldKillMyself = false

    if typeof(players) ~= "table" then
        players = {
            [1] = players
        }
    end

    for _, player in pairs(players) do
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

function AddNuke(players)
    if typeof(players) ~= "table" then
        players = {
            [1] = players
        }
    end
    for _, player in pairs(players) do
        table.insert(PendingNuke, player)
    end
end

function OneshotPlayers(players)
    
end

Players.PlayerAdded:Connect(PlayerAdded)

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

Player.Chatted:Connect(function(msg)
    if msg:sub(1, 1) == parser.CmdPrefix then
        local ok, code = pcall(parser.ParseString, parser, msg)
        if ok then
            vm:Execute(code)
        end
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    PlayerAdded(player)
end
