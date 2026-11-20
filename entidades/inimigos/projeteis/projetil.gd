class_name ProjetilInimigo
extends Area2D

# Variaveis padrao
@export var velocidade: float = 300
@export var dano: int = 1

# Nodes necessarios
@onready var sprite: Sprite2D = $Sprite2D
@onready var notificaco_tela: VisibleOnScreenNotifier2D = %VisibleOnScreenNotifier2D

var _acertou: bool = false

func _ready() -> void:
	monitoring = true
	
	area_entered.connect(_acertar_alvo)
	body_entered.connect(_acertar_alvo)
	notificaco_tela.screen_exited.connect(queue_free)

func _physics_process(delta: float) -> void:
	position.y += velocidade * delta
	
func _acertar_alvo(alvo: Node) -> void:
	if _acertou:
		return
	
	if alvo.has_method(&"tomar_dano"):
		_acertou = true
		alvo.tomar_dano(dano)
		queue_free()
