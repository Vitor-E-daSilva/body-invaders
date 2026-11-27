class_name Nivel
extends Node

signal nivel_concluido
signal nivel_falho

# Variaveis gerais
@export var onda_cena: PackedScene
@export var layouts_faceis: Array[LayoutOnda]
@export var layouts_nedios: Array[LayoutOnda]
@export var layouts_dificeis: Array[LayoutOnda]
@export var inimigo_bonus: PackedScene
@export var maximo_ondas: float = 5
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
var _layout_anterior: LayoutOnda = null
var _possiveis_layouts: Array[LayoutOnda] = []
var _posicao_onda: float # Junto com as debaixo definem eixo y de spawn da onda
var _posicao_padrao_onda: float = 50 
var _posicao_limite_onda: float = 100 
var _intervalo_spawn: float = 10 
var _intervalo_disparo: float = 1
var _vida_jogador: int


func _ready() -> void:
	# Declaração dos parametros de timer
	tempo_disparo_jogador.timeout.connect(_parada_tempo_disparo)
	tempo_disparo_jogador.wait_time = _intervalo_disparo
	tempo_spawn.timeout.connect(_spawnar_onda)
	tempo_spawn.wait_time = _intervalo_spawn
	
	# Declaração dos parametros de onda
	onda.onda_derotada.connect(_onda_derrotada)
	onda.onda_venceu.connect(_derrota)
	onda.adquiriu_pontos.connect(_aumentar_pontuacao)
	_posicao_onda = _posicao_padrao_onda
	onda.position = Vector2(20,_posicao_onda)
	_spawnar_onda()
	
	# Declaração de váriaves para o player
	jogador.jogador_atacou.connect(_ataque_jogador)
	jogador.jogador_morreu.connect(_derrota)
	jogador.jogador_tomou_dano.connect(_jogador_perdeu_vida)
	_vida_jogador = jogador.vida_max

func _spawnar_onda() -> void:
	if _onda_atual >= maximo_ondas:
		nivel_concluido.emit()
		return
		 
	var _media_ondas: float = maximo_ondas/3
	
	if _onda_atual <= _media_ondas:
		_possiveis_layouts = layouts_faceis
	elif _onda_atual <= _media_ondas*2:
		_possiveis_layouts = layouts_nedios
	else:
		_possiveis_layouts = layouts_dificeis
		
	tempo_spawn.stop()
	if _possiveis_layouts.size() > 1 and _layout_anterior in _possiveis_layouts:
		_possiveis_layouts.erase(_layout_anterior)

	onda.layout = _escolher_layout(_possiveis_layouts)
	if _onda_atual > 1:
		onda.layout.intervalo_disparo *= escala_intervalo_disparo
		onda.layout.intervalo_base_movimento *= escala_intervalo_movimento
	onda._spawn_onda()

func _escolher_layout(layouts: Array[LayoutOnda]) -> LayoutOnda:
	return layouts.pick_random()

func _onda_derrotada() -> void:
	_layout_anterior = onda.layout
	_posicao_onda += 20
	if _posicao_onda <= _posicao_limite_onda:	
		onda.position = Vector2(20, _posicao_onda)
	else:
		onda.position = Vector2(20, _posicao_limite_onda)
	tempo_spawn.start()
	print("Pontuação:", _pontuacao)
	print("Maior:", _maior_pontuacao)

func _ataque_jogador() -> void:
	jogador.pode_atacar = false
	tempo_disparo_jogador.start()

func _parada_tempo_disparo() -> void:
	jogador.pode_atacar = true
	tempo_disparo_jogador.stop()

func _jogador_perdeu_vida(_vida_restante: int) -> void:
	_vida_jogador =_vida_restante
	_avancar_frame_animacao()
	
func _avancar_frame_animacao() -> void:
	var total_frames: int = background.sprite_frames.get_frame_count(&"default")
	if total_frames > 0:
		background.frame = (background.frame +1) % total_frames

func _derrota() -> void:
	nivel_falho.emit()

func _aumentar_pontuacao(_pontos: int) -> void:
	_pontuacao += _pontos
	if _pontuacao > _maior_pontuacao:
		_maior_pontuacao = _pontuacao
