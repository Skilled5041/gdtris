extends LineEdit

var regex = RegEx.new()
var oldtext = ""

func _ready():
	regex.compile("^[0-9]*$")
	text = str(GameConfig.get_setting("handling", "sdf"))
	text_changed.connect(on_text_changed)
	on_window_resize()
	get_tree().get_root().size_changed.connect(on_window_resize) 

func on_text_changed(new_text):
	if regex.search(new_text) && int(new_text) >= 0:
		oldtext = new_text
		GameConfig.change_setting("handling", "sdf", int(text))
	else:
		text = oldtext
		
	set_caret_column(text.length())

func get_value():
	return(int(text))

func on_window_resize():
	var window_size = get_viewport().size
	add_theme_font_size_override("font_size", window_size.x / 1920.0 * 64)
	position.x = window_size.x / 2 - size.x / 2
	position.y = size.y * 8
