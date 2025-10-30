extends Window

@onready var theory_text: RichTextLabel = $MarginContainer/RichTextLabel

func _ready():
	close_requested.connect(hide)
	title = "Theory"
	visible = false
	
func set_theory_text(text: String):
	if theory_text:
		theory_text.text = text
