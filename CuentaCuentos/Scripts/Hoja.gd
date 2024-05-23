extends Control

const colur = [
	Color8(75, 75, 75), # negro: solo
	Color8(100, 100, 50), # amarillo: A+B
	Color8(50, 100, 50), # verde: final
	Color8(100, 50, 50), # rojo: especial
	Color8(50, 50, 100) # azul: A
]

# donde fue pulsado el clic L
var mouse_R = Vector2(0, 0)
var viewp_R = Vector2(0, 0)

# conexion
var pulsado = ""
var lineas = null

# data
var especial = false
var indice = -1
var conexion = [-1, -1] # A,B
var raiz = null

func _ready():
	raiz = get_node("..").get_node("..")
	$Selection.visible = false
	$Fondo.self_modulate = colur[0]
	IDunico()

func IDunico():
	var ok
	var i = 0
	var hojas = get_tree().get_nodes_in_group("Hojas")
	while true:
		ok = true
		for h in hojas:
			if h == self:
				continue
			if h.indice == i:
				i += 1
				ok = false
				break
		if ok:
			indice = i
			$Indice.text = raiz.Formato3(i)
			break

func SetTexto(idNodo, texto):
	while texto.find("  ") != -1:
		texto = texto.replace("  ", " ")
	idNodo.text = texto
	var c = idNodo.get_node("..").get_node("Conteo")
	if texto == "" or texto == " ":
		c.text = c.placeholder_text + "0"
	else:
		c.text = c.placeholder_text + str(texto.count(" ") + 1)

func GetSelected():
	return $Selection.visible

func SetSelected(isSelected):
	if $Selection.visible != isSelected:
		if isSelected:
			var h = raiz.GetHoja()
			if h != null:
				h.SetSelected(false)
				for t in h.GetTickets():
					t.SetSelected(false)
		raiz.SetEditor(isSelected,
			$Indice/Titulo.text,
			$Contenido.text,
			$OptionA/Subtext.text,
			$OptionB/Subtext.text
		)
		$Selection.visible = isSelected
		for t in GetTickets():
			t.SetSelected(isSelected)
		# eliminar la hoja si esta desconectada y sin titulo
		if isSelected:
			modulate.a = 1
		else:
			SetAlpha()
			if conexion[0] == -1 and conexion[1] == -1:
				var ok = true
				for h in get_tree().get_nodes_in_group("Hojas"):
					if h.conexion[0] == indice or h.conexion[1] == indice:
						ok = false
						break
				if ok and $Indice/Titulo.text == "":
					EliminaHoja()

func GetTickets():
	var res = []
	for t in get_tree().get_nodes_in_group("Tickets"):
		if t.indice == indice:
			res.append(t)
	return res

func GetEleccion():
	return conexion[0] != -1 and conexion[1] != -1

func EliminaHoja():
	for t in get_tree().get_nodes_in_group("Tickets"):
		if t.indice == indice or t.conexion == indice:
			t.lineas.queue_free()
			t.queue_free()
	var ok
	for h in get_tree().get_nodes_in_group("Hojas"):
		ok = false
		if h.conexion[0] == indice:
			h.conexion[0] = -1
			h.get_node("OptionA").text = raiz.Formato3(-1)
			ok = true
		if h.conexion[1] == indice:
			h.conexion[1] = -1
			h.get_node("OptionB").text = raiz.Formato3(-1)
			ok = true
		if ok:
			raiz.pordibujar.append(h)
	raiz.get_node("Redibuja").start()
	lineas.queue_free()
	queue_free()

func ActuColor():
	var ok = false
	for h in get_tree().get_nodes_in_group("Hojas"):
		if h.conexion[0] == indice or h.conexion[1] == indice:
			ok = true
			break
	if especial: # rojo: especial
		$Fondo.self_modulate = colur[3]
	elif conexion[0] != -1 and conexion[1] != -1: # amarillo: A+B
		$Fondo.self_modulate = colur[1]
	elif conexion[0] != -1 or conexion[1] != -1: # azul: A
		$Fondo.self_modulate = colur[4]
	elif ok: # verde: final
		$Fondo.self_modulate = colur[2]
	else: # negro: solo
		$Fondo.self_modulate = colur[0]

func SetAlpha():
	if $Selection.visible:
		modulate.a = 1
	else:
		var t8 = 255
		var c8 = 255
		var k8 = 255
		if $Indice/Titulo.text == "":
			t8 = raiz.get_node("Menu/SinTitulos").value
		var p = raiz.palabrasMin
		if GetEleccion():
			if $Contenido.text.length() < p or\
					(conexion[0] != -1 and $OptionA/Subtext.text.length() < p) or\
					(conexion[1] != -1 and $OptionB/Subtext.text.length() < p):
				c8 = raiz.get_node("Menu/SinTextos").value
		else:
			if $Contenido.text.length() < p:
				c8 = raiz.get_node("Menu/SinTextos").value
		if not $Listo.button_pressed:
			k8 = raiz.get_node("Menu/SinOk").value
		modulate.a8 = max(25, min(t8, c8, k8))

