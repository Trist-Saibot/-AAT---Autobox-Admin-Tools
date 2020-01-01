--Manages colors

function autobox:ColorToHex(color)
    string.format("#%02X%02X%02X%02X",color.r,color.g,color.b,color.a)
end
function autobox:HexToColor(hex)
    local l = string.len(hex)
    if (l > 0 and string.sub(hex,1,1) == "#") then --remove # if it has one
        hex = string.sub(hex,2,l)
        l = l-1
    end
    if (l >= 6) then --split out RGB(A) and convert
        local r = "0x" .. string.sub(hex,1,2)
        local g = "0x" .. string.sub(hex,3,4)
        local b = "0x" .. string.sub(hex,5,6)
        if (l == 6) then
            return Color(tonumber(r),tonumber(g),tonumber(b))
        elseif (l == 8) then
            local a = "0x" .. string.sub(hex,7,8)
            return Color(tonumber(r),tonumber(g),tonumber(b),tonumber(a))
        end
    end
    return nil
end
function autobox:ColorDarken(color,n)
    return Color(color.r * n,color.g * n,color.b * n)
end
function autobox:MixColor(color1,color2,ratio)
    ratio = ratio + .1
    return Color(color1.r * ratio + color2.r * -ratio,color1.g * ratio + color2.g * -ratio,color1.b * ratio + color2.b * -ratio)
end

autobox.colors = {}
autobox.colors.blue = Color(98,176,255,255)
autobox.colors.red = Color(255,62,62,255)
autobox.colors.yellow = Color(255,207,61,255)
autobox.colors.black = Color(0,0,0,255)
autobox.colors.white = Color(255,255,255,255)
autobox.colors.tan = Color(237,219,189)
autobox.colors.tan2 = Color(226,209,181)
autobox.colors.brown = Color(66,51,48)
autobox.colors.green = Color(85,255,100,255)
autobox.colors.pink = autobox:HexToColor("FF69B4")
autobox.colors.discord =
{
    autobox:HexToColor("#7289DA"),
    autobox:HexToColor("#99AAB5"),
    autobox:HexToColor("#2C2F33"),
    autobox:HexToColor("#23272A")
}
autobox.colors.discordAlt =
{
    autobox:HexToColor("#536672"),
    autobox:HexToColor("#3E4248")
}

autobox.colors.db32 =
{"FF000000",
"FF222034",
"FF45283C",
"FF663931",
"FF8F563B",
"FFDF7126",
"FFD9A066",
"FFEEC39A",
"FFFBF236",
"FF99E550",
"FF6ABE30",
"FF37946E",
"FF4B692F",
"FF524B24",
"FF323C39",
"FF3F3F74",
"FF306082",
"FF5B6EE1",
"FF639BFF",
"FF5FCDE4",
"FFCBDBFC",
"FFFFFFFF",
"FF9BADB7",
"FF847E87",
"FF696A6A",
"FF595652",
"FF76428A",
"FFAC3232",
"FFD95763",
"FFD77BBA",
"FF8F974A",
"FF8A6F30"}
for k,v in pairs(autobox.colors.db32) do
    autobox.colors.db32[k] = autobox:HexToColor(string.sub(v,3,8))
end
