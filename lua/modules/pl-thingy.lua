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
local AdminCmdBox = Instance.new("TextBox")
local AdminRoundCorners = Instance.new("UICorner")
local AdminStroke = Instance.new("UIStroke")
local AdminPadding = Instance.new("UIPadding")
local SpoofIndicatorPart = Instance.new("Part")
local SpoofIndicatorPartOutline = Instance.new("SelectionBox")
local Remote = workspace.Remote
local Player = Players.LocalPlayer
local TeamEvent = Remote.TeamEvent
local GotArrested = Remote.arrestPlayer
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
local OneshotTargetPlayers = {}
local NoGunsTargetPlayers = {}
local LoopKillingPlayers = {}
local LocalCharacter = nil
local LocalHumanoid = nil
local LocalRoot = nil
local AntikillEnabled = false
local AntiarrestEnabled = false
local Secret =  HttpService:GenerateGUID()
local NeonTxtIns = nil
local TargetBillboardTextPlayer = nil
local BiggestNumber = 1.7976931348623157e308
local PistolName = "M9"
local TaserName = "Taser"
local ShotgunName = "Remington 870"
local AkName = "AK-47"
local KnifeName = "Crude knife"
local HammerName = "Hammer"
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
local CurrentState = DefaultState


coroutine.wrap(function()
    task.wait(12)
    NeonTxtIns = loadstring(game:HttpGet("https://pastebin.com/raw/ra0fj8pP"))().new()
    NeonTxtIns.TextSize = 1.5
end)()

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
local CommandVM = loadstring(game:HttpGet("https://pastebin.com/raw/27Lnax7E"), true)()
local Parser = loadstring(game:HttpGet("https://pastebin.com/raw/t7RunsQs"), true)()
-- HTTP 429 Prevention
task.wait(3)

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

function SaveState()
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

    if CurrentState.pistol then
        coroutine.wrap(GetItem)(PistolName)
    end
    if CurrentState.shotgun then
        GetItem(ShotgunName)
    end
    if CurrentState.ak then
        GetItem(AkName)
    end
    if CurrentState.knife then
        GetItem(KnifeName)
    end
    if CurrentState.hammer then
        GetItem(HammerName)
    end

    Player.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.GettingUp)

    if CurrentState.cframe then
        local cframe = CurrentState.cframe
        local Root = Player.Character:WaitForChild("HumanoidRootPart")
        LocalRoot = Root
        local OldTime = os.clock()
        while os.clock() - OldTime < .18 do
            if (Root.Position - cframe.Position).Magnitude > 15 then
                Root.CFrame = cframe
            end
            RunService.PreSimulation:Wait()
        end
    end
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
    local Head = NewCharacter:WaitForChild("Head")
    local SpoofsOldCFrame
    local Arrested = false

    Humanoid.Died:Once(function()
        if table.find(PendingNuke, player) then
            table.remove(PendingNuke, table.find(PendingNuke, player))
            KillPlayers(Players:GetPlayers())
        end
        if player == Player and AntikillEnabled and not Arrested then
            print(Player.Team)
            SaveState()
            RestoreState()
        end
    end)

    local HealthChanged, NoGunsCheck = nil, nil
    HealthChanged = Humanoid.HealthChanged:Connect(function()
        if table.find(OneshotTargetPlayers, player) then
            HealthChanged:Disconnect()
            KillPlayers(player)
        end
    end)
    NoGunsCheck = player.Backpack.ChildAdded:Connect(function(Gun)
        if player.Team ~= Guards and table.find(NoGunsTargetPlayers, player) and Gun:WaitForChild("GunStates", .9) then
            NoGunsCheck:Disconnect()
            KillPlayers(player)
        end
    end)

    if player ~= Player then
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
            SpoofIndicatorPartOutline.Color3 = Color3.fromHSV(os.clock() % 1, 1, 1)
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

    --[[Player.CharacterRemoving:Once(function()
        if Humanoid:GetState() ~= Enum.HumanoidStateType.Dead and Head:FindFirstChild("handcuffedGui") == nil then
            SaveState()
        end
        if AntiarrestEnabled then
            RestoreState()
        end
    end)]]

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

