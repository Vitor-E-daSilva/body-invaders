class_name Projetil
extends Area2D

# Variaveis padrao
@export var velocidade: float = 150
@export var direcao: Vector2 = Vector2.UP
@export var dano: int = 1
@export var destrutivel: bool = false
@export var durabilidade: int = 1

# Nodes necessarios
@onready var sprite: Sprite2D = $Sprite2D
@onready var notificaco_tela: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

var _acertou: bool = false

func _ready() -> void:
	monitoring = true
	monitorable = destrutivel
	
	area_entered.connect(_acertar_alvo)
	body_entered.connect(_acertar_alvo)
	notificaco_tela.screen_exited.connect(queue_free)

func _physics_process(delta: float) -> void:
	position += direcao.normalized() * velocidade * delta
	
func _acertar_alvo(alvo: Node) -> void:
	if _acertou:
		return
	
	if alvo.has_method(&"tomar_dano"):
		_acertou = true
		alvo.tomar_dano(dano)
		queue_free()
	
	if alvo.has_method(&"diminuir_durabilidade"):
		alvo.diminuir_durabilidade(dano)

func diminuir_durabilidade(_quantidade: int):
	if _acertou or not destrutivel:
		return
	durabilidade -= _quantidade
	
	if durabilidade <= 0:
		_acertou = true
		queue_free()
