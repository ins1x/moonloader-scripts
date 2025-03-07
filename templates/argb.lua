function join_argb(a, r, g, b)
   local argb = b  -- b
   argb = bit.bor(argb, bit.lshift(g, 8))  -- g
   argb = bit.bor(argb, bit.lshift(r, 16)) -- r
   argb = bit.bor(argb, bit.lshift(a, 24)) -- a
   return argb
end

function explode_argb(argb)
   local a = bit.band(bit.rshift(argb, 24), 0xFF)
   local r = bit.band(bit.rshift(argb, 16), 0xFF)
   local g = bit.band(bit.rshift(argb, 8), 0xFF)
   local b = bit.band(argb, 0xFF)
   return a, r, g, b
end

function hex_to_argb(hex)
   local a, r, g, b = explode_argb(tonumber(hex, 16))
   return a, r, g, b
end

function intToHexRgb(int)
   return string.sub(bit.tohex(int), 3, 8)
end

function intToHexArgb(int)
   return string.sub(bit.tohex(int), 1, 8)
end