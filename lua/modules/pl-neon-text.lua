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
    ["8"] = {
        width = 0.5633333333333334,
        vertex = {
            { Vector2.new(.21, .25), Vector2.new(.35, .25) }
            { Vector2.new(.35, .25), Vector2.new(.45, .35) }
            { Vector2.new(.45, .35), Vector2.new(.45, .48) }
            { Vector2.new(.45, .48), Vector2.new(.35, .56) }
            { Vector2.new(.21, .56), Vector2.new(.35, .56) }
            { Vector2.new(.11, .48), Vector2.new(.21, .56) }
            { Vector2.new(.11, .64), Vector2.new(.21, .56) }
            { Vector2.new(.45, .64), Vector2.new(.35, .56) }
            { Vector2.new(.45, .79), Vector2.new(.35, .89) }
            { Vector2.new(.35, .89), Vector2.new(.21, .89) }
            { Vector2.new(.21, .89), Vector2.new(.11, .79) }
            { Vector2.new(.11, .79), Vector2.new(.11, .64) }
            { Vector2.new(.11, .35), Vector2.new(.21, .25) }
            { Vector2.new(.11, .35), Vector2.new(.11, .48) }
            { Vector2.new(.45, .64), Vector2.new(.45, .79) }
        }
    },
    ["9"] = {
        width = 0.5633333333333334,
        vertex = {
            { Vector2.new(.14, .9), Vector2.new(.41, .6) }
            { Vector2.new(.41, .6), Vector2.new(.26, .66) }
            { Vector2.new(.26, .66), Vector2.new(.11, .6) }
            { Vector2.new(.11, .6), Vector2.new(.08, .42) }
            { Vector2.new(.08, .42), Vector2.new(.17, .26) }
            { Vector2.new(.17, .26), Vector2.new(.35, .26) }
            { Vector2.new(.35, .26), Vector2.new(.44, .42) }
            { Vector2.new(.44, .42), Vector2.new(.41, .6) }
        }
    },
    ["a"] = {
        width = 0.5433333333333333,
        vertex = {
            { Vector2.new(.18, .43), Vector2.new(.39, .43) }
            { Vector2.new(.39, .43), Vector2.new(.51, .66) }
            { Vector2.new(.51, .66), Vector2.new(.39, .9) }
            { Vector2.new(.18, .9), Vector2.new(.39, .9) }
            { Vector2.new(.18, .9), Vector2.new(.06, .66) }
            { Vector2.new(.06, .66), Vector2.new(.18, .43) }
            { Vector2.new(.51, .43), Vector2.new(.51, .9) }
        }
    },
    ["b"] = {
        width = 0.56,
        vertex = {
            { Vector2.new(.1, .43), Vector2.new(.39, .43) }
            { Vector2.new(.39, .43), Vector2.new(.51, .66) }
            { Vector2.new(.51, .66), Vector2.new(.39, .9) }
            { Vector2.new(.1, .9), Vector2.new(.39, .9) }
            { Vector2.new(.1, .06), Vector2.new(.1, .9) }
        }
    },
    ["c"] = {
        width = 0.5233333333333333,
        vertex = {
            { Vector2.new(.18, .43), Vector2.new(.39, .43) }
            { Vector2.new(.18, .9), Vector2.new(.39, .9) }
            { Vector2.new(.18, .9), Vector2.new(.06, .66) }
            { Vector2.new(.06, .66), Vector2.new(.18, .43) }
        }
    },
    ["d"] = {
        width = 0.5633333333333334,
        vertex = {
            { Vector2.new(.18, .43), Vector2.new(.46, .43) }
            { Vector2.new(.18, .9), Vector2.new(.46, .9) }
            { Vector2.new(.18, .9), Vector2.new(.06, .66) }
            { Vector2.new(.06, .66), Vector2.new(.18, .43) }
            { Vector2.new(.46, .06), Vector2.new(.46, .9) }
        }
    },
    ["e"] = {
        width = 0.53,
        vertex = {
            { Vector2.new(.18, .43), Vector2.new(.39, .43) }
            { Vector2.new(.39, .43), Vector2.new(.51, .66) }
            { Vector2.new(.06, .66), Vector2.new(.51, .66) }
            { Vector2.new(.18, .9), Vector2.new(.44, .9) }
            { Vector2.new(.18, .9), Vector2.new(.06, .66) }
            { Vector2.new(.06, .66), Vector2.new(.18, .43) }
        }
    },
    ["f"] = {
        width = 0.3466666666666667,
        vertex = {
            { Vector2.new(.16, .9), Vector2.new(.16, .21) }
            { Vector2.new(.16, .21), Vector2.new(.33, .21) }
            { Vector2.new(.03, .48), Vector2.new(.33, .48) }
        }
    },
    ["g"] = {
        width = 0.56,
        vertex = {
            { Vector2.new(.18, .43), Vector2.new(.39, .43) }
            { Vector2.new(.39, .43), Vector2.new(.51, .66) }
            { Vector2.new(.51, .66), Vector2.new(.39, .9) }
            { Vector2.new(.18, .9), Vector2.new(.39, .9) }
            { Vector2.new(.18, .9), Vector2.new(.06, .66) }
            { Vector2.new(.06, .66), Vector2.new(.18, .43) }
            { Vector2.new(.51, .43), Vector2.new(.51, 1.2) }
            { Vector2.new(.06, 1.2), Vector2.new(.51, 1.2) }
        }
    },
    ["h"] = {
        width = 0.55,
        vertex = {
            { Vector2.new(.1, .43), Vector2.new(.39, .43) }
            { Vector2.new(.39, .43), Vector2.new(.51, .58) }
            { Vector2.new(.51, .58), Vector2.new(.51, .9) }
            { Vector2.new(.1, .06), Vector2.new(.1, .9) }
        }
    },
    ["i"] = {
        width = 0.24333333333333335,
        vertex = {
            { Vector2.new(.12, .42), Vector2.new(.12, .9) }
            { Vector2.new(.12, .24), Vector2.new(.12, .3) }
        }
    },
    ["j"] = {
        width = 0.24,
        vertex = {
            { Vector2.new(.12, .42), Vector2.new(.12, 1.2) }
            { Vector2.new(.12, .24), Vector2.new(.12, .3) }
            { Vector2.new(-.09, 1.2), Vector2.new(.12, 1.2) }
        }
    },
    ["k"] = {
        width = 0.5066666666666667,
        vertex = {
            { Vector2.new(.12, .21), Vector2.new(.12, .9) }
            { Vector2.new(.12, .69), Vector2.new(.42, .39) }
            { Vector2.new(.22, .59), Vector2.new(.42, .9) }
        }
    },
    ["l"] = {
        width = 0.24333333333333335,
        vertex = {
            { Vector2.new(.12, .21), Vector2.new(.12, .9) }
        }
    },
    ["m"] = {
        width = 0.8766666666666667,
        vertex = {
            { Vector2.new(.1, .43), Vector2.new(.1, .9) }
            { Vector2.new(.1, .53), Vector2.new(.29, .43) }
            { Vector2.new(.29, .43), Vector2.new(.44, .53) }
            { Vector2.new(.44, .53), Vector2.new(.44, .9) }
            { Vector2.new(.44, .53), Vector2.new(.61, .43) }
            { Vector2.new(.61, .43), Vector2.new(.76, .53) }
            { Vector2.new(.76, .53), Vector2.new(.76, .9) }
        }
    },
    ["n"] = {
        width = 0.5533333333333333,
        vertex = {
            { Vector2.new(.1, .43), Vector2.new(.1, .9) }
            { Vector2.new(.1, .53), Vector2.new(.29, .43) }
            { Vector2.new(.29, .43), Vector2.new(.44, .53) }
            { Vector2.new(.44, .53), Vector2.new(.44, .9) }
        }
    },
    
    ["o"] = {
        width = 0.57,
        vertex = {
            { Vector2.new(.18, .43), Vector2.new(.39, .43) }
            { Vector2.new(.39, .43), Vector2.new(.51, .66) }
            { Vector2.new(.51, .66), Vector2.new(.39, .9) }
            { Vector2.new(.18, .9), Vector2.new(.39, .9) }
            { Vector2.new(.18, .9), Vector2.new(.06, .66) }
            { Vector2.new(.06, .66), Vector2.new(.18, .43) }
        }
    },
    ["I"] = {
        width = 0.2733333333333333,
        vertex = {
            { Vector2.new(.13, .23), Vector2.new(.13, .9) }
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
