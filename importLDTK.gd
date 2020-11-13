tool
extends EditorScript

var jsonData = {}


# Called when the node enters the scene tree for the first time.
func _run():
	var tileMapFile = File.new()
	tileMapFile.open("res://testlevel.json", File.READ)
	var jsonTXT = tileMapFile.get_as_text()
	tileMapFile.close()
	var jsonParsed = JSON.parse(jsonTXT)
	var tileData = jsonParsed.result
	_checkJson(tileData) # checking the json to make sure it passes
	_extractLayers(tileData)
	_extractTileMaps(tileData)
	jsonData.jsonVersion = tileData["jsonVersion"]
	jsonData.defaultGridSize = tileData["defaultGridSize"]

	var sceneRoot = get_editor_interface().get_edited_scene_root()
	if sceneRoot == null:
		push_error("You must create a root Node2D before you run the plugin")
	print("SceneRoot: ", sceneRoot)


	sceneRoot.name = "LDtk Imported"
	_importTileSets(jsonData.validTileMaps)
	_createTileMaps(jsonData.validTileMaps, sceneRoot)
	

	
func _checkJson(tileData: Dictionary):
	if tileData["exportTiled"] == true:
		push_error("TileData set as tiled, this importer does not accept tiled JSON")
	if tileData["__header__"]["app"] != "LDtk":
		push_warning("App name is not set to LDtk, possible problem with JSON?")
	else:
		print("App name is verified...")
		
	#if tileData["__header__"]."file"
	
	
func _extractLayers(tileData: Dictionary):
	jsonData.layers = tileData["defs"]["layers"]
	print("Layers: ", jsonData.layers)
	print("TYPEOF: ", typeof(jsonData.layers))
	for layer in jsonData.layers:
		print("Layer type: ", layer["__type"])
		
func _extractTileMaps(tileData: Dictionary):
	jsonData.tileMaps = tileData["defs"]["tilesets"]
	jsonData.validTileMaps = []
	for tileMap in jsonData.tileMaps:
		print("TileSetFound: ", tileMap["identifier"])
		if tileMap["relPath"] == null:
			print("Tileset has no path, discarding: ", tileMap["identifier"])
			continue
		jsonData.validTileMaps.append(tileMap)
	
	print("Valid Sets: ", jsonData.validTileMaps)

func _createTileMaps(tileMaps: Array, sceneRoot: Node):
	for tileMap in tileMaps:
		var tileMapName = tileMap["identifier"]
		print("Creating TileMap: ", tileMapName)
		var tileMapLDtk = TileMap.new()
		tileMapLDtk.name = tileMapName
		sceneRoot.add_child(tileMapLDtk, true)
		tileMapLDtk.set_owner(sceneRoot)
		var gridSize = tileMap["tileGridSize"]
		var cellSize = Vector2(gridSize, gridSize)
		tileMapLDtk.set_cell_size(cellSize)
		var tilemapPath = "res://LDtkTextures/" + tileMapName + ".png"
		var texImage = ResourceLoader.load(tilemapPath)
		var newTileSet = TileSet.new()
		var ycoord = 0
		var xcoord = 0
		var totalColumns = tileMap["pxWid"]/gridSize
		var totalRows = tileMap["pxHei"]/gridSize
		var runNumber = 0
		for r in range(totalRows):
			for c in range(totalColumns):
				var newRect = Rect2(xcoord, ycoord, gridSize, gridSize)
				var id = newTileSet.get_last_unused_tile_id()
				newTileSet.create_tile(id)
				newTileSet.tile_set_texture(id, texImage)
				newTileSet.tile_set_name(id, tileMapName + "-" + str(runNumber))
				newTileSet.tile_set_region(id, newRect)
				tileMapLDtk.set_tileset(newTileSet)
				ycoord = ycoord + gridSize
				runNumber = runNumber + 1

			ycoord = 0
			xcoord = xcoord + gridSize

				

		
	
		

func _importTileSets(tileMaps: Array):
	var imageDir = Directory.new()
	imageDir.open("res://")
	imageDir.make_dir("LDtkTextures")
	imageDir.change_dir("res://LDtkTextures")
	print("DIR: ", imageDir.get_current_dir())
	
	for tileSet in tileMaps:
		print("Importing tileset: ", tileSet["relPath"])
		var tileFile = File.new()
		if tileFile.open(tileSet["relPath"], File.READ) != OK:
			push_error("unable to open tilemap image: " + tileSet["relPath"])
		tileFile.close()
		var testImage = Image.new()
		#var testTexture = Texture.new()
		var filename =  "res://LDtkTextures/" + tileSet["identifier"] + ".png"
		testImage.load(tileSet["relPath"])
		testImage.save_png(filename)
		
		
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
