-- title:   NYT Connections
-- author:  Trisha Razdan (trazdan1), Erebus Oh (eoh2)
-- desc:    Make 4 groups of 4.
-- site:    https://www.nytimes.com/games/connections
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

local tries = 0
local x = 1
local y = 1

-- list of words
-- max 6 letters
local allWords = {
	{"red", "tan", "blue", "pink"}, -- colors
	{"car", "bike", "run", "walk"}, -- transport
	{"cat", "dog", "pig", "cow"}, -- animals
	{"LA", "NYC", "DC", "PHL"}, -- cities
	{"heat", "nets", "jazz", "bulls"}, -- mascots
	{"tab", "ctrl", "esc", "fn"}, -- keys
	{"foot", "yard", "inch", "mile"}, -- units
	{"eye", "nose", "lips", "ear"}, -- body parts
	{"cut", "piece", "share", "take"}, -- profit piece
	{"dodge", "duck", "escape", "skirt"}, -- to avoid
	{"arch", "ball", "sole", "toe"}, -- foot parts
	{"come", "down", "sit", "stay"}, -- dog calls
	{"cram", "jam", "pack", "stuff"}, -- to fill
	{"peak", "peek", "peke", "pique"}, -- homophones
	{"bough", "dough", "cough", "tough"} --"-ough" words that don't sound the same
}
local allGroupNames = {
	"colors",
	"transport",
	"animals",
	"cities",
	"mascots",
	"keys",
	"units",
	"body parts",
	"profit piece",
	"to avoid",
	"foot parts",
	"dog calls",
	"to fill",
	"homophones",
	"'ough' words"
}
local numGroups = 15

local YELLOW = 69
local GREEN = 65
local BLUE = 73
local PURPLE = 129
local SELECT = 5
local BORDER_SELECT = 154 -- h=4, w=5, colorkey=11

local BLACK_COLOR = 7
local GREEN_COLOR = 5
local YELLOW_COLOR = 4
local BLUE_COLOR = 10
local PURPLE_COLOR = 1
local LIGHTGRAY_COLOR = 13

-- Initialize board, row major = (row + 4*(col - 1))
-- array of tiles
local board = {}
local chosenGroups = {}
local solvedGroups = {false, false, false, false}
local colorgroups = {YELLOW_COLOR, GREEN_COLOR, BLUE_COLOR, PURPLE_COLOR}

--x and y coords to DRAW the boxes -- same order as board
local draw_x = {48, 88, 128, 168, 48, 88, 128, 168, 48, 88, 128, 168, 48, 88, 128, 168}
local draw_y = {32, 32, 32, 32, 56, 56, 56, 56, 80, 80, 80, 80, 104, 104, 104, 104}
-- tile object, represents each word tile in the game
tile = {}
-- create tile object
function tile:new(w, newx, newy, newdx, newdy, g, g2)
	local o = {word = w, x = newx, y = newy, dx = newdx, dy = newdy, group = g, chosengroup = g2, selected = false, solved = false}
	setmetatable(o, {__index = tile})
	return o
end

-- draw tile
function tile:draw()
	-- draw word
	-- print(self.word, self.x, self.y)

	--want to color based on group #
	

	-- draw depending on selected, solved variables
	if self.selected then
		spr(SELECT,self.dx, self.dy, 11, 1, 0, 0, 4, 4)
		print(self.word, self.dx , self.dy, 1, false, 1, true)
	else 
		spr(133,self.dx, self.dy, 11, 1, 0, 0, 4, 4)
		print(self.word, self.dx , self.dy, 1, false, 1, true)
	end

	if self.solved then
		if (self.group == chosenGroups[1]) then
			spr(YELLOW, self.dx, self.dy, 11, 1, 0, 0, 4, 4)
		elseif (self.group == chosenGroups[2]) then
			spr(GREEN, self.dx, self.dy, 11, 1, 0, 0, 4, 4)

		elseif (self.group == chosenGroups[3]) then
			spr(BLUE, self.dx, self.dy, 11, 1, 0, 0, 4, 4)
		else
			spr(PURPLE, self.dx, self.dy, 11, 1, 0, 0, 4, 4)
		end
		
	end
end

--separate so can call once board and words are initialized
-- print(text x=0 y=0 color=15 fixed=false scale=1 smallfont=false)
function tile:printWord()
	if self.solved and self.group == chosenGroups[4] then
		print(self.word, self.dx, self.dy, LIGHTGRAY_COLOR, false, 1, true) -- if solved purple group, draw word in light gray to see better
	else
		print(self.word, self.dx, self.dy, BLACK_COLOR, false, 1, true)
	end
