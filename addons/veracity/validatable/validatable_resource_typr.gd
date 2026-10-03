# ---------------------------------------------------------------------------------------------- #
##
# ---------------------------------------------------------------------------------------------- #


@tool
class_name ValidatableResourceTypr
extends ConstrainedTypr


func _get_base_script_inheritance_constraint() -> Script:
	return ValidatableResource
