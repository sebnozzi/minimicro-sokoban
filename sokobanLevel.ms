
// Define some variables

// Define some constants
TILESHEET_FILE = "sokoban_tilesheet.png"

// -- Size of tiles to *display*
TILE_SIZE = 32
// -- Size of tiles in the *tilesheet* file
TILESHEET_TILE_SIZE = 64

// Define displays

// -- Setup sprites display
sprtDisp = display(4)

clearDisplays = function()
	gfx.clear
	text.clear
	sprtDisp.clear
	text.row = 25
end function

// Create directions for movement
up = {"deltaCol": 0, "deltaRow": 1}
down = {"deltaCol": 0, "deltaRow": -1}
left = {"deltaCol": -1, "deltaRow": 0}
right = {"deltaCol": 1, "deltaRow": 0}

// Create position class
Position = {"col":0, "row": 0}
Position.newFrom = function(col,row)
	newPosition = new Position
	newPosition.col = col
	newPosition.row = row
	return newPosition
end function
Position.shiftedByOneInDirection = function(direction)
	newPosition = new Position
	newPosition.col = self.col + direction.deltaCol
	newPosition.row = self.row + direction.deltaRow
	return newPosition
end function

// Load tilesheet file
sokobanTiles = {}
sokobanTiles.images = file.loadImage(TILESHEET_FILE)
sokobanTiles.tileSize = TILESHEET_TILE_SIZE
sokobanTiles.getImageAt = function(col,row)
	img = self.images.getImage(
	self.tileSize*col,self.tileSize*row,
	self.tileSize,self.tileSize)
	return img
end function
// Extract sprites from the tilesheet file
sokobanTiles.boxImg = sokobanTiles.getImageAt(6,7)
sokobanTiles.placedBoxImg = sokobanTiles.getImageAt(9,7)
sokobanTiles.floorImg = sokobanTiles.getImageAt(11,1)
sokobanTiles.wallImg = sokobanTiles.getImageAt(6,1)
sokobanTiles.targetImg = sokobanTiles.getImageAt(11,0)

sokobanTiles.workerImgUp = sokobanTiles.getImageAt(3,3)
sokobanTiles.workerImgDown = sokobanTiles.getImageAt(0,3)
sokobanTiles.workerImgLeft = sokobanTiles.getImageAt(3,1)
sokobanTiles.workerImgRight = sokobanTiles.getImageAt(0,1)

// Define level behaviour

LEVEL = {}
LEVEL.colCount=0
LEVEL.rowCount=0
LEVEL.tileSize = TILE_SIZE
LEVEL.originX = function()
	return (960/2)-self.tileSize*(LEVEL.colCount/2)
end function
LEVEL.originY = function()
	return (640/2)-self.tileSize*(LEVEL.rowCount/2)
end function
// Map of Position => StructureTile
LEVEL.structureTiles = {}
LEVEL.boxes = []
LEVEL.worker = null

// Define tile behaviour

StructureTile = {}
StructureTile.position = new Position
StructureTile.img = null
StructureTile.tileSize = function()
	return LEVEL.tileSize
end function
StructureTile.canBeMovedInto = false
StructureTile.isTargetTile = false
StructureTile.isFloorTile = false
StructureTile.isWallTile = false
StructureTile.drawFromOrigin = function()
	col = self.position.col
	row = self.position.row
	x = LEVEL.originX+col*self.tileSize
	y = LEVEL.originY+row*self.tileSize
	gfx.drawImage self.img,x,y,self.tileSize,self.tileSize
end function
// TODO: code duplication with LevelSprite
StructureTile.isAtPosition = function(position)
	return self.position == position
end function

WallTile = new StructureTile
WallTile.img = sokobanTiles.wallImg
WallTile.isWallTile = true
WallTile.drawFromOrigin = function()
	col = self.position.col
	row = self.position.row
	x = LEVEL.originX+col*self.tileSize
	y = LEVEL.originY+row*self.tileSize
	gfx.drawImage sokobanTiles.floorImg,x,y,self.tileSize,self.tileSize
	super.drawFromOrigin
end function

