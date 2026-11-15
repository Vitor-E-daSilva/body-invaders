extends Node2D

# Função de iniciação da tela principal
func _process(_delta):
	get_tree().change_scene_to_file("res://niveis/nivel1.tscn")
