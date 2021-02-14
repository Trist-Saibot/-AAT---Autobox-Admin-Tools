-----
-- Vote restart
-----

local PLUGIN = {}
PLUGIN.title = "Vote Restart"
PLUGIN.author = "Trist"
PLUGIN.description = "Allows you to vote for a restart"
PLUGIN.command = "voterestart"

PLUGIN.options = {"Yes","No"}

if (SERVER) then
    util.AddNetworkString("AAT_VoteRestart")
    util.AddNetworkString("AAT_VoteRestartEnd")
    net.Receive("AAT_VoteRestart",function(len,ply)
        if (!ply.AAT_VotedRestart) then
            local option = net.ReadInt(4)
            PLUGIN.Votes[option] = PLUGIN.Votes[option] + 1
            ply.AAT_VotedRestart = true
            PLUGIN.VotingPlayers = PLUGIN.VotingPlayers + 1
            if ( PLUGIN.VotingPlayers >= #player.GetAll() ) then
                timer.Remove("AAT_VoteRestartEnd")
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
            v.AAT_VotedRestart = false
        end

        net.Start("AAT_VoteRestart")
        net.Broadcast()
        autobox:Notify( autobox.colors.blue, ply:Nick(), autobox.colors.white, " has called a ", autobox.colors.red, "Restart Vote", autobox.colors.white, "." )

        timer.Create("AAT_VoteRestartEnd",10,1,function() PLUGIN:VoteEnd() end)
    else
        autobox:Notify( ply, autobox.colors.red, "Please wait ", autobox.colors.white, autobox:FormatTime(math.floor(self.cooldown - CurTime())), autobox.colors.red, " before starting another restart vote." )
    end
end

if ( CLIENT ) then
    net.Receive("AAT_VoteRestart",function()
        PLUGIN:ShowVoteMenu()
    end)
    net.Receive("AAT_VoteRestartEnd",function()
        if (PLUGIN.VoteWindow and PLUGIN.VoteWindow.Close) then PLUGIN.VoteWindow:Close() end
    end)
end

function PLUGIN:ShowVoteMenu()
    self.VoteWindow = vgui.Create("DFrame")
    self.VoteWindow:SetSize(200,95)
    self.VoteWindow:Center()
    self.VoteWindow:SetTitle("Restart the Server?")
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
            net.Start("AAT_VoteRestart")
            net.WriteInt(i,4)
            net.SendToServer()
            self.VoteWindow:Close()
        end
        optionlist:AddItem( votebut )
    end
end

function PLUGIN:VoteEnd()
    net.Start("AAT_VoteRestartEnd")
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

    autobox:Notify( autobox.colors.red, "Vote Restart" .. " ", autobox.colors.white, msg .. "." )

    if (resultset[1] > resultset[2]) then
            autobox:Notify( autobox.colors.red, "The server will restart in 30 seconds." )
            timer.Simple(30,function()
                RunConsoleCommand("_restart")
            end)
    end

end

autobox:RegisterPlugin(PLUGIN)