FloorTile = new StructureTile
FloorTile.img = sokobanTiles.floorImg
FloorTile.isFloorTile = true
FloorTile.canBeMovedInto = true

TargetTile = new FloorTile
TargetTile.img = sokobanTiles.targetImg
TargetTile.isTargetTile = true

// Adding structure tiles

LEVEL.addStructureTile = function(structureClass,position)
	structureTile = new structureClass
	structureTile.position = position
	self.structureTiles[position] = structureTile
end function
LEVEL.addFloorAt = function(position)
	self.addStructureTile(FloorTile,position)
end function
LEVEL.addTargetAt = function(position)
	self.addStructureTile(TargetTile,position)
end function
LEVEL.addWallAt = function(position)
	self.addStructureTile(WallTile,position)
end function

// Adding/setting sprite objects

addSprite = function(levelSprite, position)
	levelSprite.moveTo position
	levelSprite.initialPosition = position
	sprtDisp.sprites.push levelSprite	
end function

addBox = function(position)
	boxSprite = new BoxSprite
	addSprite boxSprite,position
	return boxSprite
end function

LEVEL.addBoxAt = function(position)
	boxSprite = addBox(position)
	self.boxes.push boxSprite
end function
LEVEL.addPlacedBoxAt = function(position)
	boxSprite = addBox(position)
	boxSprite.bePlaced
	self.boxes.push boxSprite
end function

LEVEL.addWorkerAt = function(position)
	// Create the worker
	worker = new WorkerSprite
	sprtDisp.sprites.push worker
	// Setup its positions
	worker.moveTo position
	worker.initialPosition = position
	// Register it in class
	self.worker = worker
end function

// Querying

LEVEL.getLevelObjectAt = function(position)
	// Either box or ... air
	for box in self.boxes
		if box.isAtPosition(position) then
			return box
		end if
	end for
	// Construct "air" object, which ignores "move" requests
	airObject = {}
	airObject.move = function(direction)
		// Do nothing
	end function
	return airObject
end function

LEVEL.hasFreeTileAt = function(position)
	// Try to prove wrong ... look for walls or boxes
	objects = self.boxes + self.structureTiles.values
	// Try to find object at position, and ask if we can move there
	// Only floors and targets can be moved into
	for object in objects
		if object.isAtPosition(position) then
			return object.canBeMovedInto
		end if
	end for
	// Nothing found (should not happen)
	return false
end function

LEVEL.getTargetTiles = function()
	tiles = []
	for tile in self.structureTiles.values
		if tile.isTargetTile then
			tiles.push tile
		end if
	end for
	return tiles
end function

LEVEL.hasTargetTileAt = function(position)
	for targetTile in self.getTargetTiles
		if targetTile.isAtPosition(position) then
			return true
		end if
	end for
	return false
end function

LEVEL.hasFloorOrTargetTileAt = function(position)
	if self.structureTiles.hasIndex(position) then
		tile = self.structureTiles[position]
		return tile.isTargetTile or tile.isFloorTile
	end if
	return false
end function

LEVEL.hasWallTileAt = function(position)
	if self.structureTiles.hasIndex(position) then
		tile = self.structureTiles[position]
		return tile.isWallTile
	end if
	return false
end function

LEVEL.isSolved = function()
	// Solved when all boxes are "placed"
	// Proved wrong when at leat one box is not placed
	for box in self.boxes
		if not box.isPlaced then
			return false
		end if
	end for
	return true
end function

// Drawing level tiles

LEVEL.drawTiles = function()
	// Draw the individual tiles
	for tile in self.structureTiles.values
		tile.drawFromOrigin
	end for
end function

// Resetting the level

LEVEL.reset = function()
	// Tell all sprites to move to their initial positions
	self.worker.moveToInitialPosition
	for box in self.boxes
		box.moveToInitialPosition
	end for
end function

// Create level-sprite superclass with common behaviour
// Sublasses of this will be "movable" objects in the level,
// that is: boxes and the worker 
LevelSprite = new Sprite
LevelSprite.scale = 0 // adjusted below
LevelSprite.adjustScale = function()
	self.scale = LEVEL.tileSize / TILESHEET_TILE_SIZE