end
function tile:newWord(w, g, g2)
	self.word = w
	self.group = g
	self.chosengroup = g2
end

function inArray(val)
	for i,va in ipairs(chosenGroups) do
		if val == va then
			return true
		end
	end
	return false
end

function swapTiles(ind1, ind2)
	local tempword = board[ind1].word
	local tempg = board[ind1].group
	local tempg2 = board[ind1].chosengroup

	board[ind1]:newWord(board[ind2].word, board[ind2].group, board[ind2].chosengroup)
	board[ind2]:newWord(tempword, tempg, tempg2)

end

function shuffleBoard()
	for i=16,1,-1 do
		local randInd = math.random(1, i)
		swapTiles(i, randInd)
	end
end

function initBoard()
	local randGroup = -1

	for i=1,4 do
		while randGroup == -1 or inArray(randGroup) do
			randGroup = math.random(1, numGroups)
		end
		chosenGroups[i] = randGroup
		for j=1,4 do
			index = i + 4*(j-1)
			board[index] = tile:new(allWords[randGroup][j], i, j, draw_x[index], draw_y[index], randGroup, i)
		end
	end

	shuffleBoard()
end

function drawSelect(x, y) --call when selecting word
	-- turns tile into a darker grey to select them
	spr(5, x, y, 11, 1, 0, 0, 4, 4)
end
function drawBorder(x, y)
	spr(136, x, y, 11, 1, 0, 0, 8, 8)
end

function moveSelection()
	if btnp(4) then	
		drawSelect(select_x, select_y)
	end
end

local numSelected = 0
function getSelected()
	local sels = {}
	local counter = 1
	for i,t in ipairs(board) do
		if t.selected == true then
			sels[counter] = t
			counter = counter + 1
		end
	end
	numSelected = counter -1
	return sels
end

function checkSelected()
	local sels = getSelected()
	local g = sels[1].group
	for i,t in ipairs(sels) do
		if g ~= t.group then
			return false
		end
	end
	return true
end

function checkWin()
	for i,t in ipairs(board) do
		if not t.solved then
			return false
		end
	end
	return true
end

local select_x = 59
local select_y = 44

