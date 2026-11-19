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
@onready var sprite: Sprite2D = $Sprite2D
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
	if _vida < 0:
		_morte()

func atacar() -> void:
	if _morto or not pode_atacar or projetil == null:
		return
	pass

func _morte() -> void:
	
	_morto = true
	hurtbox.set_deferred("Disabled", true)
	
	# Emite o sinal de morte
	morreu.emit(self, valor_pontos)
	queue_free()
