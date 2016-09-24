tool
extends EditorPlugin

var plugin_button = null
var dialog = null
var root = null
var proccesing_lbl = null

var fileS = null
var imagepath = null

var tile_size_x = 16
var tile_size_y = 16

var actual = 0
var total = 0

func _enter_tree():
	print("Enter Tree")
	plugin_button = Button.new()
	plugin_button.set_text("Tile Creator")
	
	plugin_button.connect("pressed", self, "_show_dialog")
	add_control_to_container( CONTAINER_CANVAS_EDITOR_MENU, plugin_button)
	
	proccesing_lbl = preload("ProcessingLabel.tscn").instance()
	dialog = preload("ConfirmationDialog.tscn").instance()
	
func _show_dialog():
	print("Show Dialog")
	get_base_control().add_child(dialog)
	dialog.connect("confirmed", self, "_on_dialog_confirmed")
	dialog.get_node("Button").connect("pressed", self, "_open_file")
	dialog.popup_centered()
	

func _open_file():
	print("Open File")
	fileS = FileDialog.new()
	fileS.set_mode(FileDialog.MODE_OPEN_FILE)
	fileS.set_access(FileDialog.ACCESS_FILESYSTEM)
	fileS.add_filter("*.png;PNG Image type")
	fileS.add_filter("*.jpg;JPG Image type")
	fileS.set_size( Vector2(600, 600) )
	fileS.connect("file_selected", self, "_on_file_selected")
	add_child(fileS)
	fileS.popup_centered()

func _on_file_selected(path):
	print("File selected")
	dialog.get_node("ImagePath").set_text(path)

func _on_dialog_confirmed():
	print("Dialog Confirmed")
	root = get_tree().get_edited_scene_root()
	imagepath = dialog.get_node("ImagePath").get_text()	
	var thread = Thread.new()
	thread.start(self, "image_divide", imagepath, Thread.PRIORITY_HIGH)
	#get_base_control().add_child(proccesing_lbl)
	#proccesing_lbl.popup_centered()
	#proccesing_lbl.get_node("Label").set_text("Processing: " + str(actual) + "/" + str(total))
	thread.wait_to_finish()

func image_divide(imagepath):
	print("Create image")
	var image = Image()
	image.load(imagepath)

	var r = 0
	var i = 0
	#total = image.get_width() / tile_size_x * image.get_width() / tile_size_y
	while i < image.get_height():
		var j = 0
		r += 1
		var c = 0
		while j < image.get_width():
			#actual = r + c
			
			if not check_image_empty(image, j, i):
				
				#print("Creating image texture")
				#var image_tex = ImageTexture.new()
				#image_tex.create_from_image(image)
				#print("Created")
				
				print("Creating Sprite")
				var s = Sprite.new()
				print("Created")
				
				s.set_texture(image) # Change to image_tex if it doesn't works
				s.set_region(true)
				s.set_region_rect(Rect2(j, i, tile_size_x, tile_size_y))
				root.add_child(s)
				var pos = Vector2(r * (tile_size_x + 10), c * (tile_size_y + 10))
				c += 1
				s.set_pos(pos)
				s.set_owner(root)
			j += tile_size_y
		i += tile_size_x

func check_image_empty(image, x, y):
	print("Check Image Empty")
	if x == image.get_width() or y == image.get_height():
		return true
	for i in range (x, x + tile_size_x):
		for j in range (y, y + tile_size_y):
			if not image.get_pixel(i, j).a == 0:
				print("It has alpha!")
				return  false
	return true

func _exit_tree():
	plugin_button.disconnect("pressed", self, "_show_dialog")
	plugin_button.free()
	
	get_base_control().remove_child(dialog)
	dialog.free()
	
	plugin_button = null
	dialog = null
