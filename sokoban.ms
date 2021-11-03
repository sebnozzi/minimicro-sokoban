import "sokobanLevel"

LEVELS_FILE = "original-levels.txt"

// === Loading of levels ===

// Returns a list of "level data", which is in turn a list
// of lines. These lines are read from a level file in the
// "sokoban" format ("#" for wall, "@" for player, etc.)
loadLevels = function(levelsFile)
	linesFromFile = file.readLines(levelsFile)
	// This will be a list of lists, each sublist consisting
	// of the lines of a level
	levels = []
	// This is to read the lines of *one* level in a file
	levelLines = []
	// This is to control wether to read level lines or not
	readLevelLines = false
	for lineFromFile in linesFromFile
		// Line contains level information
		if lineFromFile.indexOf("#") != null then
			readLevelLines = true
		else if readLevelLines then
			// Stop reading - we got one level
			readLevelLines = false
			// Add level-lines to the list of levels
			levels.push levelLines
			// Reset the buffer
			levelLines = []
		else 
			// Line is uninteresing - skip
			continue
		end if
		if readLevelLines then
			levelLines.push lineFromFile
		end if
	end for
	return levels
end function

// === Displaying things ===

// Claim display 2 for text overlays
display(2).mode = displayMode.pixel
textOverlayDisp = display(2)

clearDisplays = function()
	sokobanLevel.clearDisplays
	gfx.clear
	text.clear
	textOverlayDisp.clear
	text.row = 25
end function

showOverlayMsg = function(msg,x,blackDisplay=false)
	if blackDisplay then
		textOverlayDisp.clear(color.black)
	end if
	textOverlayDisp.print(
	msg,
	x,320,
	color.white,
	"large")
end function

showLevelText = function(levelNr)
	textOverlayDisp.print(
	"Level "+levelNr,
	820,10,
	color.gray,
	"normal")
end function

// === Play modes ===

MODE_ASKING_LEVEL=1
MODE_SHOWING_LEVEL=2
MODE_PLAYING=3
MODE_SOLVED_ALL=4

askLevel = function()
	clearDisplays
	
	levelCount = len(ALL_LEVELS)
	print "Choose 1-"+levelCount+". Press ENTER for 1."
	levelStr = input("Start from level? ")
	levelNr = levelStr.val
	if levelNr == 0 then
		return 1
	else if levelNr > levelCount then
		return levelCount
	else 
		return levelNr
	end if
end function

playLevel = function(levelNr)
	beforePlaying = function()
		textOverlayDisp.clear
		showLevelText(levelNr)
	end function
	
	levelIdx = levelNr - 1
	levelData = ALL_LEVELS[levelIdx]
	// NOTE: we pass a *reference* to the function
	// Without the "@" we would be calling the function
	// here, *before* calling "playLevel"
	sokobanLevel.playLevel(levelData,@beforePlaying)
	
	showOverlayMsg("Solved!",380)
	wait(2)
end function

showLevel = function(levelNr)
	clearDisplays
	showOverlayMsg("Level "+levelNr,380,true)
	wait(1)
end function

showSolvedAll = function()
	showOverlayMsg("Solved all levels!",320)
end function

// === MAIN LOOP ===

ALL_LEVELS = loadLevels(LEVELS_FILE)
currentMode = MODE_ASKING_LEVEL
levelNr = 1

while true
	if currentMode == MODE_ASKING_LEVEL then
		levelNr = askLevel
		currentMode = MODE_SHOWING_LEVEL
	else if currentMode == MODE_SHOWING_LEVEL then
		showLevel(levelNr)
		currentMode = MODE_PLAYING
	else if currentMode == MODE_PLAYING then
		playLevel(levelNr)
		// Advance to the next level
		levelNr = levelNr + 1
		if levelNr >= len(ALL_LEVELS) then
			currentMode = MODE_SOLVED_ALL
		else
			currentMode = MODE_SHOWING_LEVEL
		end if
	else if currentMode == MODE_SOLVED_ALL then
		showSolvedAll
		exit
	end if	
end while
