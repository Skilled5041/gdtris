class_name GameConfig

static var config = ConfigFile.new()

# Called when the node enters the scene tree for the first time.
static func create():
	config.load("user://config.cfg")

	# Set default values if they don't exist
	if not config.has_section_key("handling", "das"):
		config.set_value("handling", "das", 150)
	if not config.has_section_key("handling", "arr"):
		config.set_value("handling", "arr", 50)
	if not config.has_section_key("handling", "sdf"):
		config.set_value("handling", "sdf", 5)

static func change_setting(section: String, key: String, value):
	config.set_value(section, key, value)
	config.save("user://config.cfg")

static func get_setting(section: String, key: String):
	return config.get_value(section, key)
