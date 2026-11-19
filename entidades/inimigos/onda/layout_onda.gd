class_name LayoutOnda
extends Resource

# Schema da onda
@export var formacao_colunas: Array[String] = [
	"AAAAAAAAAAA",
	"BBBBBBBBBBB",
	"BBBBBBBBBBB",   
	"VVVVVVVVVVV",  
	"VVVVVVVVVVV",
]

# Converte o schema
@export var paleta_inimigos: Dictionary = {}

@export_group("Grade")
@export var espacamento: Vector2 = Vector2(48.0, 36.0)

@export_group("Dados de Onda")
@export var intervalo_base_movimento : float = 0.5
@export var distancia_movimento : float = 16.0
@export var distancia_queda : float = 24.0
@export var intervalo_disparo : float = 1.0 