end function
LevelSprite.adjustScale
LevelSprite.position = new Position
LevelSprite.initialPosition = new Position
LevelSprite.canBeMovedInto = false
LevelSprite.moveTo = function(position)
	self.position = position
	self.x = LEVEL.originX+LEVEL.tileSize*position.col+LEVEL.tileSize/2
	self.y = LEVEL.originY+LEVEL.tileSize*position.row+LEVEL.tileSize/2	
end function
LevelSprite.moveToInitialPosition = function()
	self.moveTo self.initialPosition
end function
LevelSprite.move = function(direction)
	newPosition = self.position.shiftedByOneInDirection(direction)
	self.moveTo newPosition
end function
LevelSprite.moveUp = function()
	self.move up
end function
LevelSprite.moveDown = function()
	self.move down
end function
LevelSprite.moveLeft = function()
	self.move left
end function
LevelSprite.moveRight = function()
	self.move right
end function
LevelSprite.isAtPosition = function(position)
	return self.position == position
end function
LevelSprite.nextPositionInDirection = function(direction)
	nextPosition = self.position.shiftedByOneInDirection(direction)
	return nextPosition
end function

BoxSprite = new LevelSprite
BoxSprite.image = sokobanTiles.boxImg
BoxSprite.placedImg = sokobanTiles.placedBoxImg
BoxSprite.unplacedImg = sokobanTiles.boxImg
BoxSprite.isPlaced = false
BoxSprite.bePlaced = function()
	self.image = self.placedImg
	self.isPlaced = true
end function
BoxSprite.beUnplaced = function()
	self.image = self.unplacedImg
	self.isPlaced = false
end function
BoxSprite.updatePlacedState = function()
	// Be placed only if we are on a target-tile
	if LEVEL.hasTargetTileAt(self.position) then
		self.bePlaced
	else
		self.beUnplaced
	end if
end function
BoxSprite.move = function(direction)
	nextPosition = self.nextPositionInDirection(direction)	
	
	// Only move if the tile at direction is empty
	if LEVEL.hasFreeTileAt(nextPosition) then
		super.move direction
	end if
	
	self.updatePlacedState()
end function
BoxSprite.moveToInitialPosition = function()
	super.moveToInitialPosition
	self.updatePlacedState
end function

WorkerSprite = new LevelSprite
WorkerSprite.image = sokobanTiles.workerImgDown
WorkerSprite.move = function(direction)
	if direction == up then
		self.image = sokobanTiles.workerImgUp
	else if direction == down then
		self.image = sokobanTiles.workerImgDown
	else if direction == left then 
		self.image = sokobanTiles.workerImgLeft
	else if direction == right then
		self.image = sokobanTiles.workerImgRight
	end if
	
	nextPosition = self.nextPositionInDirection(direction)
	
	objectAtNextPosition = LEVEL.getLevelObjectAt(nextPosition)
	// Tell object to move to desired direction
	// Object _might_ ignore this request, e.g. a box cannot be moved
	// or the next position contains a wall, or there is nothing there
	objectAtNextPosition.move direction
	
	if LEVEL.hasFreeTileAt(nextPosition) then
		super.move direction
	end if
end function

// Process level data
// This draws the level and creates the appropriate sprites

FLOOR_CHAR=" "
WALL_CHAR="#"
PLAYER_CHAR="@"
TARGET_CHAR="."
BOX_CHAR="$"
PLACED_BOX_CHAR="*"

floodWithFloorTiles = function(level,position)
	if level.hasFloorOrTargetTileAt(position) then
		return
	else if level.hasWallTileAt(position) then
		return
	else
		level.addFloorAt position
	end if
	floodWithFloorTiles(level,position.shiftedByOneInDirection(up))
	floodWithFloorTiles(level,position.shiftedByOneInDirection(down))
	floodWithFloorTiles(level,position.shiftedByOneInDirection(left))
	floodWithFloorTiles(level,position.shiftedByOneInDirection(right))
end function

placeTargetTiles = function(level, targetTilePositions)
	for position in targetTilePositions
		level.addTargetAt position
	end for
