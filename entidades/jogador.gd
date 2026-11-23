extends CharacterBody2D
#variaveis do jogador
#@export antes de var para aperecer no painel do inspetor do Godot
@export var velocidade: float = 300.0
@export var margem_borda: float = 16.0


var _largura_tela: float
func _ready() -> void: #função para pegar a largura da tela. Roda uma única vez quando o jogador entra na tela
	_largura_tela = get_viewport_rect().size.x

#função que lê o teclado e aplica o movimento continuamente. Roda 60 vezes por segundo 
func _physics_process(_delta: float) -> void:
	_atualizar_movimento()
	move_and_slide()
	_limitar_na_tela()

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
