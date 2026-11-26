extends Node

signal pontuacao_mudou(nova_pontuacao)
signal maior_pontuacao_mudou(nova_pontuacao)

var _pontuacao: int = 0
var _maior_pontuacao: int = 0

func adicionar_pontos(pontos: int):
	_pontuacao += pontos
	pontuacao_mudou.emit(_pontuacao)
	
	if _pontuacao > _maior_pontuacao:
		_maior_pontuacao = _pontuacao
		maior_pontuacao_mudou.emit(_maior_pontuacao)
		
func resetar():
	_pontuacao = 0
	pontuacao_mudou.emit(_pontuacao)
