local addonName, ZRA = ...

ZRA.SHAPES = {
	skull = true,
	x = true,
	square = true,
	moon = true,
	triangle = true,
	diamond = true,
	circle = true,
	star = true,
}

function ZRA.shape(s)
	if ZRA.SHAPES[string.lower(s)] then
		return '{' .. s .. '}'
	else
		return s
	end
end

function ZRA.dump(o)
	if type(o) == 'table' then
		 local s = '{ '
		 for k,v in pairs(o) do
				if type(k) ~= 'number' then k = '"'..k..'"' end
				s = s .. '['..k..'] = ' .. ZRA.dump(v) .. ','
		 end
		 return s .. '} '
	else
		 return tostring(o)
	end
end


function ZRA.shallowcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
			copy = {}
			for orig_key, orig_value in pairs(orig) do
					copy[orig_key] = orig_value
			end
	else -- number, string, boolean, etc
			copy = orig
	end
	return copy
end

function ZRA.modulo(a,b)
	return a - math.floor(a/b)*b
end

function ZRA.tablelen(t)
	local numItems = 0
	for k,v in pairs(t) do
		numItems = numItems + 1
	end
	return numItems
end

function ZRA.deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            setmetatable(copy, ZRA.deepcopy(getmetatable(orig), copies))
            for orig_key, orig_value in next, orig, nil do
                copy[ZRA.deepcopy(orig_key, copies)] = ZRA.deepcopy(orig_value, copies)
            end
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function ZRA.remaining(it)
	local temp = {}
	for item in it do
		table.insert(temp,item)
	end
	return temp
end

function ZRA.mysplit (inputstr, sep)
	local t={}
	local p = ''
	for i = 1, string.len(inputstr) do
		local letter = string.sub(inputstr, i, i)
		if letter == sep then
			table.insert(t, p)
			p = ''
		else
			p = p .. letter
		end
	end
	return t
end

function ZRA.dicestring(str)
	local t = {}
	for i = 1, string.len(str) do
		table.insert(t, string.sub(str, i, i))
	end
	return t
end

function ZRA.codesToValsArr(codes, hash, key)
	local vals = {}
	for _,v in ipairs(codes) do
		table.insert(vals, hash[v][key])
	end
	return vals
end

function ZRA.tablefirstkey(t)
	for k,v in pairs(t) do
		return(k)
	end
end