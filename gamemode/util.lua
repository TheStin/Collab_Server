function STFormatNum(n) --Thank you DarkRP<3
	if (!n) then
		return 0
	end
	n = tonumber(n)
	//if n >= 1e14 then return tostring(n) end
    n = tostring(n)
    sep = sep or ","
    local dp = string.find(n, "%.") or #n+1
	for i=dp-4, 1, -3 do
		n = n:sub(1, i) .. sep .. n:sub(i+1)
    end
    return n
end