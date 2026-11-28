class_name Onda
extends Node2D

signal onda_derotada
signal onda_venceu
signal adquiriu_pontos(pontos)

# Variaveis gloabais da onda
@export var layout: LayoutOnda
@export var margem_esquerda: float = 10.0
@export var margem_direita: float = 240.0
@export var canto_y: float = 360
@export var intervalo_minimo_movimento: float = 0.05

# Nodes padrão da onda
@onready var container_inimigos: Node2D = $Inimigos
@onready var tempo_movimento: Timer = $TimerMovimento
@onready var tempo_disparo: Timer = $TimerDisparo

# Inicializa o esquema para spawnar os inimigos
var _grid: Array[Array] = []
var _contador_coluna: int = 0
var _contador_linha: int = 0
var _direcao: int = 1
var _inimigos_iniciais: int = 0
var _inimigos_vivos: int = 0
var _atirador_anterior: InimigoBase

# Configura os timers e chama o spawn da onda
func _ready() -> void:
	tempo_movimento.timeout.connect(_parada_tempo_movimento)
	tempo_disparo.timeout.connect(_parada_tempo_disparo)

# Spawna onda usando o recurso
func _spawn_onda() -> void:
	if layout == null:
		push_error("Layout de onda não encontrado")
		return
		
	# Conta o número de colunas
	_contador_linha = layout.formacao_linhas.size()
	_contador_coluna = 0
	for linha_str: String in layout.formacao_linhas:
		_contador_coluna = maxi(_contador_coluna, linha_str.length())
	
	# Ajusta a grid para spawnar os inimigos
	_grid.clear()
	for col: int in range(_contador_coluna):
		var array_colunas: Array[InimigoBase] = []
		array_colunas.resize(_contador_coluna)
		_grid.append(array_colunas)
	
	for linha: int in range(_contador_linha):
		var linha_str: String = layout.formacao_linhas[linha]
		for coluna: int in range(_contador_coluna):
			# Declara um token para checagem de registro de inimigos
			var token: String = linha_str[coluna]
			if token == ".":
				continue
			if not layout.paleta_inimigos.has(token):
				push_warning("Token de inimigo não encontrado")
				continue
			
			# Coleta a cena do inimigo usando o token
			var cena: PackedScene = layout.paleta_inimigos[token]
			if cena == null:
				continue
			
			# Declara o inimigo, sua posição e o adiciona a onda
			var inimigo := cena.instantiate() as InimigoBase
			inimigo.position = Vector2(coluna,linha) * layout.espacamento
			container_inimigos.add_child(inimigo)
			
			#Ajusta o grid de acordo com o loop
			_grid[coluna][linha] = inimigo
			_inimigos_iniciais += 1
			_inimigos_vivos += 1
			inimigo.morreu.connect(_inimigo_morreu.bind(coluna, linha))
			
	# Retorna se a onda estiver vazia
	if _inimigos_iniciais == 0:
		onda_derotada.emit()
		return
		
	tempo_movimento.wait_time = layout.intervalo_base_movimento
	tempo_disparo.wait_time = layout.intervalo_disparo
	tempo_movimento.start()
	tempo_disparo.start()

# Lida com o timer de movimento
func _parada_tempo_movimento() -> void:
	if _inimigos_vivos <= 0:
		return
	
	# Declara as coordenadas das bordas
	var min_x: float = INF
	var max_x: float = -INF
	var max_y: float = -INF
	
	# Procura os valores de x e y
	for coluna: int in range(_contador_coluna):
		for linha: int in range(_contador_linha):
			var inimigo: InimigoBase = _grid[coluna][linha]
			if inimigo == null:
				continue
			min_x = minf(min_x, inimigo.global_position.x - inimigo.centro_largura)
			max_x = maxf(max_x, inimigo.global_position.x - inimigo.centro_largura)
			max_y = maxf(max_y, inimigo.global_position.y)
	
	#Declara o movimento e se ele alcançou uma das bordas
	var movimento: float = layout.distancia_movimento * _direcao
	var acertou_direita: bool = _direcao > 0 and (max_x + movimento > margem_direita)
	var acertou_esquerda: bool = _direcao < 0  and (min_x + movimento < margem_esquerda)
	
	# Muda a direção de movimento ao atingir as bordas ou emite uma derrota se os inimigos chegarem ao fim
	if acertou_direita or acertou_esquerda:
		position.y += layout.distancia_queda
		_direcao *= -1
		
	if max_y + layout.distancia_queda >= canto_y:
		tempo_movimento.stop()
		tempo_disparo.stop()
		onda_venceu.emit()
		print("Onda venceu")
		return
	else:
		position.x += movimento
		
	for coluna: int in range(_contador_coluna):
		for linha: int in range(_contador_linha):
			var inimigo: InimigoBase = _grid[coluna][linha]
			if inimigo != null:
	
				inimigo.avancar_frame_animacao()

# Lida com o timer de disparo
func _parada_tempo_disparo() -> void:
	if _inimigos_vivos <= 0:
		return
	
	var possiveis_atiradores: Array[InimigoBase] = []
	
	for coluna: int in range(_contador_coluna):
		for linha: int in range(_contador_linha -1, -1,-1):
			var inimigo: InimigoBase = _grid[coluna][linha]
			if inimigo != null:
				if inimigo.pode_atacar:
					possiveis_atiradores.append(inimigo)
				break
	
	if possiveis_atiradores.is_empty():
		return
	
	if possiveis_atiradores.size() > 1 and _atirador_anterior in possiveis_atiradores:
		possiveis_atiradores.erase(_atirador_anterior)
		
	var escolhido: InimigoBase = _escolher_atirador(possiveis_atiradores)
	_atirador_anterior = escolhido
	escolhido.atacar()

# Função auxiliar para selecionar inimigo aleatório
func _escolher_atirador(atiradores: Array[InimigoBase]) -> InimigoBase:
	return atiradores.pick_random()

# Lida com morte de inimigos
func _inimigo_morreu(_inimigo: InimigoBase, _pontos: int, coluna: int, linha: int) -> void:
	_grid[coluna][linha] = null
	_inimigos_vivos -= 1
	if _inimigo == _atirador_anterior:
		_atirador_anterior = null
	
	if _inimigos_vivos <= 0:
		tempo_movimento.stop()
		tempo_disparo.stop()
		onda_derotada.emit()
		return
	
	adquiriu_pontos.emit(_pontos)
	var media_restante: float = float(_inimigos_vivos) / float(_inimigos_iniciais)
	tempo_movimento.wait_time  = maxf(intervalo_minimo_movimento, layout.intervalo_base_movimento * media_restante)