function moveArrow() -- want to use new cube's x and y
	--directional movement
	-- controls for select
	if btnp(0) then -- up
		if select_y ~= 44 then
			select_y = select_y - 24
			x =  x - 1
		end
		--spr(136, select_x, selectspr()
		--spr(136, select_x, select_y, 11, 1, 0, 0, 8, 8)
	elseif btnp(1) then -- down
		if select_y ~= 116 then
			select_y = select_y + 24
			x = x + 1
		end
	elseif btnp(2) then --left
		if select_x ~= 59 then
			select_x = select_x - 38
			y = y-1
		end
		--spr(136, select_x, select_y, 11, 1, 0, 0, 8, 8)
	elseif btnp(3) then -- right
		if select_x ~= 173 then
			select_x = select_x + 38
			y = y + 1
		end
	end
	

end

function setUpScreen() 
	map(0,0, 30, 17)
	print("Welcome to Connections!", 55, 8, 1, false, 1, false)
	print("Make 4 groups of 4.",80, 16, 1, false, 1, true) 
	print("Select", 2, 5, 1 , false, 1, false)
	print("X", 15, 11, BLACK_COLOR, false, 1, false)
	print("Submit", 2, 25, 1, false, 1, false)
	print("Z", 15, 31, BLACK_COLOR, false, 1, false)
	print("Move", 2, 45, 1, false, 1, false)
	print("Arrow Keys", 2, 51, BLACK_COLOR, false, 1, true)
	--print("Move", 2, 25, 1, false, 1, false)
	--print("Arrow Keys", 2, 30, 1, false, 1, true)
end

function drawTries()
	local ycord = 105
	print("Tries", 8, ycord, 1, false, 1, false)
	print(tries, 18, ycord + 7, 1, false, 1, false)
end

function drawGroupNames()
	for i,t in ipairs(chosenGroups) do
		if solvedGroups[i] then
			print(allGroupNames[t], 5 + (60*(i - 1)), 130, colorgroups[i], false, 1, true)
		end
		
	end
end

function resetGame()
	select_x = 59
	select_y = 44
	x = 1
	y = 1
	tries = 0
	solvedGroups = {false, false, false, false}
	setUpScreen()
	initBoard()
end
local state = "welcome"
local win = false



function TIC()
	--col x coords: 49, 89, 129, 169
	--row y coords: 37, 62, 85, 110
	-- x boundary: 24, 64, 104, 144
	-- y boundary: 16, 40, 64,+box_diff_y

	-- STATE TRANSITIONS
	if (state == "welcome") then
		if btnp(4) then -- Z key, A button
			state = "game"
			resetGame()
		end	
	elseif (state == "game") then
		-- check win condition
		if win then
			state = "gameover"
		end

	elseif (state == "gameover") then
		if btnp(4) then -- Z key, A button
			resetGame()
			state = "game"
		end
	end

	-- STATE ACTIONS
	if(state == "welcome") then
		map(060, 0, 30, 17)
		print("NYT Connections", 80, 35, 12, false, 1, false)
		print("By Ere and Trisha", 90, 50, 12, false, 1, true)
		print("Press Z to play", 96, 102, 12, false, 1, true)

	elseif (state == "game") then
		local currentTileIndex =  y + 4*(x-1)
		moveArrow()
		setUpScreen()
		
		-- get all selected tiles
		local sels = getSelected()
		--print(numSelected, 210, 70)
		-- select a word, X button
		if btnp(5) then
			if board[currentTileIndex].selected then
				board[currentTileIndex].selected = false
			elseif (numSelected < 4 and not board[currentTileIndex].solved) then
				-- select/unselect current tile
				board[currentTileIndex].selected = true
				
			end
		end

		-- check selected group of 4 moveArrow()(Z button)
		if btnp(4) and numSelected == 4 then
			if checkSelected() then
				local j = sels[1].chosengroup
				solvedGroups[j] = true
				for i,s in ipairs(sels) do
					s.solved = true
					s.selected = false
					--print("Hello", 200, 50)
				end
			else
				tries = tries + 1
			end
		end
		
		
		-- draw board + words
		for i,t in ipairs(board) do
			board[i]:draw()
			board[i]:printWord()
		end
		
		
		--`spr(id x y colorkey=-1 scale=1 flip=0 rotate=0 w=1 h=1)`
		-- draw tries counter
		drawTries()

		-- draw group names (if solved)
		drawGroupNames()

		-- draw selection arrow
		spr(12, select_x, select_y, 0, 1, 3, 2,1, 1)
		
		--spr(136, select_x, select_y, 11, 1, 0, 0, 8, 8)
		win = checkWin()

		-- debug statements
		--print(board[1].dx, 5, 10)
		--print(board[1].dy, 5, 20)

		--print(win, 5, 30)

		--print(chosenGroups[1], 200, 5)
		---print(chosenGroups[2], 200, 15)
		--print(chosenGroups[3], 200, 25)
		--print(chosenGroups[4], 200, 35)

	elseif (state == "gameover") then
		setUpScreen()
		for i,t in ipairs(board) do
			board[i]:draw()
			board[i]:printWord()
		end
		drawTries()
		drawGroupNames()
		print("Solved!", 200, 25, 1, false, 1, false)
		print("Press Z", 200, 45, 1, false, 1, false)
		print("for new", 200, 55, 1, false, 1, false)
		print("game", 200, 65, 1, false, 1, false)
	end

end

-- <TILES>
-- 000:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 001:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 005:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 006:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 007:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 008:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 012:000ff000000ff00000ffff000ffffff0ffffffff000ff000000ff000000ff000
-- 016:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 017:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 021:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 022:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 023:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 024:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 037:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 038:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 039:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 040:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 053:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 054:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 055:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 056:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 065:5555555555555555555555555555555555555555555555555555555555555555
-- 066:5555555555555555555555555555555555555555555555555555555555555555
-- 067:5555555555555555555555555555555555555555555555555555555555555555
-- 068:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 069:4444444444444444444444444444444444444444444444444444444444444444
-- 070:4444444444444444444444444444444444444444444444444444444444444444
-- 071:4444444444444444444444444444444444444444444444444444444444444444
-- 072:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 073:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 074:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 075:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 076:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 081:5555555555555555555555555555555555555555555555555555555555555555
-- 082:5555555555555555555555555555555555555555555555555555555555555555
-- 083:5555555555555555555555555555555555555555555555555555555555555555
-- 084:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 085:4444444444444444444444444444444444444444444444444444444444444444
-- 086:4444444444444444444444444444444444444444444444444444444444444444
-- 087:4444444444444444444444444444444444444444444444444444444444444444
-- 088:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 089:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 090:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 091:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 092:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 097:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 098:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 099:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 100:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 101:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 102:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 103:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 104:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 105:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 106:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 107:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 108:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 113:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 114:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 115:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 116:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 117:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 118:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 119:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 120:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 121:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 122:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 123:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 124:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 125:00000000000000000000000000000000000000000000000000000000000000b0
-- 129:1111111111111111111111111111111111111111111111111111111111111111
-- 130:1111111111111111111111111111111111111111111111111111111111111111
-- 131:1111111111111111111111111111111111111111111111111111111111111111
-- 132:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 133:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 134:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 135:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 136:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 137:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 138:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 139:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 140:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 141:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 142:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 143:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 145:1111111111111111111111111111111111111111111111111111111111111111
-- 146:1111111111111111111111111111111111111111111111111111111111111111
-- 147:1111111111111111111111111111111111111111111111111111111111111111
-- 148:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 149:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 150:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 151:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 152:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 153:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 154:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb777bbbbb777bbbbb777
-- 155:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb777777777777777777777777
-- 156:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb777777777777777777777777
-- 157:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb777777777777777777777777
-- 158:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb777bbbbb777bbbbb777bbbbb
-- 159:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 161:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 162:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 163:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 164:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 165:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 166:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 167:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 168:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 169:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 170:bbbbb777bbbbb777bbbbb777bbbbb777bbbbb777bbbbb777bbbbb777bbbbb777
-- 171:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 172:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 173:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 174:777bbbbb777bbbbb777bbbbb777bbbbb777bbbbb777bbbbb777bbbbb777bbbbb
-- 175:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 177:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 178:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 179:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 180:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 181:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 182:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 183:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 184:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 185:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 186:bbbbb777bbbbb777bbbbb777bbbbb777bbbbb777bbbbb777bbbbb777bbbbb777
-- 187:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 188:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 189:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 190:777bbbbb777bbbbb777bbbbb777bbbbb777bbbbb777bbbbb777bbbbb777bbbbb
-- 191:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 200:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 201:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 202:bbbbb777bbbbb777bbbbb777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 203:777777777777777777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 204:777777777777777777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 205:777777777777777777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 206:777bbbbb777bbbbb777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 207:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 210:6666666666666666666666666666666666666666666666666666666666666666
-- 212:7777777777777777777777777777777777777777777777777777777777777777
-- 216:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 217:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 218:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 219:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 220:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 221:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 222:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 223:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 232:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 233:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 234:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 235:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 236:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 237:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 238:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 239:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 242:9999999999999999999999999999999999999999999999999999999999999999
-- 248:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 249:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 250:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 251:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 252:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 253:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 254:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 255:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- </TILES>

-- <MAP>
-- 001:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 002:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000002f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f0101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002fb4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b42f0001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 004:00000000000058585800005858580000585858000058585800000000000000000000000000000000000000000000000000000000000000000000000000000001002fb4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b42f0000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 005:00000000000058585800005858580000585858000058585800000000000000000000000000000000000000000000000000000000000000000000000000000001002fb4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b42f0001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 006:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001002fb4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b42f0001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 007:00000000000058585800005858580000585858000058585800000000000000000000000000000000000000000000000000000000000000000000000000000100002f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f0001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 008:000000000000585858000058585800005858580000585858000000000000000000000000000000000000000000000000000000000000000000000000000101000001010101010101010101010101010101010101010000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 009:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010101000000000100000000000000000000000000000000010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 010:000000000000585858000058585800005858580000585858000000000000000000000000000000000000000000000000000000000000000000000000010101000000000101010000000000000000000000010101000100010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 011:000000000000585858000058585800005858580000585858000000000000000000000000000000000000000000000000000000000000000000000000010101000000000100014d4d4d4d4d4d4d4d4d4d4d010000010000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 012:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010001000000000100004d2d2d2d2d2d2d2d2d2d4d000001010000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 013:000000000000585858000058585800005858580000585858000000000000000000000000000000000000000000000000000000000000000000000000000101000101010100004d2d2d2d2d2d2d2d2d2d4d010101000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 014:000000000000585858000058585800005858580000585858000000000000000000000000000000000000000000000000000000000000000000000000000101010100000000004d4d4d4d4d4d4d4d4d4d4d000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 015:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101000101000101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 016:505050505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </MAP>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- 003:88888887777776666666777777888888
-- </WAVES>

-- <SFX>
-- 000:0322032203220322032203220322033303340344034403540354035403640374038403840394039503a503b503c503d503d503d503e503e503e503f5304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76400000429366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

