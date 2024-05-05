local title = [[
               _
  ___ ___     | |_ _ __ ___  ___
 / __/ __|____| __| '__/ _ \/ _ \
| (_| (_|_____| |_| | |  __/  __/
 \___\___|     \__|_|  \___|\___|
       / _| __ _ _ __ _ __ ___
 _____| |_ / _` | '__| '_ ` _ \
|_____|  _| (_| | |  | | | | | |
      |_|  \__,_|_|  |_| |_| |_|
]]

-------------
-- GLOBALS --
-------------

PARAMS = {}

---------------
-- FUNCTIONS --
---------------

-- turns the turtle around 180 degrees
local function turn_around()
	turtle.turnRight()
	turtle.turnRight()
end

-- moves the turtle forward by amount blocks
local function move_forward(amount)
	for _ = 1, amount, 1 do
		turtle.forward()
	end
end

-- plants a sapling in front of the turtle
local function plant_sapling()
	-- select the first slot (saplings) if not already selected
	if turtle.getSelectedSlot() ~= 1 then
		turtle.select(1)
	end
	turtle.place()
end

-- digs in all four directions around the turtle
local function dig_around()
	for _ = 1, 4, 1 do
		if turtle.detect() then
			turtle.dig()
		end
		turtle.turnRight()
	end
end

-- fells the tree in front of the turtle and returns it to its starting position
local function fell_tree()
	turtle.dig()
	turtle.forward()

	local times_moved_up = 0
	while turtle.detectUp() do
		turtle.digUp()
		turtle.up()
		times_moved_up = times_moved_up + 1
		dig_around()
	end

	for _ = 1, times_moved_up, 1 do
		-- just in case a new tree growing blocks the turtle from coming back down
		if turtle.detectDown() then
			turtle.digDown()
		end
		turtle.down()
	end

	turtle.back()
end

-- if there is no block in front of the turtle then plant a sapling
-- if there is a log then start felling the tree it belongs to
-- and plant a new sapling afterwards
local function handle_front()
	local ok, item_data = turtle.inspect()
	if not ok then
		plant_sapling()
	elseif string.find(item_data.name, "log") then
		fell_tree()
		plant_sapling()
	end
end

-- move to the next (right) row from the turtle's perspective
local function move_to_right_row()
	turtle.forward()
	turtle.turnRight()
	move_forward(3)
	turtle.turnRight()
end

-- move to the next (left) row from the turtle's perspective
local function move_to_left_row()
	turtle.forward()
	turtle.turnLeft()
	move_forward(3)
	turtle.turnLeft()
end

-- farm one row of trees
local function farm_single_row()
	-- step forward
	-- turn left and handle whatever is in front
	-- turn around and repeat
	-- turn left again
	for _ = 1, PARAMS.row_length, 1 do
		turtle.forward()
		turtle.turnLeft()
		handle_front()
		turn_around()
		handle_front()
		turtle.turnLeft()
	end
end

local function farm_double_row()
	farm_single_row()
	move_to_right_row()
	farm_single_row()
end

-- returns the turtle to the start (in front of the chest)
-- the distance to the start is 3 (for the first row) + 6 for every subsequent double row
local function return_to_chest()
	local distance_to_start = 3 + (PARAMS.double_rows - 1) * 6
	turtle.forward()
	turtle.turnRight()
	move_forward(distance_to_start)
	turtle.turnLeft()
end

-- iterates over all slots aside from the first one (which is for saplings)
-- drops the items into the chest the turtle is facing
local function unload_items()
	for slot = 2, 16, 1 do
		if turtle.getItemCount(slot) > 0 then
			turtle.select(slot)
			turtle.drop()
		end
	end
	turtle.select(2)
end

-------------------------
-- PROGRAM STARTS HERE --
-------------------------

-- print title
term.clear()
-- textutils.slowPrint(title, 100)
print(title)

-- startup checks
-- check that a chest is behind the turtle
turn_around()
local ok, item_data = turtle.inspect()

if not (ok and string.find(item_data.name, "chest")) then
	printError("There must be a chest behind me! Exiting...")
	return
end
turn_around()

-- check that the turtle is fueled and warn if the fuel level is < 1000
local fuel_level = turtle.getFuelLevel()
if fuel_level <= 0 then
	printError("I don't have any fuel! Exiting...")
	return
elseif fuel_level < 1000 then
	print("WARNING: Low fuel level")
end

-- check that there are saplings in the first slot
turtle.select(1)
local item_detail = turtle.getItemDetail()
if not (item_detail and string.find(item_detail.name, "sapling")) then
	printError("I need saplings in the first slot! Exiting...")
	return
end

-- read and store the run parameter

write("Number of (double) rows to plant: ")
PARAMS.double_rows = tonumber(read())

write("Length of one row: ")
PARAMS.row_length = tonumber(read())

-- iterate until terminated
while true do
	for i = 1, PARAMS.double_rows, 1 do
		farm_double_row()
		if i < PARAMS.double_rows then
			move_to_left_row()
		end
	end
	return_to_chest()
	unload_items()
	turn_around()
end
