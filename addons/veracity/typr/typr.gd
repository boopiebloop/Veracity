# ---------------------------------------------------------------------------------------------- #
##
# ---------------------------------------------------------------------------------------------- #


@tool
class_name Typr
extends RefCounted


enum Form{
	BUILT_IN,
	NATIVE,
	SCRIPT,
}

static var _script_global_name_map:Dictionary[StringName, Script] = {}

static func get_type_from_name(global_name:String) -> Variant:
	if ClassDB.class_exists(global_name):
		return global_name
	elif _script_global_name_map.has(global_name):
		return _script_global_name_map[global_name]
	else:
		for class_info in ProjectSettings.get_global_class_list():
			if class_info["class"] == global_name:
				var script_path:String = class_info["path"]
				var script:Script = load(script_path)
				_script_global_name_map[global_name] = script
				return script
	Log.warning("Class not found?")
	return null

static func script_inherits(type:Script, base_script:Script) -> bool:
	if not base_script:
		return false
	while type:
		if type == base_script:
			return true
		else:
			type = type.get_base_script()
	return false


## Identifies what this Typr is.
var _type:Variant
func get_type() -> Variant:
	return _type
func is_built_in() -> bool:
	return _type is Variant.Type
func get_built_in_type() -> Variant.Type:
	if is_built_in():
		return _type
	else:
		return TYPE_OBJECT
func is_native() -> bool:
	return _type is String
func get_native_class_name() -> String:
	if is_native():
		return _type
	else:
		return get_type_script().get_class()
func is_script() -> bool:
	return _type is Script
func get_type_script() -> Script:
	Veracity.enforce(is_script())
	@warning_ignore("unsafe_cast")
	return _type as Script


var _evaluated_form:bool = false
var _form:Form:
	get:
		if not _evaluated_form:
			_evaluate_form()
		return _form
func get_form() -> Form:
	return _form
func _evaluate_form() -> void:
	if _evaluated_form:
		Log.warning("Attempting to evaluate form when it's already evaluated?")
		return
	if is_built_in():
		_form = Form.BUILT_IN
	elif is_native():
		_form = Form.NATIVE
	elif is_script():
		_form = Form.SCRIPT
	else:
		Log.unreachable()
	_evaluated_form = true


static func from_name(type_name:String) -> Typr:
	return Typr.new(get_type_from_name(type_name))

static func from_ambiguous(type_name:String, type:Variant.Type) -> Typr:
	if not type_name.is_empty():
		return from_name(type_name)
	else:
		return Typr.new(type)

static func packed_scene_of_type(packed_scene:PackedScene, type:Variant) -> bool:
	var typr := Typr.new(type)
	return typr.inherited_by_packed_scene(packed_scene)

static func get_array_type(array:Array) -> Variant:
	if not Veracity.probe(array.is_typed(), "Array has no type!"):
		return null
	else:
		var typed_built_in := array.get_typed_builtin()
		var typed_class_name := array.get_typed_class_name()
		var typed_script := array.get_typed_script()
		if typed_built_in == TYPE_OBJECT:
			if not typed_script:
				return typed_class_name
			else:
				return typed_script
		else:
			return typed_built_in

func _init(source:Variant) -> void:
	Veracity.ensure(source)
	if source is Typr:
		var typr:Typr = source
		_type = typr.get_type()
	else:
		# Case 1: It's already a valid type.
		_type = source
		if is_built_in() or is_native() or is_script():
			return
		# Case 2: It's an Object derived from a Script/Native class.
		elif source is Object:
			var object:Object = source
			var script:Script = object.get_script()
			# Case 2.1: It's a Script-derived Object.
			if script:
				_type = script
			# Case 2.2: It's a Native Object.
			else:
				_type = object.get_class()
		# Case 3: It's an Array.
		elif source is Array:
			var array:Array = source
			var type := get_array_type(array)
			if Veracity.catch_null(type, "Array has no type!"):
				return
			else:
				_type = type
		# Case 4: It is a built-in type (or dictionary).
		else:
			if source is Dictionary:
				var dictionary:Dictionary = source
				Veracity.probe(not dictionary.is_typed())
			_type = typeof(source)

func inherits(checking_type:Variant) -> bool:
	if Veracity.catch_null(checking_type):
		return false
	var checking_typr := Typr.new(checking_type)
	# Case 1: Incompatible forms.
	if not _form == checking_typr.get_form():
		return false
	# Case 2: Same type.
	elif _type == checking_typr.get_type():
		return true
	# Case 3: Both built-in, so they can't inherit
	elif is_built_in():
		return false
	# Case 4: Both Native.
	elif _form == Form.NATIVE:
		var native_class_name := get_native_class_name()
		var checking_native_class_name := checking_typr.get_native_class_name()
		return ClassDB.is_parent_class(native_class_name, checking_native_class_name)
	# Case 5: Both Script.
	elif _form == Form.SCRIPT:
		var script := get_type_script()
		var checking_script := checking_typr.get_type_script()
		return script_inherits(script, checking_script)
	Log.unreachable()
	return false
 
func _to_string() -> String:
	return get_name()

func inherited_by(variant:Variant) -> bool:
	if Veracity.catch_null(variant):
		return false
	var typr := Typr.new(variant)
	return inherits(typr)

func get_name() -> String:
	if is_built_in():
		var built_in_type := get_built_in_type()
		return type_string(built_in_type)
	elif is_native():
		return get_native_class_name()
	elif is_script():
		var script := get_type_script()
		var global_name := script.get_global_name()
		Veracity.enforce(not global_name.is_empty())
		return global_name
	Log.unreachable()
	return ""

func inherited_by_packed_scene(packed_scene:PackedScene) -> bool:
	if not packed_scene.can_instantiate():
		return false
	var scene := packed_scene.instantiate()
	var matches := inherited_by(scene)
	scene.queue_free()
	return matches

func same_as(type:Variant) -> bool:
	if Veracity.catch_null(type):
		return false
	var typr := Typr.new(type)
	return _type == typr.get_type()

func screen_get(variant:Variant) -> Variant:
	if inherited_by(variant):
		return variant
	if variant is Array:
		var array:Array = variant
		for element:Variant in array:
			if screen_get(element):
				return element
	return null
