class_name Nivel
extends Node

signal nivel_concluido
signal nivel_falho

# Variaveis gerais
@export var layouts_faceis: Array[LayoutOnda]
@export var layouts_medios: Array[LayoutOnda]
@export var layouts_dificeis: Array[LayoutOnda]
@export var inimigo_bonus: PackedScene
@export var maximo_ondas: float = 3
@export var intervalo_base_disparo: int
@export var escala_intervalo_movimento: float = 0.9 # Escala para diminuir o intervalo de acordo com a onda
@export var escala_intervalo_disparo: float = 0.9

# Declarações omready
@onready var background: AnimatedSprite2D = $AnimatedSprite2D
@onready var onda: Onda = $Onda
@onready var jogador: JogadorBase = $Jogador
@onready var tempo_spawn: Timer = $TimerSpawn
@onready var tempo_disparo_jogador: Timer = $TimerDisparo
@onready var tempo_spawn_jogador: Timer = $TimerSpawnJogador
@onready var tempo_inimigo_bonus: Timer = $TimerBonus
@onready var tempo_movimento_inimigo_bonus: Timer = $TimerBonusMov

# Variaveis internas
var _pontuacao: int = 0
var _maior_pontuacao: int
var _onda_atual: int = 1
var _layout_anterior: LayoutOnda = null
var _possiveis_layouts: Array[LayoutOnda] = []
var _inimigo_bonus: InimigoBase = null
var _chance_de_spawn: float = 80
var _posicao_onda: float # Junto com as debaixo definem eixo y de spawn da onda
var _posicao_padrao_onda: float = 50 
var _posicao_limite_onda: float = 100 
var _vida_jogador: int
var _pausado: bool = false
# Variaveis de inimigo bonus
var _intervalo_spawn: float = 5 
var _intervalo_disparo: float = 1
var _intervalo_inimigo_bonus: float = 30.0
var _intervalo_movimento_inimigo_bonus: float = 0.25
var _direcao : int = 1
var _margem_esquerda: int = 20
var _margem_direita: int = 250


func _ready() -> void:
	# Declaração dos parametros de timer
	tempo_disparo_jogador.timeout.connect(_parada_tempo_disparo)
	tempo_disparo_jogador.wait_time = _intervalo_disparo
	tempo_spawn.timeout.connect(_spawnar_onda)
	tempo_spawn.wait_time = _intervalo_spawn
	tempo_spawn_jogador.wait_time = 1
	tempo_spawn_jogador.timeout.connect(_restaurar_jogador)
	tempo_inimigo_bonus.wait_time = _intervalo_inimigo_bonus
	tempo_inimigo_bonus.timeout.connect(_spawnar_inimigo_bonus)
	tempo_movimento_inimigo_bonus.wait_time = _intervalo_movimento_inimigo_bonus
	tempo_movimento_inimigo_bonus.timeout.connect(_mover_inimigo_bonus)
	
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

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("sair"):
		_pausar()

func _pausar() -> void:
	if not _pausado:
		get_tree().paused = true
		_pausado = true
	else:
		get_tree().paused = false
		_pausado = false

func _spawnar_onda() -> void:
	if _onda_atual >= maximo_ondas:
		nivel_concluido.emit()
		return
		 
	var _media_ondas: float = maximo_ondas/3
	
	if _onda_atual <= _media_ondas:
		_possiveis_layouts = layouts_faceis
	elif _onda_atual <= _media_ondas*2:
		_possiveis_layouts = layouts_medios
	else:
		_possiveis_layouts = layouts_dificeis
		
	tempo_spawn.stop()
	if _possiveis_layouts.size() > 1 and _layout_anterior in _possiveis_layouts:
		_possiveis_layouts.erase(_layout_anterior)

	onda.layout = _escolher_layout(_possiveis_layouts)
	if _onda_atual > 1:
		onda.layout.intervalo_disparo *= escala_intervalo_disparo
		onda.layout.intervalo_base_movimento *= escala_intervalo_movimento
	_onda_atual += 1
	onda._spawn_onda()
	tempo_inimigo_bonus.start()

func _escolher_layout(layouts: Array[LayoutOnda]) -> LayoutOnda:
	return layouts.pick_random()

func _onda_derrotada() -> void:
	_layout_anterior = onda.layout
	_posicao_onda += 20
	if _posicao_onda <= _posicao_limite_onda:	
		onda.position = Vector2(20, _posicao_onda)
	else:
		onda.position = Vector2(20, _posicao_limite_onda)
	tempo_inimigo_bonus.stop()
	tempo_spawn.start()
	
	print("Pontuação:", _pontuacao)
	print("Maior:", _maior_pontuacao)

func _spawnar_inimigo_bonus() -> void:
	if _inimigo_bonus != null:
		_inimigo_bonus.queue_free()
		return
		
	if _chance_spawn(_chance_de_spawn):
		print("A")
		_inimigo_bonus = inimigo_bonus.instantiate() as InimigoBase
		_inimigo_bonus.position = Vector2(20,30)
		add_child(_inimigo_bonus)
		tempo_movimento_inimigo_bonus.start()
	

func _chance_spawn(porcentagem:float) -> bool:
	return randf()*100 < porcentagem

func _mover_inimigo_bonus() -> void:
	if _inimigo_bonus == null:
		return
	
	var movimento: float = 10 * _direcao
	var acertou_direita: bool = _direcao > 0 and (_inimigo_bonus.position.x + movimento > _margem_direita)
	var acertou_esquerda: bool = _direcao < 0  and (_inimigo_bonus.position.x + movimento < _margem_esquerda)
	if acertou_direita or acertou_esquerda:
		_direcao *= -1
		
	_inimigo_bonus.position.x += 5.0 * _direcao
	_inimigo_bonus.avancar_frame_animacao()
	
func _ataque_jogador() -> void:
	if jogador._morto:
		return
		
	jogador.pode_atacar = false
	tempo_disparo_jogador.start()

func _parada_tempo_disparo() -> void:
	jogador.pode_atacar = true
	tempo_disparo_jogador.stop()

func _jogador_perdeu_vida(_vida_restante: int) -> void:
	_vida_jogador =_vida_restante
	_avancar_frame_animacao()
	_respawnar_jogador()
	
func _avancar_frame_animacao() -> void:
	var tween: Tween = create_tween()
	background.modulate = Color.RED
	tween.tween_property(background,"modulate", Color.WHITE, 1.0)
	
	var total_frames: int = background.sprite_frames.get_frame_count(&"default")
	if total_frames > 0:
		background.frame = (background.frame +1) % total_frames

func _respawnar_jogador() -> void:
	if jogador._morto:
		return
		
	# Declara atributos
	var tween: Tween = create_tween()
	jogador.vulneravel = false
	jogador.pode_mover = false 
	jogador.pode_atacar = false
	jogador.visible = false
	jogador.position = Vector2(100,320)
	
	# Executa animação e retorna atributos oa normal
	tempo_spawn_jogador.start()
	tween.tween_property(jogador,"visible", true, 0.5)
	tween.tween_property(jogador,"position",Vector2(135,320),0.5)
	
func _restaurar_jogador() -> void:
	jogador.pode_mover = true
	jogador.vulneravel = true
	jogador.pode_atacar = true
	tempo_spawn_jogador.stop()
	
func _derrota() -> void:
	nivel_falho.emit()

func _aumentar_pontuacao(_pontos: int) -> void:
	_pontuacao += _pontos
	if _pontuacao > _maior_pontuacao:
		_maior_pontuacao = _pontuacao
