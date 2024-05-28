local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ShootEvent = ReplicatedStorage.ShootEvent
local ReplicateEvent = ReplicatedStorage.ReplicateEvent
local Reload = ReplicatedStorage.ReloadEvent

-- Neon Text module
-- only lower case characters and numbers
-- Sorry! No documentation
-- (Not fully developed but still works anyway)

local Glyphs = {
    [""] = {
        width = .44333333333333336,
        vertex = {
            { Vector2.new(.06, .9), Vector2.new(.06, .24) },
            { Vector2.new(.06, .9), Vector2.new(.39, .9) },
            { Vector2.new(.39, .9), Vector2.new(.39, .24) },
            { Vector2.new(.39, .24), Vector2.new(.06, .24) }
        }
    },
    ["!"] = {
        width = .25666666666666665,
        vertex = {
            { Vector2.new(.12, .84), Vector2.new(.12, .9) },
            { Vector2.new(.12, .24), Vector2.new(.12, .72) }
        }
    },
    ["\""] = {
        width = .32,
        vertex = {
            { Vector2.new(.1, .2), Vector2.new(.1, .39) },
            { Vector2.new(.23, .2), Vector2.new(.23, .39) }
        }
    },
    ["#"] = {
        width = .6166666666666667,
        vertex = {
            { Vector2.new(.31, .22), Vector2.new(.18, .9) },
            { Vector2.new(.51, .22), Vector2.new(.38, .9) },
            { Vector2.new(.12, .45), Vector2.new(.6, .45) },
            { Vector2.new(.08, .69), Vector2.new(.56, .69) }
        }
    },
    ["$"] = {
        width = .5933333333333334,
        vertex = {
            { Vector2.new(.21, .24), Vector2.new(.39, .24) },
            { Vector2.new(.21, .9), Vector2.new(.39, .9) },
            { Vector2.new(.39, .24), Vector2.new(.52, .39) },
            { Vector2.new(.21, .24), Vector2.new(.09, .39) },
            { Vector2.new(.09, .39), Vector2.new(.52, .73) },
            { Vector2.new(.52, .73), Vector2.new(.39, .9) },
            { Vector2.new(.21, .9), Vector2.new(.09, .73) },
            { Vector2.new(.3, .12), Vector2.new(.3, 1.01) }
        }
    },
    ["%"] = {
        width = .593333333333,
        vertex = {
            { Vector2.new(.45, .31), Vector2.new(.12, .84) },
            { Vector2.new(.12, .31), Vector2.new(.12, .37) },
            { Vector2.new(.45, .78), Vector2.new(.45, .84) }
        }
    },
    ["&"] = {
        width = .6233333333333333,
        vertex = {
            { Vector2.new(.15, .36), Vector2.new(.55, .9) },
            { Vector2.new(.15, .36), Vector2.new(.28, .24) },
            { Vector2.new(.28, .24), Vector2.new(.41, .36) },
            { Vector2.new(.41, .36), Vector2.new(.09, .72) },
            { Vector2.new(.09, .72), Vector2.new(.18, .9) },
            { Vector2.new(.18, .9), Vector2.new(.36, .9) },
            { Vector2.new(.36, .9), Vector2.new(.55, .6) }
        }
    },
    ["("] = {
        width = .3433333333333333,
        vertex = {
            { Vector2.new(.15, .36), Vector2.new(.3, .16) },
            { Vector2.new(.15, .36), Vector2.new(.09, .63) },
            { Vector2.new(.09, .63), Vector2.new(.15, .92) },
            { Vector2.new(.15, .92), Vector2.new(.3, 1.12) }
        }
    },
    ["'"] = {
        width = .17333333333333334,
        vertex = {
            { Vector2.new(.09, .2), Vector2.new(.09, .39) }
        }
    },
    [")"] = {
        width = .3466666666666667,
        vertex = {
            { Vector2.new(.2, .36), Vector2.new(.05, .16) },
            { Vector2.new(.2, .36), Vector2.new(.26, .63) },
            { Vector2.new(.26, .63), Vector2.new(.2, .92) },
            { Vector2.new(.2, .92), Vector2.new(.05, 1.12) }
        }
    },
    ["0"] = {
        width = .5633333333333334,
        vertex = {
            { Vector2.new(.21, .25), Vector2.new(.3533333333333334, .25) },
            { Vector2.new(.3533333333333334, .25), Vector2.new(.4533333333333334, .35) },
            { Vector2.new(.4533333333333334, .35), Vector2.new(.4533333333333334, .79) },
            { Vector2.new(.4533333333333334, .79), Vector2.new(.3533333333333334, .89) },
            { Vector2.new(.3533333333333334, .89), Vector2.new(.21, .89) },
            { Vector2.new(.21, .89), Vector2.new(.11, .79) },
            { Vector2.new(.11, .79), Vector2.new(.11, .35) },
            { Vector2.new(.11, .35), Vector2.new(.21, .25) }
        }
    },
    ["1"] = {
        width = .5633333333333334,
        vertex = {
            { Vector2.new(.11, .33), Vector2.new(.31, .26) },
            { Vector2.new(.31, .26), Vector2.new(.31, .9) }
        }
    },
    ["2"] = {
        width = .5633333333333334,
        vertex = {
            { Vector2.new(.09, .34), Vector2.new(.19, .24) },
            { Vector2.new(.19, .24), Vector2.new(.383333333333, .24) },
            { Vector2.new(.383333333333, .24), Vector2.new(.453333333333, .42) },
            { Vector2.new(.453333333333, .42), Vector2.new(.09, .89) },
            { Vector2.new(.09, .89), Vector2.new(.5, .89) }
        }
    },
    ["3"] = {
        width = .5633333333333334,
        vertex = {
            { Vector2.new(.15, .27), Vector2.new(.42333333333, .27) },
            { Vector2.new(.423333333333, .27), Vector2.new(.18, .54) },
            { Vector2.new(.18, .54), Vector2.new(.36, .57) },
            { Vector2.new(.36, .57), Vector2.new(.46, .72) },
            { Vector2.new(.46, .72), Vector2.new(.3, .9) },
            { Vector2.new(.3, .9), Vector2.new(.12, .84) }
        }
    },
    ["4"] = {
        width = .5633333333333334,
        vertex = {
            { Vector2.new(.39, .9), Vector2.new(.39, .24) },
            { Vector2.new(.39, .24), Vector2.new(.06, .72) },
            { Vector2.new(.06, .72), Vector2.new(.51, .72) }
        }
    },
    ["5"] = {
        width = .5633333333333334,
        vertex = {
            { Vector2.new(.48, .26), Vector2.new(.17, .26) },
            { Vector2.new(.17, .26), Vector2.new(.15, .54) },
            { Vector2.new(.15, .54), Vector2.new(.3, .48) },
            { Vector2.new(.3, .48), Vector2.new(.45, .54) },
            { Vector2.new(.45, .54), Vector2.new(.48, .75) },
            { Vector2.new(.48, .75), Vector2.new(.3, .9) },
            { Vector2.new(.3, .9), Vector2.new(.13, .81) }
        }
    },
    ["6"] = {
        width = .5633333333333334,
        vertex = {
            { Vector2.new(.42, .24), Vector2.new(.15, .54) },
            { Vector2.new(.15, .54), Vector2.new(.3, .48) },
            { Vector2.new(.3, .48), Vector2.new(.45, .54) },
            { Vector2.new(.45, .54), Vector2.new(.48, .72) },
            { Vector2.new(.48, .72), Vector2.new(.39, .88) },
            { Vector2.new(.39, .88), Vector2.new(.21, .88) },
            { Vector2.new(.21, .88), Vector2.new(.12, .72) },
            { Vector2.new(.12, .72), Vector2.new(.15, .54) }
        }
    },
    ["7"] = {
        width = .5633333333333334,
        vertex = {
            { Vector2.new(.06, .25), Vector2.new(.48, .25) },
            { Vector2.new(.48, .25), Vector2.new(.18, .9) }
        }
    },
    ["8"] = {
        width = .5633333333333334,
        vertex = {
            { Vector2.new(.21, .25), Vector2.new(.35, .25) },
            { Vector2.new(.35, .25), Vector2.new(.45, .35) },
            { Vector2.new(.45, .35), Vector2.new(.45, .48) },
            { Vector2.new(.45, .48), Vector2.new(.35, .56) },
            { Vector2.new(.21, .56), Vector2.new(.35, .56) },
            { Vector2.new(.11, .48), Vector2.new(.21, .56) },
            { Vector2.new(.11, .64), Vector2.new(.21, .56) },
            { Vector2.new(.45, .64), Vector2.new(.35, .56) },
            { Vector2.new(.45, .79), Vector2.new(.35, .89) },
            { Vector2.new(.35, .89), Vector2.new(.21, .89) },
            { Vector2.new(.21, .89), Vector2.new(.11, .79) },
            { Vector2.new(.11, .79), Vector2.new(.11, .64) },
            { Vector2.new(.11, .35), Vector2.new(.21, .25) },
            { Vector2.new(.11, .35), Vector2.new(.11, .48) },
            { Vector2.new(.45, .64), Vector2.new(.45, .79) }
        }
    },
    ["9"] = {
        width = .5633333333333334,
        vertex = {
            { Vector2.new(.14, .9), Vector2.new(.41, .6) },
            { Vector2.new(.41, .6), Vector2.new(.26, .66) },
            { Vector2.new(.26, .66), Vector2.new(.11, .6) },
            { Vector2.new(.11, .6), Vector2.new(.08, .42) },
            { Vector2.new(.08, .42), Vector2.new(.17, .26) },
            { Vector2.new(.17, .26), Vector2.new(.35, .26) },
            { Vector2.new(.35, .26), Vector2.new(.44, .42) },
            { Vector2.new(.44, .42), Vector2.new(.41, .6) }
        }
    },
    ["A"] = {
        width = .6533333333333333,
        vertex = {
            { Vector2.new(.07, .9), Vector2.new(.33, .25) },
            { Vector2.new(.58, .9), Vector2.new(.33, .25) },
            { Vector2.new(.18, .63), Vector2.new(.47, .63) },
        }
    },
    ["I"] = {
        width = .2733333333333333,
        vertex = {
            { Vector2.new(.13, .23), Vector2.new(.13, .9) }
        }
    },
    ["S"] = {
        width = .5933333333333334,
        vertex = {
            { Vector2.new(.21, .24), Vector2.new(.39, .24) },
            { Vector2.new(.21, .9), Vector2.new(.39, .9) },
            { Vector2.new(.39, .24), Vector2.new(.52, .39) },
            { Vector2.new(.21, .24), Vector2.new(.09, .39) },
            { Vector2.new(.09, .39), Vector2.new(.52, .73) },
            { Vector2.new(.52, .73), Vector2.new(.39, .9) },
            { Vector2.new(.21, .9), Vector2.new(.09, .73) }
        }
    },
    ["a"] = {
        width = .5433333333333333,
        vertex = {
            { Vector2.new(.18, .43), Vector2.new(.39, .43) },
            { Vector2.new(.39, .43), Vector2.new(.51, .66) },
            { Vector2.new(.51, .66), Vector2.new(.39, .9) },
            { Vector2.new(.18, .9), Vector2.new(.39, .9) },
            { Vector2.new(.18, .9), Vector2.new(.06, .66) },
            { Vector2.new(.06, .66), Vector2.new(.18, .43) },
            { Vector2.new(.51, .43), Vector2.new(.51, .9) }
        }
    },
    ["b"] = {
        width = .56,
        vertex = {
            { Vector2.new(.1, .43), Vector2.new(.39, .43) },
            { Vector2.new(.39, .43), Vector2.new(.51, .66) },
            { Vector2.new(.51, .66), Vector2.new(.39, .9) },
            { Vector2.new(.1, .9), Vector2.new(.39, .9) },
            { Vector2.new(.1, .06), Vector2.new(.1, .9) }
        }
    },
    ["c"] = {
        width = .5233333333333333,
        vertex = {
            { Vector2.new(.18, .43), Vector2.new(.39, .43) },
            { Vector2.new(.18, .9), Vector2.new(.39, .9) },
            { Vector2.new(.18, .9), Vector2.new(.06, .66) },
            { Vector2.new(.06, .66), Vector2.new(.18, .43) }
        }
    },
    ["d"] = {
        width = .5633333333333334,
        vertex = {
            { Vector2.new(.18, .43), Vector2.new(.46, .43) },
            { Vector2.new(.18, .9), Vector2.new(.46, .9) },
            { Vector2.new(.18, .9), Vector2.new(.06, .66) },
            { Vector2.new(.06, .66), Vector2.new(.18, .43) },
            { Vector2.new(.46, .06), Vector2.new(.46, .9) }
        }
    },
    ["e"] = {
        width = .53,
        vertex = {
            { Vector2.new(.18, .43), Vector2.new(.39, .43) },
            { Vector2.new(.39, .43), Vector2.new(.51, .66) },
            { Vector2.new(.06, .66), Vector2.new(.51, .66) },
            { Vector2.new(.18, .9), Vector2.new(.44, .9) },
            { Vector2.new(.18, .9), Vector2.new(.06, .66) },
            { Vector2.new(.06, .66), Vector2.new(.18, .43) }
        }
    },
    ["f"] = {
        width = .3466666666666667,
        vertex = {
            { Vector2.new(.16, .9), Vector2.new(.16, .21) },
            { Vector2.new(.16, .21), Vector2.new(.33, .21) },
            { Vector2.new(.03, .48), Vector2.new(.33, .48) }
        }
    },
    ["g"] = {
        width = .56,
        vertex = {
            { Vector2.new(.18, .43), Vector2.new(.39, .43) },
            { Vector2.new(.39, .43), Vector2.new(.51, .66) },
            { Vector2.new(.51, .66), Vector2.new(.39, .9) },
            { Vector2.new(.18, .9), Vector2.new(.39, .9) },
            { Vector2.new(.18, .9), Vector2.new(.06, .66) },
            { Vector2.new(.06, .66), Vector2.new(.18, .43) },
            { Vector2.new(.51, .43), Vector2.new(.51, 1.2) },
            { Vector2.new(.06, 1.2), Vector2.new(.51, 1.2) }
        }
    },
    ["h"] = {
        width = .55,
        vertex = {
            { Vector2.new(.1, .43), Vector2.new(.39, .43) },
            { Vector2.new(.39, .43), Vector2.new(.51, .58) },
            { Vector2.new(.51, .58), Vector2.new(.51, .9) },
            { Vector2.new(.1, .06), Vector2.new(.1, .9) }
        }
    },
    ["i"] = {
        width = .24333333333333335,
        vertex = {
            { Vector2.new(.12, .42), Vector2.new(.12, .9) },
            { Vector2.new(.12, .24), Vector2.new(.12, .3) }
        }
    },
    ["j"] = {
        width = .24,
        vertex = {
            { Vector2.new(.12, .42), Vector2.new(.12, 1.2) },
            { Vector2.new(.12, .24), Vector2.new(.12, .3) },
            { Vector2.new(-.09, 1.2), Vector2.new(.12, 1.2) }
        }
    },
    ["k"] = {
        width = .5066666666666667,
        vertex = {
            { Vector2.new(.12, .21), Vector2.new(.12, .9) },
            { Vector2.new(.12, .69), Vector2.new(.42, .39) },
            { Vector2.new(.22, .59), Vector2.new(.42, .9) }
        }
    },
    ["l"] = {
        width = .24333333333333335,
        vertex = {
            { Vector2.new(.12, .21), Vector2.new(.12, .9) }
        }
    },
    ["m"] = {
        width = .8766666666666667,
        vertex = {
            { Vector2.new(.1, .43), Vector2.new(.1, .9) },
            { Vector2.new(.1, .53), Vector2.new(.29, .43) },
            { Vector2.new(.29, .43), Vector2.new(.44, .53) },
            { Vector2.new(.44, .53), Vector2.new(.44, .9) },
            { Vector2.new(.44, .53), Vector2.new(.61, .43) },
            { Vector2.new(.61, .43), Vector2.new(.76, .53) },
            { Vector2.new(.76, .53), Vector2.new(.76, .9) }
        }
    },
    ["n"] = {
        width = .5533333333333333,
        vertex = {
            { Vector2.new(.1, .43), Vector2.new(.1, .9) },
            { Vector2.new(.1, .53), Vector2.new(.29, .43) },
            { Vector2.new(.29, .43), Vector2.new(.44, .53) },
            { Vector2.new(.44, .53), Vector2.new(.44, .9) }
        }
    },
    ["o"] = {
        width = .57,
        vertex = {
            { Vector2.new(.18, .43), Vector2.new(.39, .43) },
            { Vector2.new(.39, .43), Vector2.new(.51, .66) },
            { Vector2.new(.51, .66), Vector2.new(.39, .9) },
            { Vector2.new(.18, .9), Vector2.new(.39, .9) },
            { Vector2.new(.18, .9), Vector2.new(.06, .66) },
            { Vector2.new(.06, .66), Vector2.new(.18, .43) }
        }
    },
    ["p"] = {
        width = .56,
        vertex = {
            { Vector2.new(.1, .43), Vector2.new(.1, 1.2) },
            { Vector2.new(.1, .43), Vector2.new(.39, .43) },
            { Vector2.new(.39, .43), Vector2.new(.51, .66) },
            { Vector2.new(.51, .66), Vector2.new(.39, .9) },
            { Vector2.new(.1, .9), Vector2.new(.39, .9) }
        }
    },
    ["q"] = {
        width = .57,
        vertex = {
            { Vector2.new(.46, .43), Vector2.new(.46, 1.2) },
            { Vector2.new(.18, .43), Vector2.new(.46, .43) },
            { Vector2.new(.18, .9), Vector2.new(.46, .9) },
            { Vector2.new(.18, .9), Vector2.new(.06, .66) },
            { Vector2.new(.06, .66), Vector2.new(.18, .43) }
        }
    },
    ["r"] = {
        width = .34,
        vertex = {
            { Vector2.new(.1, .43), Vector2.new(.1, .9) },
            { Vector2.new(.1, .53), Vector2.new(.21, .43) },
            { Vector2.new(.21, .43), Vector2.new(.31, .43) }
        }
    },
    ["s"] = {
        width = .5166666666666667,
        vertex = {
            { Vector2.new(.17, .43), Vector2.new(.42, .43) },
            { Vector2.new(.17, .43), Vector2.new(.08, .54) },
            { Vector2.new(.08, .54), Vector2.new(.17, .66) },
            { Vector2.new(.17, .66), Vector2.new(.35, .66) },
            { Vector2.new(.35, .66), Vector2.new(.44, .77) },
            { Vector2.new(.44, .77), Vector2.new(.35, .9) },
            { Vector2.new(.35, .9), Vector2.new(.1, .9) }
        }
    },
    ["t"] = {
        width = .32666666666666666,
        vertex = {
            { Vector2.new(.14, .3), Vector2.new(.14, .9) },
            { Vector2.new(.02, .48), Vector2.new(.26, .48) }
        }
    },
    ["u"] = {
        width = .55,
        vertex = {
            { Vector2.new(.1, .43), Vector2.new(.1, .78) },
            { Vector2.new(.1, .78), Vector2.new(.27, .9) },
            { Vector2.new(.27, .9), Vector2.new(.44, .78) },
            { Vector2.new(.44, .43), Vector2.new(.44, .78) }
        }
    },
    ["v"] = {
        width = .48333333333333334,
        vertex = {
            { Vector2.new(.07, .43), Vector2.new(.24, .9) },
            { Vector2.new(.4, .43), Vector2.new(.24, .9) }
        }
    },
    ["w"] = {
        width = .75,
        vertex = {
            { Vector2.new(.07, .43), Vector2.new(.21, .9) },
            { Vector2.new(.38, .43), Vector2.new(.21, .9) },
            { Vector2.new(.38, .43), Vector2.new(.52, .9) },
            { Vector2.new(.52, .9), Vector2.new(.66, .43) }
        }
    },
    ["x"] = {
        width = .49666666666666665,
        vertex = {
            { Vector2.new(.07, .43), Vector2.new(.43, .9) },
            { Vector2.new(.4, .43), Vector2.new(.07, .9) }
        }
    },
    ["y"] = {
        width = .47333333333333333,
        vertex = {
            { Vector2.new(.07, .43), Vector2.new(.24, .9) },
            { Vector2.new(.4, .43), Vector2.new(.138, 1.2) }
        }
    },
    ["z"] = {
        width = .49666666666666665,
        vertex = {
            { Vector2.new(.07, .43), Vector2.new(.43, .43) },
            { Vector2.new(.43, .43), Vector2.new(.07, .9) },
            { Vector2.new(.07, .9), Vector2.new(.43, .9) }
        }
    },
    ["¡"] = {
        width = .24333333333333335,
        vertex = {
            { Vector2.new(.12, .6), Vector2.new(.12, 1.08) },
            { Vector2.new(.12, .42), Vector2.new(.12, .48) }
        }
    },
}

