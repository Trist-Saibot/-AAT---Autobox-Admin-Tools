--General utility functions

function autobox:BoolToInt(bool)
    if (bool) then return 1 else return 0 end
end

function autobox:KeyByValue(tbl,value,iterator)
    iterator = iterator or pairs
    for k,v in iterator(tbl) do
        if (value == v) then return k end
    end
end