func SetHoja(titulo, contenido, isA, opcion):
	$Indice/Titulo.text = titulo
	SetTexto($Contenido, contenido)
	if isA:
		SetTexto($OptionA/Subtext, opcion)
	else:
		SetTexto($OptionB/Subtext, opcion)
	SetAlpha()

func GetHoja():
	return [
		position.x,
		position.y,
		indice,
		conexion[0],
		conexion[1],
		$Indice/Titulo.text,
		$Contenido.text,
		$OptionA/Subtext.text,
		$OptionB/Subtext.text,
		especial,
		$Listo.button_pressed
	]

func GetOpcion(isA):
	if isA:
		return $OptionA/Subtext.text
	else:
		return $OptionB/Subtext.text

func SetOpcion(isA, opcion):
	if isA:
		SetTexto($OptionA/Subtext, opcion)
	else:
		SetTexto($OptionB/Subtext, opcion)

func _process(_delta):
	# mover hoja
	if mouse_R.x != 0 or mouse_R.y != 0:
		var pos = get_global_mouse_position()
		position = viewp_R + (pos - mouse_R)
		lineas.position = position
		if raiz.get_node("Redibuja").is_stopped():
			raiz.pordibujar.append(self)
			for h in get_tree().get_nodes_in_group("Hojas"):
				if indice == h.conexion[0] or indice == h.conexion[1]:
					raiz.pordibujar.append(h)
			for t in get_tree().get_nodes_in_group("Tickets"):
				if indice == t.conexion:
					raiz.pordibujar.append(t)
			raiz.get_node("Redibuja").start()
	# conectar hoja
	if pulsado != "":
		var pos = get_global_mouse_position()
		if pulsado == "A":
			raiz.Linea($OptionA/PosA.global_position, pos)
		else:
			raiz.Linea($OptionB/PosB.global_position, pos)

func _on_bot_select_pressed():
	if Input.is_action_pressed("com_shift"):
		especial = not especial
		ActuColor()
	else:
		SetSelected(true)

func _on_bot_halar_button_down():
	mouse_R = get_global_mouse_position()
	viewp_R = global_position

func _on_bot_halar_button_up():
	mouse_R = Vector2(0, 0)

func _on_bot_conex_a_button_down():
	pulsado = "A"

func _on_bot_conex_a_button_up():
	pulsado = ""
	raiz.Linea(Vector2(0, 0), Vector2(0, 0))
	Conectar(true)

func _on_bot_conex_b_button_down():
	pulsado = "B"

func _on_bot_conex_b_button_up():
	pulsado = ""
	raiz.Linea(Vector2(0, 0), Vector2(0, 0))
	Conectar(false)

func Conectar(isA):
	var pos = get_global_mouse_position() - Vector2(16, 0)
	for h in get_tree().get_nodes_in_group("Hojas"):
		if h.get_node("PosC").global_position.distance_to(pos) < 24:
			if h == self:
				if isA:
					for t in get_tree().get_nodes_in_group("Tickets"):
						if t.indice == indice and t.conexion == conexion[0]:
							t.lineas.queue_free()
							t.queue_free()
							break
					conexion[0] = -1
					$OptionA.text = raiz.Formato3(-1)
				else:
					for t in get_tree().get_nodes_in_group("Tickets"):
						if t.indice == indice and t.conexion == conexion[1]:
							t.lineas.queue_free()
							t.queue_free()
							break
					conexion[1] = -1
					$OptionB.text = raiz.Formato3(-1)
			else:
				if isA and conexion[0] != -1:
					for t in get_tree().get_nodes_in_group("Tickets"):
						if t.indice == indice and t.conexion == conexion[0]:
							t.lineas.queue_free()
							t.queue_free()
							break
				elif not isA and conexion[1] != -1:
					for t in get_tree().get_nodes_in_group("Tickets"):
						if t.indice == indice and t.conexion == conexion[1]:
							t.lineas.queue_free()
							t.queue_free()
							break
				if isA:
					conexion[0] = h.indice
					$OptionA.text = raiz.Formato3(h.indice)
				else:
					conexion[1] = h.indice
					$OptionB.text = raiz.Formato3(h.indice)
				raiz.pordibujar.append(h)
			raiz.pordibujar.append(self)
			raiz.DibujaLineas()
			break

func _on_listo_toggled(_toggled_on):
	SetAlpha()
