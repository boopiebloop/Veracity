# ---------------------------------------------------------------------------------------------- #
##
# ---------------------------------------------------------------------------------------------- #


class_name VeracityDockErrorUI
extends Control


static func from_template() -> VeracityDockErrorUI:
	return preload("res://addons/veracity/ui/dock/veracity_dock.tscn").instantiate()
