scope()
setModule('util')

function countBy(t, test)
    local count = 0
    for _, value in pairs(t) do
        if test(value) then
            count = count + 1
        end
    end
    return count
end