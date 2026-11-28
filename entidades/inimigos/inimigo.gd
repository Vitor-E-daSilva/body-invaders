class_name InimigoBase
extends Area2D

# Sinaliza morte de um inimigo
signal morreu(enemy: InimigoBase, pontos: int)

# Variaveis gerais
@export var vida_max: int = 1
@export var valor_pontos: int = 10
@export var centro_largura: float = 8.0

# Variaveis de ataque
@export_group("Combate")
@export var pode_atacar: bool = false
@export var projetil: PackedScene

# Variaveis de aparencia/fisica
@onready var sprite: AnimatedSprite2D = $"AnimatedSprite2D"
@onready var hurtbox: CollisionShape2D = $CollisionShape2D
@onready var marcador: Marker2D = $Marker2D

# Variaveis internas
var _vida : int
var _morto: bool = false

func _ready() -> void:
	_vida = vida_max
	# Importante para lidar com projeteis
	monitoring = false
	monitorable = true

func tomar_dano(quantia : int) -> void:
	if _morto:
		return
	
	_vida -= quantia
	if _vida > 0:
		_flash_acerto()
	else:
		_morte()

# Serve para manter animação de inimigos
func avancar_frame_animacao() -> void:
	if _morto or sprite.animation != &"mover":
		return
	
	var total_frames: int = sprite.sprite_frames.get_frame_count(&"mover")
	if total_frames > 0:
		sprite.frame = (sprite.frame +1) % total_frames
		

func atacar() -> void:
	if _morto or not pode_atacar or projetil == null:
		return

	var projetil_var: Node2D = projetil.instantiate()
	var container = get_tree().get_first_node_in_group("projeteis")
	if container != null:
		container.add_child(projetil_var)
		projetil_var.global_position = marcador.global_position

# Usa uma tween para dar um flash básico de acerto
func _flash_acerto() -> void:
	var tween : Tween = create_tween()
	sprite.modulate = Color(2.5,2.5,1.0)
	tween.tween_property(sprite,"modulate", Color.WHITE, 0.1)

func _morte() -> void:	
	_morto = true
	hurtbox.set_deferred("Disabled", true)
	
	# Emite o sinal de morte
	morreu.emit(self, valor_pontos)
	
	if sprite.sprite_frames.has_animation(&"morte"):
		sprite.play(&"morte")
		sprite.animation_finished.connect(queue_free, CONNECT_ONE_SHOT)
	else:
		queue_free()
