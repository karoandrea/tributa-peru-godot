extends Node

enum Resultado { NORMAL, COBRO, GAME_OVER, VICTORIA }

const DIAS_POR_MES = 3
const MESES_PARA_GANAR = 3
const CLIENTES_POR_DIA = 3
const NUM_NPCS_TRIVIA = 4


var dinero = 100
var dia = 1
var mes = 1
var stock = 10
var cobro_mes = 500
var ventas_hoy = 0
var motivo_fin = ""
var trivia_hecha_hoy = false

# Para que el jugador aparezca bien al cambiar de escena
var tiene_spawn = false
var spawn_pos = Vector2.ZERO

func vender(precio) -> bool:
	if stock <= 0 or ventas_hoy >= CLIENTES_POR_DIA:
		return false
	stock -= 1
	ventas_hoy += 1
	dinero += precio
	return true

func comprar(cantidad, costo) -> bool:
	if dinero < costo:
		return false
	dinero -= costo
	stock += cantidad
	return true

func pasar_dia() -> Resultado:
	ventas_hoy = 0
	trivia_hecha_hoy = false  
	dia += 1
	if dia <= DIAS_POR_MES:
		return Resultado.NORMAL

	# Fin de mes: viene el cobrador
	if dinero < cobro_mes:
		motivo_fin = "No tenías dinero para pagar los arbitrios a la municipalidad.\nNecesitabas S/ %d y solo tenías S/ %d." % [cobro_mes, dinero]
		return Resultado.GAME_OVER
	dinero -= cobro_mes
	dia = 1
	mes += 1
	if mes > MESES_PARA_GANAR:
		motivo_fin = "Pagaste todos tus arbitrios a tiempo durante %d meses." % MESES_PARA_GANAR
		return Resultado.VICTORIA
	return Resultado.COBRO

func reiniciar():
	dinero = 100
	dia = 1
	mes = 1
	stock = 10
	cobro_mes = 500
	ventas_hoy = 0
	motivo_fin = ""
	tiene_spawn = false
	trivia_hecha_hoy = false

func npc_trivia_activo() -> int:
	return (dia - 1) % NUM_NPCS_TRIVIA