end function

adjustTileSize = function(newSize)
	LEVEL.tileSize = newSize
	LevelSprite.scale = newSize / TILESHEET_TILE_SIZE
end function

LEVEL.initializeFromData = function(levelData)
	// Reset fields
	self.boxes = []
	self.structureTiles = {}
	// Initialize level dimensions
	self.rowCount=len(levelData)
	for levelLine in levelData
		// Keep the maximum line length found
		lineLength = len(levelLine)
		if lineLength > self.colCount then
			self.colCount=lineLength
		end if
	end for
	
	// Adjust tile size
	if self.rowCount > 12 then
		adjustTileSize(36)
	else 
		adjustTileSize(48)
	end if 
	
	// Variables to accumulate objects
	targetTilePositions = []
	wallPositions = []
	playerPosition = null
	boxPositions = []
	placedBoxPositions = []
	
	// Process data
	row = self.rowCount-1 // from 0 to count-1
	for levelLine in levelData
		col = 0
		// Process all chars in line
		for charIdx in range(0,self.colCount-1)
			if charIdx < len(levelLine) then
				levelChar = levelLine[charIdx]
			else
				levelChar = null
			end if
			
			position = Position.newFrom(col,row)
			
			if levelChar == WALL_CHAR then
				wallPositions.push position
			else if levelChar == TARGET_CHAR then
				targetTilePositions.push position
			else if levelChar == PLACED_BOX_CHAR then
				// Represents a target-tile with a "placed" box in it
				// Show a target-tile and add sprite for box
				targetTilePositions.push position
				placedBoxPositions.push position
			else if levelChar == BOX_CHAR then
				// Represents a box outside of a target-tile
				boxPositions.push position
			else if levelChar == PLAYER_CHAR then
				// Represents the worker (player)
				workerPosition = position
			end if	
			
			col = col + 1
		end for
		row = row - 1
	end for
	
	// Add walls
	for position in wallPositions
		self.addWallAt position
	end for	
	// Flood with floor tiles from worker
	floodWithFloorTiles(self, workerPosition)
	// After flooding everything with floor-tiles, make
	// place for the target tiles
	placeTargetTiles(self, targetTilePositions)
	// Draw level tiles
	self.drawTiles()
	// Add sprites
	for position in boxPositions
		self.addBoxAt position
	end for
	for position in placedBoxPositions
		self.addPlacedBoxAt position
	end for
	self.addWorkerAt workerPosition
end function

// MAIN LOOP

// Define some key-codes
KEY_ESC = 27
KEY_LEFT = 17
KEY_RIGHT = 18
KEY_UP = 19
KEY_DOWN = 20

playLevel = function(levelData)
	clearDisplays
	
	LEVEL.initializeFromData(levelData)
	
	key.clear
	while true
		pressedKey = key.get.lower
		keyCode = pressedKey.code
		
		if pressedKey == "q" or keyCode == KEY_ESC then
			exit
		else if pressedKey == "r" then
			// Reset the game
			LEVEL.reset
		else if keyCode == KEY_LEFT then
			LEVEL.worker.moveLeft
		else if keyCode == KEY_RIGHT then
			LEVEL.worker.moveRight
		else if keyCode == KEY_UP then
			LEVEL.worker.moveUp
		else if keyCode == KEY_DOWN then
			LEVEL.worker.moveDown
		end if
		
		if LEVEL.isSolved then
			break
		end if
		
		yield
	end while
end function

// MAIN PROGRAM

if globals == locals then
	levelData = [
	"#########",
	"#..   $ #",
	"#..     #",
	"### $   ##",
	"# $  @ $ #",
	"#   ##   #",
	"##########"]
	firstLevel = [
	"    #####", 
	"    #   #", 
	"    #   #", 
	"  ###   ##", 
	"  #      #",
	"### # ## #   ######", 
	"#   # ## #####  **#", 
	"#              $.*#",
	"##### ### #@##  **#", 
	"    #     #########", 
	"    #######"]
	levelData = firstLevel
	playLevel(levelData)
	if LEVEL.isSolved then
		print "Solved!"
	end if
end if