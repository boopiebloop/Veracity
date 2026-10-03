# ---------------------------------------------------------------------------------------------- #
##
# ---------------------------------------------------------------------------------------------- #


@tool
@abstract
class_name ConstrainedTypr
extends ScriptTypr


func _init(new_script:Script = null) -> void:
	var inheritance_constraint_script:Script = Veracity.ensure(
		_get_base_script_inheritance_constraint())
	if new_script:
		_type = Veracity.ensure(new_script)
		Veracity.enforce(inherits(inheritance_constraint_script))
	else:
		_type = inheritance_constraint_script

@abstract func _get_base_script_inheritance_constraint() -> Script

func generate_map(elements:Array) -> Dictionary[Script, Array]:
	var matches:bool = elements.get_typed_script() == get_type_script()
	Veracity.enforce(matches)
	Veracity.ensure(elements)
	var map:Dictionary[Script, Array] = {}
	for element:Variant in elements:
		var typr := Typr.new(element)
		var type := typr.get_type()
		var array:Array = map.get_or_add(type, [])
		array.append(element)
	return map
