extends CharacterBody2D

const VELOCIDAD = 150.0
@onready var animacion = $AnimatedSprite2D

func _physics_process(_delta):
	var dir = Input.get_vector("IZQUIERDA", "DERECHA", "ARRIBA", "ABAJO")
	velocity = dir * VELOCIDAD
	move_and_slide()

	if dir == Vector2.ZERO:
		animacion.stop()
	elif abs(dir.x) > abs(dir.y):
		animacion.play("derecha" if dir.x > 0 else "izquierda")
	else:
		animacion.play("abajo" if dir.y > 0 else "arriba")
		
	move_and_slide()
