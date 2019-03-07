--prop protection and the likes

for _,v in ipairs({"PlayerSpawnedProp","PlayerSpawnedEffect","PlayerSpawnedRagdoll"}) do
    hook.Add(v,"AAT_MarkEnts",function(ply,model,ent) ent:SetNWString("AAT_Owner",ply:SteamID()) end)
end

for _,v in ipairs({"PlayerSpawnedSENT","PlayerSpawnedNPC","PlayerSpawnedVehicle"}) do
    hook.Add(v,"AAT_MarkEnts",function(ply,ent) ent:SetNWString("AAT_Owner",ply:SteamID()) end)
end
