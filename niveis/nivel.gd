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
@export var escala_intervalo_movimento: float = 0.9 # Escala para diminuir o intervalo de acordo com a onda
@export var escala_intervalo_disparo: float = 0.9

# Declarações omready
@onready var background: AnimatedSprite2D = $AnimatedSprite2D
@onready var onda: Onda = $Onda
@onready var jogador: JogadorBase = $Jogador
@onready var tempo_spawn: Timer = $TimerSpawn
@onready var tempo_disparo_jogador: Timer = $TimerDisparo

# Variaveis internas
var _pontuacao: int = 0
var _maior_pontuacao: int
var _onda_atual: int = 1
var _onda_ativa: Onda = null
var _layout_anterior: LayoutOnda = null
var _possiveis_layouts: Array[LayoutOnda] = []
var _posicao_onda: float # Junto com as debaixo definem eixo y de spawn da onda
var _posicao_padrao_onda: float = 50 
var _posicao_limite_onda: float = 100 
var _intervalo_spawn: float = 10
var _intervalo_disparo: float = 1


func _ready() -> void:
	tempo_disparo_jogador.timeout.connect(_parada_tempo_disparo)
	tempo_spawn.timeout.connect(_spawnar_onda)
	onda.onda_derotada.connect(_onda_derrotada)
	_posicao_onda = _posicao_padrao_onda
	_possiveis_layouts = layouts
	onda.position = Vector2(20,_posicao_onda)
	_spawnar_onda()

func _spawnar_onda() -> void:
	tempo_spawn.stop()
	print(_possiveis_layouts)
	if _possiveis_layouts.size() > 1 and _layout_anterior in _possiveis_layouts:
		_possiveis_layouts.erase(_layout_anterior)

	onda.layout = _escolher_layout(_possiveis_layouts)
	onda._spawn_onda()


func _escolher_layout(layouts: Array[LayoutOnda]) -> LayoutOnda:
	return layouts.pick_random()

func _onda_derrotada() -> void:
	_layout_anterior = onda.layout
	_posicao_onda += 20
	onda.position = Vector2(20, _posicao_onda)
	tempo_spawn.start()

func _parada_tempo_disparo() -> void:
	pass
