-- WARNING --
-- This script should only be used in combination with the Doors Room Dumper.
-- This script was made to rename rooms from numbers to their original names
-- USAGE: insert all your rooms into the ServerStorage->Rooms
-- and run this script in the command bar.

local Rooms = (game:GetService("ServerStorage"):WaitForChild("Rooms")); -- Gets the ServerStorage->Rooms folder.

for _, Room in next, Rooms:GetChildren(), nil do -- Iterates through the Rooms folder.
	Room.Name = ("" .. Room:GetAttribute("RawName")) -- Renames the Rooms to their RawName attribute.
end; -- Ends the for loop.

-- SCRIPT END --