local GlyphGenCframes = {}

for Key, Data in pairs(Glyphs) do
    local Table = {
        width = Data.width,
        vertex = {}
    }
    for _, Line in ipairs(Data.vertex) do
        table.insert(Table.vertex, {
            Distance = (Line[1] - Line[2]).Magnitude,
            Position = Vector3.new(Line[1]:Lerp(Line[2], .5).X, -Line[1]:Lerp(Line[2], .5).Y),
            Cframe = CFrame.lookAt(
                Vector3.zero,
                Vector3.new(Line[2].X - Line[1].X, Line[1].Y - Line[2].Y),
                Vector3.yAxis
            )
        })
    end
    GlyphGenCframes[Key] = Table
end

local NeonText = {}
NeonText.__index = NeonText

local function HasTool(ToolName)
    local Character = Player.Character
    local Backpack = Player.Backpack

    if Character == nil then
        return
    end

    if Character:FindFirstChild(ToolName) or Backpack:FindFirstChild(ToolName) then
        return Character:FindFirstChild(ToolName) or Backpack[ToolName]
    end
end

local function getGun()
    return HasTool("M4A1") or HasTool("AK-47") or HasTool("M9") or HasTool("Remington 870") or HasTool("Taser")
end

function NeonText.new()
    local self = setmetatable({}, NeonText)
    self.CFrame = CFrame.new(0, 0, 0)
    self.TextXAlignment = Enum.TextXAlignment.Left
    self.TextYAlignment = Enum.TextYAlignment.Top
    self.Text = ""
    self.TextSize = 3
    self.TextRenderScaleWidth = 0
    self.RenderedBullets = {}
    return self
