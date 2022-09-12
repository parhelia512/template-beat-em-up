@tool
extends QuiverCharacterState

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

enum EndConditions {
	ANIMATION, ## Triggers end of state when air attack animation emits [signal QuiverCharacterSkin.skin_animation_finished].
	DISTANCE_FROM_GROUND, ## Triggers end of state using [member _min_distance_from_ground].
	FIRST_TO_TRIGGER, ## Triggers end of state by whatever happens first, ANIMATION or DISTANCE_FROM_GROUND
}

#--- constants ------------------------------------------------------------------------------------

const JumpState = preload(
		"res://addons/quiver.beat_em_up/characters/action_states/air_actions/quiver_action_jump.gd"
)

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _skin_state: StringName
var _path_falling_state := "Air/Jump"

## What Condition should trigger the end of the air attack. See enum [b]EndContitions.[/b]
var _end_condition: EndConditions = EndConditions.DISTANCE_FROM_GROUND:
	set(value):
		_end_condition = value
		notify_property_list_changed()

## Minimum distance the air attack can have from ground. Anything below this will trigger 
## the end of the air attack if [member _end_condition] is either 
## [b]EndConditions.DISTANCE_FROM_GROUND[/b] or [b]EndConditions.FIRST_TO_TRIGGER[/b].
var _min_distance_from_ground = 100

@onready var _jump_state := get_parent() as JumpState

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	update_configuration_warnings()
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if not get_parent() is JumpState:
		warnings.append(
				"This ActionState must be a child of Action AirState or a state " 
				+ "inheriting from it."
		)
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_skin.transition_to(_skin_state)


func physics_process(delta: float) -> void:
	_jump_state.physics_process(delta)
	if _has_distance_condition():
		if _skin.position.y >= _min_distance_from_ground:
			_state_machine.transition_to(_path_falling_state)


func exit() -> void:
	super()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _has_animation_condition() -> bool:
	return (
			_end_condition == EndConditions.ANIMATION 
			or _end_condition == EndConditions.FIRST_TO_TRIGGER
	)


func _has_distance_condition() -> bool:
	return (
			_end_condition == EndConditions.DISTANCE_FROM_GROUND 
			or _end_condition == EndConditions.FIRST_TO_TRIGGER
	)

func _connect_signals() -> void:
	super()
	
	if _has_animation_condition():
		QuiverEditorHelper.connect_between(
				_skin.skin_animation_finished, _on_skin_animation_finished
		)


func _disconnect_signals() -> void:
	super()
	
	if _skin != null and _has_animation_condition():
		QuiverEditorHelper.disconnect_between(
				_skin.skin_animation_finished, _on_skin_animation_finished
		)


func _on_skin_animation_finished() -> void:
	_state_machine.transition_to(_path_falling_state)

### -----------------------------------------------------------------------------------------------


###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################


var _CUSTOM_PROPERTIES = {
	"Air Attack State":{
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY,
		hint = PROPERTY_HINT_NONE,
	},
	"skin_state": {
		backing_field = "_skin_state",
		type = TYPE_INT,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_ENUM,
		hint_string = \
				'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
	},
	"path_falling_state": {
		backing_field = "_path_falling_state",
		type = TYPE_STRING,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_NONE,
		hint_string = QuiverState.HINT_STATE_LIST,
	},
	"end_condition": {
		backing_field = "_end_condition",
		type = TYPE_INT,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_ENUM,
		hint_string = ",".join(EndConditions.keys()),
	},
	"min_distance_from_ground": {
		backing_field = "_min_distance_from_ground",
		type = TYPE_INT,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "0,1000,10,or_greater",
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
	
	for key in _CUSTOM_PROPERTIES:
		var add_property := true
		var dict: Dictionary = _CUSTOM_PROPERTIES[key]
		if not dict.has("name"):
			dict.name = key
		
		if _has_distance_condition() and key == "min_distance_from_ground":
			dict.usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		elif key == "min_distance_from_ground":
			dict.usage = PROPERTY_USAGE_STORAGE
		
		if add_property:
			properties.append(dict)
	
	return properties


func _get(property: StringName):
	var value
	
	if property in _CUSTOM_PROPERTIES and _CUSTOM_PROPERTIES[property].has("backing_field"):
		value = get(_CUSTOM_PROPERTIES[property]["backing_field"])
	
	return value


func _set(property: StringName, value) -> bool:
	var has_handled: = false
	
	if property in _CUSTOM_PROPERTIES and _CUSTOM_PROPERTIES[property].has("backing_field"):
		set(_CUSTOM_PROPERTIES[property]["backing_field"], value)
		has_handled = true
	
	return has_handled

### -----------------------------------------------------------------------------------------------