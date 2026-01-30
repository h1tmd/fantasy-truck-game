# In the script of the parent Control node
extends Control

func _ready():
	$UpButton.action_name = "car_forward"
	$DownButton.action_name = "car_reverse"
	$LeftButton.action_name = "car_left"
	$RightButton.action_name = "car_right"
