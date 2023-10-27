scope()
setModule('util')

-- does nothing, just reads a value for the sake of reading it
function see(x)
end

-- false, nil, '', {}, []
function blank(o)
    if type(o) == "table" then
        return #o == 0
    else
        return (o == false) or (o == nil) or (o == '')
    end
end

-- not blank
function present(o)
    return not util.blank(o)
end

function indexOf(array, value)
    for i, v in pairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end