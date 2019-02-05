--Everything having to do with time management
if(SERVER)then
    hook.Add("PlayerDisconnected","AAT_TimeSave",function(ply)
        autobox:SQL_UpdateLastJoin(ply,autobox:SyncTime())
        autobox:SQL_UpdatePlaytime(ply,ply:AAT_GetPlaytime())
    end)
    timer.Create( "AAT_PlaytimeSave", 60, 0, function()
        for _, ply in ipairs( player.GetAll() ) do
            autobox:SQL_UpdateLastJoin(ply,autobox:SyncTime())
            autobox:SQL_UpdatePlaytime(ply,ply:AAT_GetPlaytime())
			ply.Playtime = ply:AAT_GetPlaytime()
			ply.LastSave = autobox:SyncTime()
			autobox:SyncPlaytime()
        end
    end)
end
local AAT_Player = FindMetaTable("Player")
function AAT_Player:AAT_GetPlaytime()
    return math.floor((self.Playtime or 0) + autobox:SyncTime() - (self.LastSave or 0))
end
function autobox:FormatTime(t)
	if ( t < 0 ) then
		return "Forever"
	elseif ( t < 60 ) then
		if ( t == 1 ) then return "one second" else return t .. " seconds" end
	elseif ( t < 3600 ) then
		if ( math.ceil( t / 60 ) == 1 ) then return "one minute" else return math.ceil( t / 60 ) .. " minutes" end
	elseif ( t < 24 * 3600 ) then
		if ( math.ceil( t / 3600 ) == 1 ) then return "one hour" else return math.ceil( t / 3600 ) .. " hours" end
	elseif ( t < 24 * 3600 * 7 ) then
		if ( math.ceil( t / ( 24 * 3600 ) ) == 1 ) then return "one day" else return math.ceil( t / ( 24 * 3600 ) ) .. " days" end
	elseif ( t < 24 * 3600 * 30 ) then
		if ( math.ceil( t / ( 24 * 3600 * 7 ) ) == 1 ) then return "one week" else return math.ceil( t / ( 24 * 3600 * 7 ) ) .. " weeks" end
	else
		if ( math.ceil( t / ( 24 * 3600 * 30 ) ) == 1 ) then return "one month" else return math.ceil( t / ( 24 * 3600 * 30 ) )  .. " months" end
	end
end
if(SERVER)then
	util.AddNetworkString("AAT_TimeSync")
	util.AddNetworkString("AAT_PlaytimeSync")

	function autobox:SyncPlaytime()
		net.Start("AAT_PlaytimeSync")
			local playerData = {}
				for _,v in ipairs(player.GetAll())do
					table.insert(playerData,{SteamID = v:SteamID(),Playtime = v.Playtime or 0,LastJoin = v.LastJoin or 0,LastSave = v.LastSave or 0})
				end
			net.WriteTable(playerData)
		net.Broadcast()
	end
	timer.Create("AAT_SyncPlaytime",60,0,autobox.SyncPlaytime)

	net.Receive("AAT_TimeSync",function(len,ply)
		net.Start("AAT_TimeSync")
		net.WriteInt(os.time(),32)
		net.Send(ply)
	end)
	function autobox:SyncTime() -- added so it can be a shared function
		return os.time()
	end
end
if(CLIENT)then
	function autobox:SyncTime()
		if(!autobox.timeSync)then
			net.Start("AAT_TimeSync")
			net.SendToServer()
			return os.time()
		end
		return os.time() - autobox.timeSync
	end
	net.Receive("AAT_TimeSync",function(len,ply)
		autobox.timeSync = os.time() - net.ReadInt(32)
	end)
	net.Receive("AAT_PlaytimeSync",function()
		local playerData = net.ReadTable()
		local players = player.GetAll()
		for _,v in pairs(playerData)do
			for k,p in ipairs(players)do
				if(v.SteamID==p:SteamID())then
					p.Playtime = v.Playtime
					p.LastJoin = v.LastJoin
					p.LastSave = v.LastSave
					table.remove(players,k)
					break
				elseif(p:SteamID()=="NULL" && v.SteamID == "BOT")then
					p.Playtime = v.Playtime
					p.LastJoin = v.LastJoin
					p.LastSave = v.LastSave
					table.remove(players,k)
					break
				end
			end
		end
	end)
end
