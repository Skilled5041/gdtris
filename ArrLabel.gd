extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	on_window_resize()
	get_tree().get_root().size_changed.connect(on_window_resize) 

func on_window_resize():
	var window_size = get_viewport().size
	add_theme_font_size_override("normal_font_size", window_size.x / 1920.0 * 64)
	size.x = window_size.x / 10
	size.y = window_size.y / 10
	position.x = window_size.x / 2 - size.x / 2
	position.y = size.y * 4