function GetToolInBackpack(ToolName)
    local Character = GetCharacter()
    if Character and Character:FindFirstChild(ToolName) then
        return Character[ToolName]
    end
    return Player.Backpack:FindFirstChild(ToolName)
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

    SpoofPosition("getitemtask"..ItemName, 3000, Item.CFrame)
    while Player.Backpack:FindFirstChild(ItemName) == nil and Character.Parent == workspace and Item:IsDescendantOf(workspace) do
        ItemHandler:InvokeServer(Item)
    end
    UnspoofPosition("getitemtask"..ItemName)
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
                SpoofPosition("tpkilltask", 300, TargetRoot.CFrame)
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
end

function OneshotPlayers(players)
    if typeof(players) ~= "table" then
        players = {
            [1] = players
        }
    end
    for _, player in pairs(players) do
        if table.find(OneshotTargetPlayers, player) then
            continue
        end
        table.insert(OneshotTargetPlayers, player)
    end
end

function UnoneshotPlayers(players)
    if typeof(players) ~= "table" then
        players = {
            [1] = players
        }
    end
    for _, player in pairs(players) do
        if table.find(OneshotTargetPlayers, player) then
            table.remove(OneshotTargetPlayers, table.find(OneshotTargetPlayers, player))
        end
    end
end

function NoGunsPlayers(players)
    if typeof(players) ~= "table" then
        players = {
            [1] = players
        }
    end
    for _, player in pairs(players) do
        if table.find(NoGunsTargetPlayers, player) then
            continue
        end
        table.insert(NoGunsTargetPlayers, player)
    end
end

function UnNoGunsPlayers(players)
    if typeof(players) ~= "table" then
        players = {
            [1] = players
        }
    end
    for _, player in pairs(players) do
        if table.find(NoGunsTargetPlayers, player) then
            table.remove(NoGunsTargetPlayers, table.find(NoGunsTargetPlayers, player))
        end
    end
end

function LoopkillPlayers(players)
    if typeof(players) ~= "table" then
        players = {
            [1] = players
        }
    end
    for _, player in pairs(players) do
        if table.find(LoopKillingPlayers, player) then
            continue
        end
        table.insert(LoopKillingPlayers, player)
    end
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
            RunService.PostSimulation:Wait()
            if typeof(TargetBillboardTextPlayer) ~= "Instance" or not TargetBillboardTextPlayer:IsA("Player") then
                continue
            end
            if GetToolInBackpack(PistolName) == nil then
                GetItem(PistolName)
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
            NeonTxtIns:Draw()
            task.wait(.6)
        end
end)()

function UnLoopkillPlayers(players)
    if typeof(players) ~= "table" then
        players = {
            [1] = players
        }
    end
    for _, player in pairs(players) do
        if table.find(LoopKillingPlayers, player) then
            table.remove(LoopKillingPlayers, table.find(LoopKillingPlayers, player))
        end
    end
end

function Invisible()
    SpoofPosition("i'm invisible", 99, CFrame.new(BiggestNumber, BiggestNumber, BiggestNumber))
end

function Visible()
    UnspoofPosition("i'm invisible")
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
    SaveState()
    SwitchToTeam(Team, true)
    RestoreState(true)
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

Player.Chatted:Connect(function(msg)
    if msg:sub(1, 1) == parser.CmdPrefix then
        local ok, code = pcall(parser.ParseString, parser, msg)
        if ok then
            vm:Execute(code)
        end
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
    while task.wait(1.5) do
        KillPlayers(LoopKillingPlayers)
    end
end)()

for _, player in ipairs(Players:GetPlayers()) do
    PlayerAdded(player)
end
