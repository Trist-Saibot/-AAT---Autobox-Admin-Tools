-----
--Changes the default chat box
-----
local PLUGIN = {}
PLUGIN.title = "Chatbox"
PLUGIN.author = "Trist"
PLUGIN.description = "Changes the default chat box"

PLUGIN.suggestions = {}

if (CLIENT) then
    --make sure the tab closes when it needs to
    if (!autobox.OnChatText) then
        autobox.OnChatText = chat.AddText
    end
    function chat.AddText(...)
        local args = {...}
        if (type(args[1]) ==  "table" and !IsColor(args[1])) then
            table.remove(args[1])
            autobox.OnChatText(unpack(args))
        else
            autobox.OnChatText(...)
        end
    end
end

--temp evolve code
function PLUGIN:HUDPaint()
	if ( self.Chat ) then
		local x, y = chat.GetChatBoxPos()
		x = x + ScrW() * 0.03875
		y = y + ScrH() / 4 + 5

		surface.SetFont( "ChatFont" )

		for _, v in ipairs( self.suggestions ) do
			local sx, sy = surface.GetTextSize( v.command )

			draw.SimpleText( v.command, "ChatFont", x, y, Color( 0, 0, 0, 255 ) )
			draw.SimpleText( " " .. v.usage or "", "ChatFont", x + sx, y, Color( 0, 0, 0, 255 ) )
			draw.SimpleText( v.command, "ChatFont", x, y, Color( 255, 255, 100, 255 ) )
			draw.SimpleText( " " .. v.usage or "", "ChatFont", x + sx, y, Color( 255, 255, 255, 255 ) )

			y = y + sy
		end
	end
end
function PLUGIN:ChatTextChanged( str )
	if ( string.Left( str, 1 ) == "/" or string.Left( str, 1 ) == "!" or string.Left( str, 1 ) == "@" ) then
		local com = string.sub( str, 2, ( string.find( str, " " ) or ( #str + 1 ) ) - 1 )
		self.suggestions = {}

		for _, v in pairs( autobox.plugins ) do
			if ( v.command and string.sub( v.command, 0, #com ) == string.lower( com ) and #self.suggestions < 4 ) then table.insert( self.suggestions, { command = string.sub( str, 1, 1 ) .. v.command, usage = v.usage or "" } ) end
		end
		table.SortByMember( self.suggestions, "command", function( a, b ) return a < b end )
	else
		self.suggestions = {}
	end
end

function PLUGIN:OnChatTab( str )
	if ( string.match( str, "^[/!][^ ]*$" ) and #self.suggestions > 0 ) then
		return self.suggestions[1].command .. " "
	end
end
function PLUGIN:StartChat() self.Chat = true end
function PLUGIN:FinishChat() self.Chat = false end

--rank names
function PLUGIN:OnPlayerChat( ply, txt, teamchat, dead )

    local tab = {}
    table.insert( tab, color_white )
    table.insert( tab, "(" .. autobox:GetRankInfo(ply:AAT_GetRank()).RankName .. ") " )


    if ( IsValid( ply ) ) then
        table.insert( tab, autobox:HexToColor(autobox:GetRankInfo(ply:AAT_GetRank()).Color) or team.GetColor( ply:Team() ) )
        table.insert( tab, ply:Nick())
    else
        table.insert( tab, "Console" )
    end
    table.insert( tab, Color( 255, 255, 255 ) )
    table.insert( tab, ": " .. txt )

    chat.AddText( unpack( tab ) )

    return true
end



--[[

--Chat Autocomplete
function PLUGIN:ChatTextChanged(str)
    self.suggestions = {}
    if ( (string.Left(str,1) ==  "/") or (string.Left(str,1) ==  "!") or (string.Left(str,1) ==  "@") ) then
        local com = string.sub(str,2,(string.find(str," ") or (#str + 1)) - 1)
        for _,v in pairs(autobox.plugins) do
            if (v.command and string.sub(v.command,0,#com) ==  string.lower(com) and #self.suggestions < 4) then
                table.insert(self.suggestions,{command = string.sub(str,1,1) .. v.command,usage = v.usage or ""})
            end
        end
        table.SortByMember(self.suggestions,"command",function(a,b) return a < b end)
    end
end
function PLUGIN:OnChatTab(str)
    if ( string.match( str, "^[/!][^ ]*$" ) and #self.suggestions > 0 ) then
        return self.suggestions[1].command .. " "
    end
end

--Rank Names
function PLUGIN:OnPlayerChat(ply,txt,team,dead)
    if (GAMEMODE.IsSandboxDerived) then
        local rankData = autobox:GetRankInfo(ply:AAT_GetRank())
        local tab = {}
        local temp = {}
        temp.Player = ply
        temp.Type = "Message"
        temp.Icon = rankData.Icon
        temp.IconTooltip = rankData.RankName
        table.insert(tab,temp)
        --table.insert(tab,color_white)
        --table.insert(tab,"("..autobox:GetRankInfo(ply:AAT_GetRank()).RankName..") ")
        if (IsValid(ply)) then
            table.insert(tab,autobox:HexToColor(rankData.Color) or color_white)
            table.insert(tab,ply:Nick())
        else
            table.insert(tab,"Console")
        end
        table.insert(tab,color_white)
        table.insert(tab,": " .. txt)
        chat.AddText(unpack(tab))
        return true
    end
end
]]

autobox:RegisterPlugin(PLUGIN)