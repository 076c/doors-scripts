print("initiated the room dumper");

if not isfolder("DOORS_Rooms") then
    makefolder("DOORS_Rooms");
end;

if not readfile("DOORS_Rooms/README.txt") then
    writefile("DOORS_Rooms/README.txt", [[
This is the DOORS Room dumper directory.
Every room saved with the DOORS Room dumper will be here.

To get started, execute the script given and play through DOORS as normal.
To import the Rooms, head over to your game (or a baseplate) and right click 'Workspace' -> 'Insert from File' and select your desired room.

If you have the option 'SaveRoom_Beta' enabled, the names of the rooms you have saved will be written to a file and will be read from that file.

This script was made by @synapsesoftworksllc using UniversalSynSaveInstance as an instance to xml parser.
    ]])
end;

local IsSaving = false;
local RoomQueue = {};

local SaveRoom = function(room: Model, name)
    local ssi = loadstring(game:HttpGet("https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/saveinstance.luau", true))();
    ssi({ ShowStatus = false, ReadMe = false, noscripts = false, Object = room, FilePath = "DOORS_Rooms/DOORS_ROOM_" .. name });
end;
local SaveRoomsBeta = false;
-- totally not stolen from synapse :troll:
local StatusText = Instance.new("TextLabel");
StatusText.BackgroundTransparency = 1;
StatusText.Font = Enum.Font.Code;
StatusText.AnchorPoint = Vector2.new(1);
StatusText.Position = UDim2.new(1);
StatusText.Size = UDim2.new(0.3, 0, 0, 20);
StatusText.TextColor3 = Color3.new(1, 1, 1);
StatusText.TextScaled = true;
StatusText.TextStrokeTransparency = 0.7;
StatusText.TextXAlignment = Enum.TextXAlignment.Left;
StatusText.TextYAlignment = Enum.TextYAlignment.Bottom;
local StatusGui = Instance.new("ScreenGui");
StatusGui.DisplayOrder = 2e9;
StatusText.Parent = StatusGui;
local function randomString()
	local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890";local b=math.random(7,20);local c="";for i=1,b do c=c..string.char(string.byte(a,math.random(1,#a)))end return c;
end;
StatusGui.Name = randomString();
StatusText.Name = randomString();
if ({pcall(function()return game:GetService("CoreGui")end)})[1] == true then
	StatusGui.Parent = game:GetService("CoreGui");
else
	StatusGui.Parent = game:GetService("Players").LocalPlayer.PlayerGui;
end;
function updateStatus(text, color)
	StatusText.Text = text;
    if color then
        StatusText.TextColor3 = color;
    end;
end;
updateStatus("Initiated @synapsesoftworksllc's Room dumper.");
wait(1);
local CurrentRooms = assert(workspace:FindFirstChild("CurrentRooms"));
local file_stream = if SaveRoomsBeta == true then (readfile and readfile("DOORS_Rooms/saved_rooms.txt") or nil) or writefile("DOORS_Rooms/saved_rooms.txt") else nil;

local json = loadstring(game:HttpGet("https://raw.githubusercontent.com/rxi/json.lua/refs/heads/master/json.lua"))();

local SavedRooms = {};

if SaveRoomsBeta == true then
    local succ, decoded = pcall(function() return json.decode(file_stream) end);
    if succ == true then
        SavedRooms = decoded;
    else
        SavedRooms = {};
    end;
end;

function ProcessQueue()
    while #RoomQueue > 0 do
        local room = table.remove(RoomQueue, 1);
        if not (room:GetAttribute("RawName")) then
            continue;
        end;
        local RawName = (room:GetAttribute("RawName") or "UNKNOWN_ROOM_" .. room.Name);
        updateStatus(string.format("Dumping room %*", RawName));
        if SavedRooms[RawName] == true then
            continue;
        end;
        SavedRooms[RawName] = true;
        IsSaving = true;
        SaveRoom(room, RawName);
        IsSaving = false;
        if SaveRoomsBeta == true then
            writefile("DOORS_Rooms/saved_rooms.txt", json.encode(SavedRooms));
        end;
        updateStatus(string.format("Finished dumping room %*", RawName), Color3.new(0, 1));
    end;
end;

task.spawn(function()
    while true do
        if not IsSaving and #RoomQueue > 0 then
            ProcessQueue();
        end;
        task.wait();
    end;
end);

function PassRoom(room: Model)
    table.insert(RoomQueue, room);
end;

-- Call 1: Check Current Rooms

for _, Room in pairs(CurrentRooms:GetChildren()) do
    if Room == nil then
        return;
    end;
    PassRoom(Room);
end;

-- Call 2: Listen on Addition of new Rooms

CurrentRooms.ChildAdded:Connect(function(room: Model)
    PassRoom(room);
end);
