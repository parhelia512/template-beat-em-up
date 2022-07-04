@tool
extends QuiverCharacterState

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@export var _path_hurt := "Ground/Hurt"
@export var _path_knockout := "Air/Knockout/Launch"

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	update_configuration_warnings()
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_character.ground_level = _character.global_position.y
	_character.is_on_air = false


func unhandled_input(_event: InputEvent) -> void:
	pass


func physics_process(_delta: float) -> void:
	_character.ground_level = _character.global_position.y


func exit() -> void:
	_character.is_on_air = true
	super()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _connect_signals() -> void:
	super()
	
	if not _attributes.hurt_requested.is_connected(_on_hurt_requested):
		_attributes.hurt_requested.connect(_on_hurt_requested)
	
	if not _attributes.knockout_requested.is_connected(_on_knockout_requested):
		_attributes.knockout_requested.connect(_on_knockout_requested)


func _disconnect_signals() -> void:
	super()
	
	if _attributes != null:
		if _attributes.hurt_requested.is_connected(_on_hurt_requested):
			_attributes.hurt_requested.disconnect(_on_hurt_requested)
		
		if _attributes.knockout_requested.is_connected(_on_knockout_requested):
			_attributes.knockout_requested.disconnect(_on_knockout_requested)


func _on_hurt_requested(knockback: QuiverKnockback) -> void:
	_state_machine.transition_to(_path_hurt, {hurt_type = knockback.hurt_type})


func _on_knockout_requested(knockback: QuiverKnockback) -> void:
	_state_machine.transition_to(_path_knockout, {launch_vector = knockback.launch_vector})

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

const CUSTOM_PROPERTIES = {
	"path_hurt": {
		backing_field = "_path_hurt",
		type = TYPE_STRING,
		usage = PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_NONE,
		hint_string = QuiverState.HINT_STATE_LIST,
	},
	"path_knockout": {
		backing_field = "_path_knockout",
		type = TYPE_STRING,
		usage = PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_NONE,
		hint_string = QuiverState.HINT_STATE_LIST,
	},
#	"": {
#		backing_field = "",
#		name = "",
#		type = TYPE_NIL,
#		usage = PROPERTY_USAGE_DEFAULT,
#		hint = PROPERTY_HINT_NONE,
#		hint_string = "",
#	},
}

### Custom Inspector built in functions -----------------------------------------------------------

func _get_property_list() -> Array:
	var properties: = []
	
	for key in CUSTOM_PROPERTIES:
		var add_property := true
		var dict: Dictionary = CUSTOM_PROPERTIES[key]
		if not dict.has("name"):
			dict.name = key
		
		if add_property:
			properties.append(dict)
	
	return properties


func _get(property: StringName):
	var value
	
	if property in CUSTOM_PROPERTIES and CUSTOM_PROPERTIES[property].has("backing_field"):
		value = get(CUSTOM_PROPERTIES[property]["backing_field"])
	
	return value


func _set(property: StringName, value) -> bool:
	var has_handled: = false
	
	if property in CUSTOM_PROPERTIES and CUSTOM_PROPERTIES[property].has("backing_field"):
		set(CUSTOM_PROPERTIES[property]["backing_field"], value)
		has_handled = true
	
	return has_handled

### -----------------------------------------------------------------------------------------------
