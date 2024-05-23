extends Control

# donde fue pulsado el clic L
var mouse_R = Vector2(0, 0)
var viewp_R = Vector2(0, 0)

# conexion
var lineas = null

# data
var indice = -1
var conexion = -1
var raiz = null

func _ready():
	raiz = get_node("..").get_node("..")
	$Selection.visible = false

func SetSelected(isSelected):
	$Selection.visible = isSelected

func _process(_delta):
	# mover ticket
	if mouse_R.x != 0 or mouse_R.y != 0:
		var pos = get_global_mouse_position()
		position = viewp_R + (pos - mouse_R)
		lineas.position = position
		if raiz.get_node("Redibuja").is_stopped():
			raiz.pordibujar.append(self)
			raiz.get_node("Redibuja").start()

func GetTicket():
	return [
		position.x,
		position.y,
		indice,
		conexion
	]

func _on_bot_halar_button_down():
	mouse_R = get_global_mouse_position()
	viewp_R = global_position

func _on_bot_halar_button_up():
	mouse_R = Vector2(0, 0)
