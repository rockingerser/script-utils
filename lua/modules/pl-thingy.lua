local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local Remote = workspace.Remote
local Player = Players.LocalPlayer
local TeamEvent = Remote.TeamEvent
local Guards = Teams.Guards
local Inmates = Teams.Inmates
local Neutral = Teams.Neutral
local Criminals = Teams.Criminals
local CriminalSpawn = workspace["Criminals Spawn"]:FindFirstChildOfClass("SpawnLocation")

local function GetCharacter(Wait, TargetPlayer)
    TargetPlayer = TargetPlayer or Player
    if not TargetPlayer.Character and Wait then
        Player.CharacterAdded:Wait()
    end
    return TargetPlayer.Character
end

local function GetCharLimb(Name, Wait, TargetPlayer)
    TargetPlayer = TargetPlayer or Player
    if Wait then
        while Character(false, TargetPlayer) == nil or Character(false, TargetPlayer):FindFirstChild(Name) == nil do
            RunService.PostSimulation:Wait()
        end
    end

    local Char = Character(false, TargetPlayer)
    if Char == nil then
        return
    end

    return Char:FindFirstChild("Name")
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
            local Event = 
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
    local Item = workspace.Prison_ITEMS.single[ItemName].ITEMPICKUP
    local Character = GetCharacter()

    if Character == nil then
        return
    end

    local Root = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChild("Humanoid")

    if Root == nil or Humanoid == nil then
        return
    end

    while Player.Backpack:FindFirstChild(ItemName) and Character.Parent == workspace do
        Root.CFrame = Item.CFrame
        itemHandler:InvokeServer(Item)
    end
end

local function KillAllPlayers()
    if #Guards:GetPlayers() == 8 then
        SwitchToTeam(Criminals, true)
    end
end
