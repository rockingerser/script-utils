local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShootEvent = ReplicatedStorage.ShootEvent
local ReplicateEvent = ReplicatedStorage.ReplicateEvent
local Reload = ReplicatedStorage.TouchReload

local Glyphs = {
    ["0"] = {
        width = 0.5633333333333334,
        vertex = {
            { Vector2.new(.21, .25), Vector2.new(.3533333333333334, .25) }
            { Vector2.new(.3533333333333334, .25), Vector2.new(.4533333333333334, .35) }
            { Vector2.new(.4533333333333334, .35), Vector2.new(.4533333333333334, .79) }
            { Vector2.new(.4533333333333334, .79), Vector2.new(.3533333333333334, .89) }
            { Vector2.new(.3533333333333334, .89), Vector2.new(.21, .89) }
            { Vector2.new(.21, .89), Vector2.new(.11, .79) }
            { Vector2.new(.11, .79), Vector2.new(.11, .35) }
            { Vector2.new(.11, .35), Vector2.new(.21, .25) }
        }
    },
    ["1"] = {
        width = 0.5633333333333334,
        vertex = {
            { Vector2.new(.11, .33), Vector2.new(.31, .26) }
            { Vector2.new(.31, .26), Vector2.new(.31, .9) }
        }
    },
    ["2"] = {
        width = 0.5633333333333334,
        vertex = {
            { Vector2.new(.09, .34), Vector2.new(.19, .24) }
            { Vector2.new(.19, .24), Vector2.new(.383333333333, .24) }
            { Vector2.new(.383333333333, .24), Vector2.new(.453333333333, .42) }
            { Vector2.new(.453333333333, .42), Vector2.new(.09, .89) }
            { Vector2.new(.09, .89), Vector2.new(.5, .89) }
        }
    },
    ["3"] = {
        width = 0.5633333333333334,
        vertex = {
            { Vector2.new(.15, .27), Vector2.new(.42333333333, .27) }
            { Vector2.new(.423333333333, .27), Vector2.new(.18, .54) }
            { Vector2.new(.18, .54), Vector2.new(.36, .57) }
            { Vector2.new(.36, .57), Vector2.new(.46, .72) }
            { Vector2.new(.46, .72), Vector2.new(.3, .9) }
            { Vector2.new(.3, .9), Vector2.new(.12, .84) }
        }
    },
    ["4"] = {
        width = 0.5633333333333334,
        vertex = {
            { Vector2.new(.39, .9), Vector2.new(.39, .24) }
            { Vector2.new(.39, .24), Vector2.new(.06, .72) }
            { Vector2.new(.06, .72), Vector2.new(.51, .72) }
        }
    },
    ["5"] = {
        width = 0.5633333333333334,
        vertex = {
            { Vector2.new(.48, .26), Vector2.new(.17, .26) }
            { Vector2.new(.17, .26), Vector2.new(.15, .54) }
            { Vector2.new(.15, .54), Vector2.new(.3, .48) }
            { Vector2.new(.3, .48), Vector2.new(.45, .54) }
            { Vector2.new(.45, .54), Vector2.new(.48, .75) }
            { Vector2.new(.48, .75), Vector2.new(.3, .9) }
            { Vector2.new(.3, .9), Vector2.new(.13, .81) }
        }
    },
    ["6"] = {
        width = 0.5633333333333334,
        vertex = {
            { Vector2.new(.42, .24), Vector2.new(.15, .54) }
            { Vector2.new(.15, .54), Vector2.new(.3, .48) }
            { Vector2.new(.3, .48), Vector2.new(.45, .54) }
            { Vector2.new(.45, .54), Vector2.new(.48, .72) }
            { Vector2.new(.48, .72), Vector2.new(.39, .88) }
            { Vector2.new(.39, .88), Vector2.new(.21, .88) }
            { Vector2.new(.21, .88), Vector2.new(.12, .72) }
            { Vector2.new(.12, .72), Vector2.new(.15, .54) }
        }
    },
    ["7"] = {
        width = 0.5633333333333334,
        vertex = {
            { Vector2.new(.06, .25), Vector2.new(.48, .25) }
            { Vector2.new(.48, .25), Vector2.new(.18, .9) }
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
            Cframe = CFrame.lookAt(
                Vector3.new(
                    Line[1]:Lerp(Line[2], .5).X,
                    Line[1]:Lerp(Line[2], .5).Y
                ),
                Vector3.new(Line[2].X, Line[2].Y),
                Vector3.upVector
            )
        })
    end
end

local NeonText = {}
NeonText.__index = NeonText

function NeonText.new()
    local self = setmetatable({}, NeonText)
    self.CFrame = CFrame.new(0, 0, 0)
    self.TextXAlignment = Enum.TextXAlignment.Left
    self.TextYAlignment = Enum.TextYAlignment.Top
    self.Text = ""
    self.TextSize = 9
    self.TextRenderScaleWidth = 0
    self.RenderedBullets
end

function NeonText:Render()
    self.RenderedBullets = nil
    if self.Text == "" then
        return
    end
    self.RenderedBullets = {}
    for i = 1, #self.Text do
        local Glyph = GlyphGenCframes[self.Text]
        if Glyph == nil then
            continue
        end
        for _, Line in ipairs(Glyph.vertex) do
            self.RenderedBullets[i] = {
                RayObject = Ray.new(Vector3.zero, Vector3.zero),
                Distance = Line.Distance * self.TextSize
                Cframe = self.CFrame * Glyph.Cframe
            }
        end
        self.TextRenderScaleWidth += Glyph.width
    end
end

function NeonText:SetCFrame(newCframe)
    local oldCframe = self.CFrame
    self.CFrame = newCframe
    if self.RenderedBullets == nil then
        return
    end
    for _, Bullet in pairs(self.RenderedBullets) do
        Bullet.Cframe += newCframe * oldCframe:Inverse()
    end
end
