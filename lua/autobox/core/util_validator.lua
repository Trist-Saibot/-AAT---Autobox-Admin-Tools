--Shortcuts plugins can use to validate input
--allows for more consistency

function autobox:ValidatePerm(ply,perm)
    if (!ply:IsValid() or ply:AAT_HasPerm(perm)) then
        return true
    else
        autobox:Notify(ply,autobox.chatConst.err,autobox.colors.red,autobox.chatConst.notallowed)
        return false
    end
end

function autobox:ValidateSingleTarget(ply,players)
    if (!autobox:ValidateHasTarget(ply,players)) then return false end
    if (#players <= 1) then
        return true
    else
        autobox:Notify(ply,autobox.chatConst.err,autobox.colors.white,"Did you mean ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,"?")
        return false
    end
end

function autobox:ValidateHasTarget(ply,players)
    if (#players > 0) then
        return true
    else
        autobox:Notify(ply,autobox.chatConst.err,autobox.colors.red,autobox.chatConst.noplayers)
        return false
    end
end

function autobox:ValidatePlayerFound(ply,target)
    if (target) then
        return true
    else
        autobox:Notify(ply,autobox.chatConst.err,autobox.colors.red,autobox.chatConst.noplayers)
        return false
    end
end

function autobox:ValidateBetterThan(ply,target)
    if (!ply:IsValid() or ply:AAT_BetterThan(target)) then
        return true
    else
        autobox:Notify(ply,autobox.chatConst.err,autobox.colors.red,autobox.chatConst.notallowed)
        return false
    end
end

function autobox:ValidateBetterThanOrEqual(ply,target)
    if (!ply:IsValid() or ply:AAT_BetterThanOrEqual(target)) then
        return true
    else
        autobox:Notify(ply,autobox.chatConst.err,autobox.colors.red,autobox.chatConst.notallowed)
        return false
    end
end

function autobox:ValidateNumber(ply,value)
    if (tonumber(value)) then
        return true
    else
        autobox:Notify(ply,autobox.chatConst.err,autobox.colors.red,"The value must be a number!")
        return false
    end
end
