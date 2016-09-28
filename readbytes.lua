-- readbytes.lua

-- min or win, since there are a couple dependencies
OS="min"

io.write("Hey there, welcome to the raw byte processing plant!\n");
io.write("To get started, enter the name of the file with raw bytes:\n\n");


local fileName=io.read("*l");

local dump;
if(OS=="win") then
	dump=assert(io.open(fileName,"rb"),"Error, couldn't open the byte file");
else
	dump=assert(fs.open(fileName,"r"),"Error, couldn't open the byte file");
end

local bytes={}

if(OS=="win") then
	repeat
		local byteString=dump:read(3);
		bytes[#bytes+1]=tonumber(byteString);
	until not byteString
else
	byteString=dump.readAll();

	for str in byteString:gmatch("%d%d%d") do
		bytes[#bytes+1]=str
	end
end

if(OS=="win") then
	dump:close();
else
	dump.close();
end

-- data offsets in bmp files, +1 since lua indexes at 1
BMPSIZE=2		+1
PIXELADDR=10	+1
BMPWIDTH=18		+1
BMPHEIGHT=22	+1

-- multiplying results by 256 since they are multi
-- byte values

local size=(bytes[BMPSIZE]
	+bytes[BMPSIZE+1]*256
	+bytes[BMPSIZE+2]*256*256
	+bytes[BMPSIZE+3]*256*256*256);
local pixelArrAddr=bytes[PIXELADDR]
	+bytes[PIXELADDR+1]*256
	+bytes[PIXELADDR+2]*256*256
	+bytes[PIXELADDR+3]*256*256*256+1;
local bmpWidth=bytes[BMPWIDTH]
	+bytes[BMPWIDTH+1]*256
	+bytes[BMPWIDTH+2]*256*256
	+bytes[BMPWIDTH+3]*256*256*256;
local bmpHeight=bytes[BMPHEIGHT]
	+bytes[BMPHEIGHT+1]*256
	+bytes[BMPHEIGHT+2]*256*256
	+bytes[BMPHEIGHT+3]*256*256*256;
local padAmount=bmpWidth%4;

-- simple pixel object
Pixel={x=0,y=0,Re=0,Gr=0,Bl=0}
function Pixel:new(o) return {x=0,y=0,re=0,gr=0,bl=0} end

-- convert pixel bytes into useful data; position and RGB color

local pixels={};
local currX,currY=0,0;

local i=pixelArrAddr;
while i<size do
	if i%10000==0 then sleep(0) end
	
	local curr=Pixel:new();
	
	-- get data from palette
	local colorIndex=bytes[i]+1;
	curr.bl=bytes[colorIndex];
	curr.gr=bytes[colorIndex+1];
	curr.re=bytes[colorIndex+2];
	
	curr.x=currX;
	curr.y=currY;
	
	--io.write(i.." "..colorIndex.."\n");
	
	pixels[#pixels+1]=curr;
	
	-- io.write("x: %d, y: %d, RGB: %02x%02x%02x\n",curr.x,curr.y,curr.re,curr.gr,curr.bl);
	
	currX=currX+1;
	i=i+1;
	
	-- at the end of the scan line, move to next line
	-- and increase i to account for padded bytes
	
	if(currX>=bmpWidth) then 
		currX=0;
		currY=currY+1;
		i=i+padAmount;
	end
	
end

--[[for k,v in pairs(pixels) do
	io.write(string.format("x: %d, y: %d, RGB: %02x%02x%02x\n",v.x,v.y,v.re,v.gr,v.bl));
end]]


-- now, time to draw on the screen

-- this is in mc only
if OS~="win" then
	local glass=peripheral.wrap("right");
	
	local offsetX,offsetY=5,90;
	
	for k,v in pairs(pixels) do
		local rgb=v.re*256*256+v.gr*256+v.bl;
		glass.addBox(offsetX+v.x,offsetY-v.y,1,1,rgb,1);
	end
	
	glass.sync();
end


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