class_name JogadorBase
extends CharacterBody2D

signal jogador_morreu()

#variaveis do jogador
#@export antes de var para aperecer no painel do inspetor do Godot
@export var vida_max: int = 3
@export var velocidade: float = 300.0
@export var margem_borda: float = 16.0

# Declaração de variaveis dos nós filhos
@onready var sprite: Sprite2D = $SpriteJogador
@onready var marcador: Marker2D = $Marker2D
@onready var hurtbox: CollisionShape2D = $CollisionShape2D

# Variaveis de ataque
@export_group("Combate")
@export var pode_atacar: bool = true
@export var projetil: PackedScene

# Variáveis internas
var _largura_tela: float
var _vida: int
var _morto: bool = false

func _ready() -> void: #função para pegar a largura da tela. Roda uma única vez quando o jogador entra na tela
	_largura_tela = get_viewport_rect().size.x
	_vida = vida_max

#função que lê o teclado e aplica o movimento continuamente. Roda 60 vezes por segundo 
func _physics_process(_delta: float) -> void:
	_atualizar_movimento()
	move_and_slide()
	_limitar_na_tela()
	if Input.is_action_just_pressed("ataque"):
		atacar()

#função que identifica se o jogador apertou para esquerda ou pra direita
func _atualizar_movimento() -> void:
	#Se apertar Esquerda: direcao vale -1
	#Se apertar Direita: direcao vale 1
	var direcao: float = Input.get_axis("ui_left", "ui_right")
	velocity.x = direcao * velocidade #define a velocidade do jogador em x, e a armazena na variavel que ja vem embutida no CharacterBody2D.
	velocity.y = 0.0 #Como é inspirado no Space Invaders, o personagem não sobe nem desce

#Para função que impede que a nave saia pelas bordas esquerda ou direita da janela
func _limitar_na_tela() -> void:
	global_position.x = clamp(global_position.x, margem_borda, _largura_tela - margem_borda)

func atacar() -> void:
	if _morto or not pode_atacar:
		return

	var projetil_var: Node2D = projetil.instantiate()
	projetil_var.top_level = true
	projetil_var.global_position = marcador.global_position
	add_child(projetil_var)

# Função para receber hits
func tomar_dano(quantia: int) -> void:
	if _morto:
		return
		
	_vida -= quantia
	if _vida > 0:
		_flash_acerto()
	else:
		_morte()

func _flash_acerto() -> void:
	var tween : Tween = create_tween()
	sprite.modulate = Color(2.5,2.5,1.0)
	tween.tween_property(sprite,"modulate", Color.WHITE, 0.1)

func _morte() -> void:	
	_morto = true
	hurtbox.set_deferred("Disabled", true)

	# Emite o sinal de morte
	jogador_morreu.emit()
	queue_free()
