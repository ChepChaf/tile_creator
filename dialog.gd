tool
extends ConfirmationDialog
var initialized = false

func _ready():
	if initialized:
		return
	initialized = true