-----
-- Vote mode
-----

local PLUGIN = {}
PLUGIN.title = "Vote Mode"
PLUGIN.author = "Trist"
PLUGIN.description = "Allows you to vote for the gamemode"
PLUGIN.command = "votemode"

PLUGIN.options = {"War","Build"}

if (SERVER) then
    util.AddNetworkString("AAT_VoteMode")
    util.AddNetworkString("AAT_VoteModeEnd")
    net.Receive("AAT_VoteMode",function(len,ply)
        if (!ply.AAT_VotedMode) then
            local option = net.ReadInt(4)
            PLUGIN.Votes[option] = PLUGIN.Votes[option] + 1
            ply.AAT_VotedMode = true
            PLUGIN.VotingPlayers = PLUGIN.VotingPlayers + 1
            if ( PLUGIN.VotingPlayers >= #player.GetAll() ) then
                timer.Remove("AAT_VoteModeEnd")
                PLUGIN:VoteEnd()
            end
        end
    end)
end

function PLUGIN:Call(ply)
    print(self.cooldown)
    if ((self.cooldown or 0) < CurTime()) then
        self.cooldown = CurTime() + 600 --10 minute cooldown
        self.Votes = {}
        self.Votes[1] = 0
        self.Votes[2] = 0
        self.VotingPlayers = 0

        for _,v in ipairs(player.GetAll()) do
            v.AAT_VotedMode = false
        end

        net.Start("AAT_VoteMode")
        net.Broadcast()
        autobox:Notify( autobox.colors.blue, ply:Nick(), autobox.colors.white, " has called a ", autobox.colors.red, "Mode Vote", autobox.colors.white, "." )

        timer.Create("AAT_VoteModeEnd",10,1,function() PLUGIN:VoteEnd() end)
    else
        autobox:Notify( ply, autobox.colors.red, "Please wait ", autobox.colors.white, autobox:FormatTime(math.floor(self.cooldown - CurTime())), autobox.colors.red, "before starting another mode vote." )
    end
end

if ( CLIENT ) then
    net.Receive("AAT_VoteMode",function()
        PLUGIN:ShowVoteMenu()
    end)
    net.Receive("AAT_VoteModeEnd",function()
        if (PLUGIN.VoteWindow and PLUGIN.VoteWindow.Close) then PLUGIN.VoteWindow:Close() end
    end)
end

function PLUGIN:ShowVoteMenu()
    self.VoteWindow = vgui.Create("DFrame")
    self.VoteWindow:SetSize(200,95)
    self.VoteWindow:Center()
    self.VoteWindow:SetTitle("Vote Mode")
    self.VoteWindow:SetDraggable(false)
    self.VoteWindow:ShowCloseButton(false)
    self.VoteWindow:SetBackgroundBlur(true)
    self.VoteWindow:MakePopup()

    local optionlist = vgui.Create("DPanelList",self.VoteWindow)
    optionlist:SetPos(5,25)
    optionlist:SetSize(190,65)
    optionlist:SetPadding(5)
    optionlist:SetSpacing(5)

    for i, option in ipairs( self.options ) do
        local votebut = vgui.Create( "DButton" )
        votebut:SetText( option )
        votebut:SetTall( 25 )
        function votebut.DoClick()
            net.Start("AAT_VoteMode")
            net.WriteInt(i,4)
            net.SendToServer()
            self.VoteWindow:Close()
        end
        optionlist:AddItem( votebut )
    end
end

function PLUGIN:VoteEnd()
    net.Start("AAT_VoteModeEnd")
    net.Broadcast()

    local msg = ""
    local resultset = {}
    for i = 1, #self.options do
        local percent
        if ( table.Count( self.Votes ) == 0 ) then percent = 0 else percent = math.Round( ( self.Votes[i] or 0 ) / self.VotingPlayers * 100 ) end

        resultset[i] = percent

        msg = msg .. self.options[i] .. " (" .. percent .. "%)"

        if ( i == #self.options - 1 ) then
            msg = msg .. " and "
        elseif ( i != #self.options ) then
            msg = msg .. ", "
        end
    end

    if (resultset[1] != 50) then
    --Makes sure there was no tie.
        if (resultset[1] > resultset[2]) then
        --War Mode won the vote.
        RunConsoleCommand( "sbox_godmode", 0 )
        RunConsoleCommand( "sbox_noclip", 0 )

        autobox.silentNotify = true
            autobox:CallPlugin("noclip",ents.Create(""),"*",0)
        autobox.silentNotify = false

        else
        --Build Mode won the vote.
        RunConsoleCommand( "sbox_godmode", 1 )
        RunConsoleCommand( "sbox_noclip", 1 )
        end
    end

    autobox:Notify( autobox.colors.red, "Vote Mode" .. " ", autobox.colors.white, msg .. "." )

end

autobox:RegisterPlugin(PLUGIN)