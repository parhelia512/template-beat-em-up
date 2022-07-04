class_name QuiverAttackData
extends Resource

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export_range(1, 2, 1, "or_greater") var attack_damage = 1
@export var knockback:QuiverAttributes.KnockbackStrength = \
	QuiverAttributes.KnockbackStrength.NONE
@export var hurt_type: QuiverCombatSystem.HurtTypes = QuiverCombatSystem.HurtTypes.HIGH

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

