-- Original author: Mark Edgar
-- Licensed under the same terms as Lua (MIT license).

local usage = [[
	Usage: bc2c input output
]]

if not arg or not #arg == 3 then
  io.stderr:write(usage)
  return
end

local name = arg[1]
local input = arg[2]
local output = arg[3]

local content = assert(io.open(input, "rb")):read("*a")

local numtab={}
local i
for i=0,255 do
	numtab[string.char(i)]=("%3d,"):format(i)
end

function dump(str)
	return (str:gsub(".", numtab):gsub(("."):rep(80), "%0\n"))
end

local template = [[
/* DO NOT EDIT */
/* code automatically generated by bc2c from %s */
static const char luabc_%s[] = {
	%s
};

inline void lua_load_%s(lua_State *L)
{
	luaL_loadbuffer(L, luabc_%s, sizeof(luabc_%s), "%s");
}
]]

assert(io.open(output, "wb")):write(string.format(template, input, name, dump(content), name, name, name, name))