end

function NeonText:Render()
    self.RenderedBullets = nil
    if self.Text == "" then
        return
    end
    self.RenderedBullets = {}
    local BulletId = 1
    self.TextRenderScaleWidth = 0
    for i = 1, #self.Text do
        if self.Text:sub(i, i) == " " then
            self.TextRenderScaleWidth += 1 / 3
            continue
        end
        local Glyph = GlyphGenCframes[self.Text:sub(i, i):lower()]
        if Glyph == nil then
            continue
        end
        for Key, Line in ipairs(Glyph.vertex) do
            self.RenderedBullets[BulletId] = {
                RayObject = Ray.new(Vector3.zero, Vector3.zero),
                Distance = Line.Distance * self.TextSize,
                Cframe = self.CFrame * CFrame.new((Line.Position + Vector3.xAxis * self.TextRenderScaleWidth) * self.TextSize) * Line.Cframe
            }
            BulletId += 1
        end
        self.TextRenderScaleWidth += Glyph.width
    end
end

function NeonText:SetCFrame(newCframe)
    local oldCframe = self.CFrame
    self.CFrame = newCframe
    print(#self.RenderedBullets)
    if self.RenderedBullets == nil then
        return
    end
    for _, Bullet in pairs(self.RenderedBullets) do
        Bullet.Cframe *= newCframe * oldCframe:Inverse()
        print(Bullet.Cframe.Position)
        return
    end
end

function NeonText:Draw()
    -- Draw Text on player's screen
    for _, Connection in pairs(getconnections(ReplicateEvent.OnClientEvent)) do
        Connection:Fire(self.RenderedBullets)
    end

    local Gun = getGun()
    if Gun then
        ShootEvent:FireServer(self.RenderedBullets, Gun)
        Reload:FireServer(Gun)
    end
end

--------------------------- test
--[[
local neonText = NeonText.new()
neonText.Text = "soy la primera persona en crear este script oh yeahh"
neonText.CFrame = Player.Character.Head.CFrame * CFrame.new(0, 0, 0)
neonText.TextSize = 1.5
neonText:Render()

while task.wait(.36) do
    if Player.Character:FindFirstChild("Head") then
        --print("Ok")
        neonText:Draw()
    end
end
]]

return NeonText
