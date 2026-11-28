class_name LayoutOnda
extends Resource

# Schema da onda
@export var formacao_linhas: Array[String] = [
	"AAAAAAAAAAA",
	"BBBBBBBBBBB",
	"BBBBBBBBBBB",
	"VVVVVVVVVVV",  
	"VVVVVVVVVVV",
]

# Converte o schema
@export var paleta_inimigos: Dictionary = {}

@export_group("Grade")
@export var espacamento: Vector2 = Vector2(20.0, 20.0)

@export_group("Dados de Onda")
@export var intervalo_base_movimento : float = 1.0
@export var distancia_movimento : float = 5.0
@export var distancia_queda : float = 5.0
@export var intervalo_disparo : float = 4.0
