-- readbmp.lua

KB=1024

local picName=arg[1]
local pic=assert(io.open(picName,"rb"),"Error, could not open picture");

local bytes={};

repeat
	local byteString=pic:read(4*KB);
	for bite in (byteString or ''):gmatch('.') do
		bytes[#bytes+1]=bite:byte();
	end
until not byteString

pic:flush();
pic:close();

local byteDump=assert(io.open("bytedump.txt","wb"),"Error, could not open output file");

for k,v in pairs(bytes) do
	byteDump:write(string.format("%03d",v));
end

byteDump:flush();
byteDump:close();

--[[
local i=0

for k,v in pairs(bytes) do
	if(i%16==0) then
		io.write(string.format("%08x: ",i));
	end
		

	io.write(string.format("%02X ",v));
	
	i=i+1;
	if(i%16==0) then
		io.write("\n");
	elseif(i%8==0) then
		io.write("- ");
	end
end


]]