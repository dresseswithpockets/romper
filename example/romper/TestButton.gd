extends Button

const simple = preload("res://romper/simple.gdns")
onready var data = simple.new()

func _on_Button_pressed():
	print("Data = " + data.get_data())
