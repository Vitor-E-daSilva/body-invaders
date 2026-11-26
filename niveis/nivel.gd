class_name Nivel
extends Node

signal nivel_concluido
signal nivel_falho

# Variaveis gerais
@export var onda_cena: PackedScene
@export var layouts: Array[LayoutOnda]
@export var inimigo_bonus: PackedScene
@export var maximo_ondas: int
@export var intervalo_base_disparo: int
@export var _escala_intervalo_movimento: float = 0.9 # Escala para diminuir o intervalo de acordo com a onda
@export var _escala_intervalo_disparo: float = 0.9

# Declarações omready
@onready var background: AnimatedSprite2D = $AnimatedSprite2D
@onready var onda: Onda = $Onda
@onready var jogador: JogadorBase = $Jogador
@onready var tempo_spawn: Timer = $TimerSpawn
@onready var tempo_disparo_jogador: Timer = $TimerDisparo

# Variaveis internas
var _onda_atual: int = 1
var _onda_ativa: Onda
var _possiveis_layouts: Array[LayoutOnda] = []
var _posicao_onda: float # Junto com as debaixo definem eixo y de spawn da onda
var _posicao_padrao_onda: float = 50 
var _posicao_limite_onda: float = 100 

func _ready() -> void:
	tempo_disparo_jogador.timeout.connect(_parada_tempo_disparo)
	tempo_spawn.timeout.connect(_spawnar_onda)
	_posicao_onda = _posicao_padrao_onda

func _spawnar_onda() -> void:
	pass

func _parada_tempo_disparo() -> void:
	jogador.pode_atacar = true
