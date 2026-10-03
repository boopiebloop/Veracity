@tool
class_name Veracity


const DIRECTORY := "res://addons/veracity/"

static var _critical_errors:Array[String] = []

static func _add_critical_error(details:String) -> void:
	if not _critical_errors.has(details):
		_critical_errors.append(details)

static func _remove_critical_error(details:String) -> void:
	_critical_errors.erase(details)

## Checks for an assertion and calls [method report_error] if the assertion fails.
static func enforce(boolean:bool, msg:String = "", is_warning:bool = false) -> void:
	if not boolean:
		if is_warning:
			Log.warning("Assertion failed: " + msg, true)
		else:
			Log.critical("Assertion failed: " + msg, true)

static func check_illegal_setter(value:Variant, corrected_value:Variant) -> Variant:
	if not value == corrected_value:
		Log.warning("Illegal value passed to setter!")
	return corrected_value

static func check_typed_packed_scene_setter(current_value:PackedScene, new_value:PackedScene, 
	type:Variant) -> PackedScene:
		if not new_value:
			return new_value
		var typr := Typr.new(type)
		if typr.inherited_by_packed_scene(new_value):
			return new_value
		else:
			Log.error("Wrong PackedScene type! Expected %s." % typr.get_name())
			return current_value

static func is_null(variant:Variant) -> bool:
	if variant == null:
		return true
	elif variant is Array:
		var array:Array = variant
		return array.any(is_null)
	elif variant is Dictionary:
		var dictionary:Dictionary = variant
		return dictionary.keys().any(is_null) or dictionary.values().any(is_null)
	return false

static func safe_get(value:Variant, value_if_null:Variant) -> Variant:
	if not is_null(value):
		return value
	else:
		return Veracity.catch_null(value_if_null, "value_if_null can't be null!")

static func screen_get(value:Variant, value_if_null:Variant = null, fail_cause:String = "Caught Null Value!") -> Variant:
	if catch_null(value, fail_cause):
		return value_if_null
	else:
		return value

static func catch_null(value:Variant, fail_cause:String = "Caught Null Value!") -> bool:
	var value_null:bool = is_null(value)
	if value_null:
		Log.error(fail_cause)
	return value_null

static func catch_null_setter(current_value:Variant, new_value:Variant) -> Variant:
	if is_null(new_value):
		Log.error("Caught a null value passed to a non-null setter!")
		return current_value
	else:
		return new_value

static func ensure(value:Variant, assertion:bool = true, fail_cause:String = "") -> Variant:
	var valid := _is_valid(value)
	if not valid:
		Log.critical("Value Validation Failed: %s" % _get_fail_cause(value, assertion, fail_cause))
	return value

static func probe(state:bool, 
	fail_cause:String = "Illegal state detected! Undefined behaviour may follow...") -> bool:
		if not state:
			Log.error(fail_cause, true)
		return state

static func catch_illegal_states(state_checks:Dictionary[bool, String]) -> bool:
	var failed:bool = false
	var errors:String = ""
	var states := state_checks.keys()
	for i in range(states.size()):
		var state:bool = states[i]
		if not state:
			var fail_cause := state_checks[state]
			if fail_cause.is_empty():
				fail_cause = "Detected false"
			errors += "[indent]Failed State %s: %s![/indent]" %  [i + 1, fail_cause]
			failed = true
	if failed:
		Log.error(errors, true)
	return failed

static func _get_fail_cause(value:Variant, assertion:bool, fail_cause:String) -> String:
	if fail_cause.is_empty():
		if is_null(value):
			fail_cause += "Caught null value! "
		if not assertion:
			fail_cause += "Failed assertion! "
	return fail_cause

static func _is_valid(value:Variant, assertion:bool = true) -> bool:
	return not is_null(value) and assertion

static func unreachable(cause:String = "Unreachable statement?", return_value:Variant = null) -> Variant:
	Log.error(cause)
	return return_value
