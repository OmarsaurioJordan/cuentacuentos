extends Control

const raiz = "res://"

const palabrasMin = 16 # cantidad caracteres minimos para suponer texto lleno

const objHoja = preload(raiz + "Scenes/Hoja.tscn")
const objLinea = preload(raiz + "Scenes/Linea.tscn")
const objTicket = preload(raiz + "Scenes/Ticket.tscn")
const objLinux = preload(raiz + "Scenes/Linux.tscn")

# donde fue pulsado el clic R
var mouse_R = Vector2(0, 0)
var viewp_R = Vector2(0, 0)
var zoomIni = 1.0

# lista de hojas que deben re dibujar sus lineas
var pordibujar = []

# ejecucion: 0:indIni, 1:indFin, 2:itera, 3:actual
var ejecuta = false
var config = [-1, -1, -1, 0]
var libroAll = [] # nodos de todas las hojas al pulsar ejecutar
var historias = [] # strings de historias, ej: "1,2,3,4" c/u
var bucles = [] # strings de historias con bucle, ej: "1,2,3,2" c/u

func _ready():
	randomize()
	zoomIni = $Camara.zoom
	PrepareEsquema()
	$Camara/Editor.visible = false
	$Camara/Editor/OpcionA.disabled = true
	$Camara/Editor/OpcionB.disabled = false
	$Camara/Guardando.visible = false
	$Esquema2.visible = false
	$Menu/VerImg.button_pressed = $Esquema1.visible
	for p in $Plantillas.get_children():
		p.placeholder_text = p.text
	PlantillaOpen()
	NotasOpen()
	Open("save")

func PrepareEsquema():
	$Esquema1.texture = load(raiz + "Data/esquema.png")
	$Esquema1.position = Vector2(0, 0)
	# ajustar esquema 2
	$Esquema2.position = $Esquema1.position
	$Esquema2.scale = $Esquema1.scale
	$Esquema2.texture = $Esquema1.texture
	# ajustar el boton de fondo
	$Mascara.position = Vector2(-1400, -180)
	$Mascara.size = Vector2($Esquema1.texture.get_width(),
		$Esquema1.texture.get_height()) * $Esquema1.scale +\
		Vector2(1400 + 180, 180 * 2)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		Save("save")
		PlantillaSave()
		NotasSave()
		get_tree().quit()

func _process(_delta):
	Simular()
	# mover la camara
	if Input.is_action_just_pressed("com_clic_R"):
		mouse_R = get_viewport().get_mouse_position()
		viewp_R = $Camara.position
	elif Input.is_action_just_released("com_clic_R"):
		mouse_R = Vector2(0, 0)
	elif mouse_R.x != 0 or mouse_R.y != 0:
		var pos = get_viewport().get_mouse_position()
		$Camara.position = viewp_R + (mouse_R - pos) *\
			$Camara/Editor.scale / zoomIni
	# hacer zoom a la camara
	elif ($Camara/Editor.visible and\
			get_viewport().get_mouse_position().x < 3456 * 0.62) or\
			not $Camara/Editor.visible:
		if Input.is_action_just_pressed("com_wheel_U"):
			$Camara.zoom *= 1.1
			$Camara/Editor.scale = Vector2(1 / $Camara.zoom.x,\
				1 / $Camara.zoom.y) * zoomIni
			$Camara/Guardando.scale = $Camara/Editor.scale
		elif Input.is_action_just_pressed("com_wheel_D"):
			$Camara.zoom *= 0.9
			$Camara/Editor.scale = Vector2(1 / $Camara.zoom.x,\
				1 / $Camara.zoom.y) * zoomIni
			$Camara/Guardando.scale = $Camara/Editor.scale

func Formato3(valor):
	if valor == -1:
		return "..."
	elif valor < 10:
		return "00" + str(valor)
	elif valor < 100:
		return "0" + str(valor)
	else:
		return str(valor)

func GetHoja():
	for h in get_tree().get_nodes_in_group("Hojas"):
		if h.GetSelected():
			return h
	return null

func SetEditor(isVisible, titulo, contenido, opcA, opcB):
	$Camara/Editor.visible = isVisible
	if isVisible:
		$Camara/Editor/Titulo.text = titulo
		$Camara/Editor/Contenido.text = contenido
		if $Camara/Editor/OpcionA.disabled:
			$Camara/Editor/Opciones.text = opcA
		else:
			$Camara/Editor/Opciones.text = opcB
	else:
		var h = GetHoja()
		if h != null:
			h.SetHoja(
				$Camara/Editor/Titulo.text,
				$Camara/Editor/Contenido.text,
				$Camara/Editor/OpcionA.disabled,
				$Camara/Editor/Opciones.text
			)

func _on_opcion_a_pressed():
	$Camara/Editor/OpcionA.disabled = true
	$Camara/Editor/OpcionB.disabled = false
	var h = GetHoja()
	if h != null:
		var ant = $Camara/Editor/Opciones.text
		$Camara/Editor/Opciones.text = h.GetOpcion(true)
		h.SetOpcion(false, ant)

func _on_opcion_b_pressed():
	$Camara/Editor/OpcionA.disabled = false
	$Camara/Editor/OpcionB.disabled = true
	var h = GetHoja()
	if h != null:
		var ant = $Camara/Editor/Opciones.text
		$Camara/Editor/Opciones.text = h.GetOpcion(false)
		h.SetOpcion(true, ant)

func _on_mascara_pressed():
	var h = GetHoja()
	if h != null:
		h.SetSelected(false)
		Save("save")

func _input(event):
	if event.is_action_pressed("com_crear"):
		var pos = get_global_mouse_position()
		CreaHoja(pos)
	elif event.is_action_pressed("com_show"):
		$Esquema2.visible = true
	elif event.is_action_released("com_show"):
		$Esquema2.visible = false

func CreaHoja(pos):
	var aux = objHoja.instantiate()
	$Libro.add_child(aux)
	aux.position = pos
	aux.lineas = objLinea.instantiate()
	$Lineas.add_child(aux.lineas)
	aux.lineas.position = aux.position
	aux.lineas.scale = aux.scale
	aux.SetAlpha()
	return aux

func CreaTicket(pos, indice, conexion):
	var aux = objTicket.instantiate()
	$Libro.add_child(aux)
	aux.position = pos
	aux.indice = indice
	aux.get_node("Indice").text = Formato3(indice)
	aux.conexion = conexion
	aux.lineas = objLinux.instantiate()
	$Lineas.add_child(aux.lineas)
	aux.lineas.position = aux.position
	aux.lineas.scale = aux.scale
	for h in get_tree().get_nodes_in_group("Hojas"):
		if h.indice == indice:
			if h.conexion[0] == conexion:
				aux.lineas.get_node("Pos").default_color =\
					h.lineas.get_node("PosA").default_color
			else:
				aux.lineas.get_node("Pos").default_color =\
					h.lineas.get_node("PosB").default_color
			break
	return aux

func HojaInicial():
	var ok
	for a in get_tree().get_nodes_in_group("Hojas"):
		ok = true
		for h in get_tree().get_nodes_in_group("Hojas"):
			if h.conexion[0] == a.indice or h.conexion[1] == a.indice:
				ok = false
				break
		if ok:
			return a
	return null

func _on_bot_exp_hojas_pressed():
	# encontrar hoja inicial
	var ini = HojaInicial()
	if ini == null:
		return false
	else:
		ini = ini.indice
	# eliminar las previas
	var dir = DirAccess.open(raiz + "Hojas")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			dir.remove(file_name)
			file_name = dir.get_next()
	# escribir nuevas hojas
	var txt
	var dat
	var fil
	for h in get_tree().get_nodes_in_group("Hojas"):
		dat = h.GetHoja()
		# 0:x,1:y,2:ind,3:indA,4:indB,5:tit,6:cont,7:A,8:B,9:esp,10:ok
		if h.indice == ini:
			txt = $Plantillas/HojaInicio.text
		elif dat[3] != -1 and dat[4] != -1:
			txt = $Plantillas/HojaDecision.text
		elif dat[3] != -1:
			txt = $Plantillas/HojaLineal.text
		else:
			txt = $Plantillas/HojaFin.text
		txt = txt.replace("#N", str(dat[2]))
		txt = txt.replace("#A", str(dat[3]))
		txt = txt.replace("#B", str(dat[4]))
		txt = txt.replace("#I", str(ini))
		txt = txt.replace("#TT", str(dat[5]))
		txt = txt.replace("#TC", str(dat[6]))
		txt = txt.replace("#TA", str(dat[7]))
		txt = txt.replace("#TB", str(dat[8]))
		# guardar txt
		fil = FileAccess.open(raiz + "Data/Hojas/h" +\
			str(dat[2]) + ".txt", FileAccess.WRITE)
		fil.store_line(txt)
		fil.close()
	Indicador("Exported...")
	return true

func _on_bot_exp_docum_pressed():
	# encontrar hoja inicial
	var ini = HojaInicial()
	if ini == null:
		return false
	var fil = FileAccess.open(raiz + "Data/document.txt", FileAccess.WRITE)
	var txt = $Plantillas/Documento.text
	# poner la primera hoja siempre al inicio
	var dat = ini.GetHoja()
	# 0:x,1:y,2:ind,3:indA,4:indB,5:tit,6:cont,7:A,8:B,9:esp,10:ok
	var tox = str(dat[2]) + "\n" + dat[5] + "\n\n" + dat[6]
	if dat[3] != -1 and dat[4] != -1:
		tox += "\n\n" + "> Opción A:\n\n" + dat[7] + "\n\n(A) ver: " + str(dat[3])
		tox += "\n\n" + "> Opción B:\n\n" + dat[8] + "\n\n(B) ver: " + str(dat[4])
	elif dat[3] != -1:
		tox += "\n\n" + "> Siguiente: " + str(dat[3])
	else:
		tox += "\n\n> Este es un final, gracias por leer!!!"
	# poner el resto de hojas en desorden
	for h in get_tree().get_nodes_in_group("Hojas"):
		if h == ini:
			continue
		dat = h.GetHoja()
		# 0:x,1:y,2:ind,3:indA,4:indB,5:tit,6:cont,7:A,8:B,9:esp,10:ok
		tox += "\n#---\n" + str(dat[2]) + "\n\n" + dat[5] + "\n\n" + dat[6]
		if dat[3] != -1 and dat[4] != -1:
			tox += "\n\n" + "> Opción A:\n\n" + dat[7] + "\n\n(A) ver: " + str(dat[3])
			tox += "\n\n" + "> Opción B:\n\n" + dat[8] + "\n\n(B) ver: " + str(dat[4])
		elif dat[3] != -1:
			tox += "\n\n" + "> Siguiente: " + str(dat[3])
		else:
			tox += "\n\n> Este es un final, gracias por leer!!!"
	# guardar todo
	txt = txt.replacen("#ALL", tox).replacen("#---", "________________________")
	fil.store_line(txt)
	fil.close()
	Indicador("Exported...")
	return true

func _on_bot_exp_datos_pressed():
	Save("data")

func Indicador(texto):
	# indicador
	$Camara/Guardando.visible = true
	$Camara/Guardando/Fin.start()
	$Camara/Guardando/Texto.text = texto

func Save(namefile):
	var fff = FileAccess.open(raiz + "Data/" + namefile + ".txt",\
		FileAccess.WRITE)
	var dat
	var txt
	for h in get_tree().get_nodes_in_group("Hojas"):
		dat = h.GetHoja()
		# 0:x,1:y,2:ind,3:indA,4:indB,5:tit,6:cont,7:A,8:B,9:esp,10:ok
		for i in range(5):
			dat[i] = str(dat[i])
		for i in range(5, 9):
			dat[i] = dat[i].replacen("\n", "|")
		if dat[9]:
			dat[9] = "1"
		else:
			dat[9] = "0"
		if dat[10]:
			dat[10] = "1"
		else:
			dat[10] = "0"
		txt = PackedStringArray(dat)
		fff.store_csv_line(txt)
	for t in get_tree().get_nodes_in_group("Tickets"):
		dat = t.GetTicket()
		# 0:x,1:y,2:ind,3:conex
		for i in range(4):
			dat[i] = str(dat[i])
		txt = PackedStringArray(dat)
		fff.store_csv_line(txt)
	fff.close()
	# indicador
	if namefile == "save":
		Indicador("Saved...")
	else:
		Indicador("Exported...")

func _on_bot_imp_datos_pressed():
	Open("data")

func Open(filename):
	# verificar que existe el archivo
	if not FileAccess.file_exists(raiz + "Data/" + filename + ".txt"):
		return false
	# eliminar todo lo presente
	for c in $Lineas.get_children():
		c.queue_free()
	for c in $Libro.get_children():
		c.queue_free()
	# abrir el archivo
	var fff = FileAccess.open(raiz + "Data/" + filename + ".txt",\
		FileAccess.READ)
	var dat = []
	while not fff.eof_reached():
		dat.append(fff.get_csv_line())
	fff.close()
	# crear las cosas
	var aux
	for d in dat:
		if d.size() == 10 or d.size() == 11: # compatibilidad
			# 0:x,1:y,2:ind,3:indA,4:indB,5:tit,6:cont,7:A,8:B,9:esp,10:ok
			aux = CreaHoja(Vector2(float(d[0]), float(d[1])))
			aux.indice = int(d[2])
			aux.get_node("Indice").text = Formato3(aux.indice)
			aux.conexion[0] = int(d[3])
			aux.get_node("OptionA").text = Formato3(aux.conexion[0])
			aux.conexion[1] = int(d[4])
			aux.get_node("OptionB").text = Formato3(aux.conexion[1])
			aux.SetHoja(d[5].replacen("|", "\n"), d[6].replacen("|", "\n"),
				true, d[7].replacen("|", "\n"))
			aux.SetOpcion(false, d[8].replacen("|", "\n"))
			aux.especial = d[9] != "0"
			if d.size() == 11:
				aux.get_node("Listo").button_pressed = d[10] != "0"
			pordibujar.append(aux)
	for d in dat:
		if d.size() == 4:
			# 0:x,1:y,2:ind,3:conex
			aux = CreaTicket(Vector2(float(d[0]), float(d[1])),
				int(d[2]), int(d[3]))
			pordibujar.append(aux)
	DibujaLineas()
	if filename == "save":
		Indicador("Opened...")
	else:
		Indicador("Imported...")
	return true

func DibujaLineas():
	var opc = ["PosA", "PosB"]
	for h in get_tree().get_nodes_in_group("Hojas"):
		if not pordibujar.has(h):
			continue
		for i in range(2):
			if h.conexion[i] == -1:
				DibujaUna(h.lineas.get_node(opc[i]), Vector2(0, 0), 0,
					h.indice, -1)
			else:
				for n in get_tree().get_nodes_in_group("Hojas"):
					if n.indice == h.conexion[i]:
						if i == 0:
							DibujaUna(h.lineas.get_node(opc[i]),
								n.get_node("PosC").global_position, 0,
								h.indice, n.indice)
						else:
							DibujaUna(h.lineas.get_node(opc[i]),
								n.get_node("PosC").global_position, 12,
								h.indice, n.indice)
						break
		h.ActuColor()
	for t in get_tree().get_nodes_in_group("Tickets"):
		if not pordibujar.has(t):
			continue
		var lin = t.lineas.get_node("Pos")
		var pos = lin.global_position
		for n in get_tree().get_nodes_in_group("Hojas"):
			if n.indice == t.conexion:
				var posFin = n.get_node("PosC").global_position
				lin.points[0] = Vector2(0, 0)
				lin.points[2] = (posFin - pos) - Vector2(24, 0)
				lin.points[1] = Vector2(lin.points[2].x, 0)
				lin.points[3] = posFin - pos
				break
	pordibujar = []

func DibujaUna(lin, posFin, desf, indIni, indFin):
	if posFin.x == 0 and posFin.y == 0:
		for i in range(4):
			lin.points[i] = posFin
	elif (posFin.x - lin.global_position.x) - (24 + desf) < 24:
		for i in range(3):
			lin.points[i] = Vector2(0, 0)
		lin.points[3] = Vector2(12, 0)
		# crear ticket si es que no existe
		var ok = true
		for t in get_tree().get_nodes_in_group("Tickets"):
			if t.indice == indIni and t.conexion == indFin:
				ok = false
				break
		if ok:
			var aux = CreaTicket(posFin - Vector2(72, 28), indIni, indFin)
			pordibujar.append(aux)
			DibujaLineas()
	else:
		var pos = lin.global_position
		lin.points[0] = Vector2(0, 0)
		lin.points[2] = (posFin - pos) - Vector2(24 + desf, 0)
		lin.points[1] = Vector2(lin.points[2].x, 0)
		lin.points[3] = posFin - pos
		# eliminar ticket si es que existe
		for t in get_tree().get_nodes_in_group("Tickets"):
			if t.indice == indIni and t.conexion == indFin:
				t.lineas.queue_free()
				t.queue_free()
				break

func Linea(pos1, pos2):
	$LineaRoja.points[0] = pos1
	$LineaRoja.points[1] = pos2

func _on_redibuja_timeout():
	DibujaLineas()

func FindHoja(ind, hojas=[]):
	if hojas.is_empty():
		hojas = get_tree().get_nodes_in_group("Hojas")
	for h in hojas:
		if h.indice == ind:
			return h
	return null

func Simular():
	if ejecuta:
		# comenzar poniendo la primera hoja
		var history = []
		var act = FindHoja(config[0], libroAll)
		history.append(act.indice)
		# se hace un ciclo buscando todas las posibilidades
		while true:
			if act.conexion[0] == -1 and act.conexion[1] == -1:
				break
			elif act.indice == config[1]:
				break
			elif act.conexion[0] != -1 and act.conexion[1] != -1:
				if randf() < 0.5:
					act = FindHoja(act.conexion[0], libroAll)
				else:
					act = FindHoja(act.conexion[1], libroAll)
				history.append(act.indice)
			elif act.conexion[0] != -1:
				act = FindHoja(act.conexion[0], libroAll)
				history.append(act.indice)
			# verificar si hay lazo
			if history.count(act.indice) > 1:
				var txt = ",".join(history)
				if not bucles.has(txt):
					bucles.append(txt)
				history = []
				break
		# verificar si es una nueva posibilidad
		if not history.is_empty():
			var tyt = ",".join(history)
			if not historias.has(tyt):
				historias.append(tyt)
		# contar intento
		config[3] += 1
		$Menu/Actual.text = str(floor((config[3] / config[2]) * 100.0)) + " %"
		# finalizar
		if config[3] >= config[2]:
			_on_bot_ejecutar_pressed()
			Resultado()

func Resultado():
	var tnt = "Result: Ok\n\n"
	# ver cuantos lazos cerrados hay
	tnt += "bucles: " + str(bucles.size()) + "\n"
	# en caso de haber, muestra el id final del primero
	if not bucles.is_empty():
		tnt += "ind fin: " + bucles[0].split(",")[-1] + "\n"
	# ver cuantas hojas salieron
	var misHojas = []
	for h in historias:
		for i in h.split(","):
			if not misHojas.has(int(i)):
				misHojas.append(int(i))
	tnt += "\nhojas: " + str(misHojas.size()) + "\n"
	# contar el numero de hojas rojas
	var tot = 0
	for h in misHojas:
		for hjs in libroAll:
			if hjs.indice == h:
				if hjs.especial:
					tot += 1
				break
	tnt += "hojas red: " + str(tot) + "\n"
	# ver cuantas historias salieron
	tnt += "historias: " + str(historias.size()) + "\n"
	# ver cual fue la historia maxima
	tot = 0
	for i in historias:
		tot = max(tot, i.count(",") + 1)
	tnt += "histo max: " + str(tot) + "\n"
	# ver cual fue la historia minima
	tot = 10000
	for i in historias:
		tot = min(tot, i.count(",") + 1)
	tnt += "histo min: " + str(tot) + "\n"
	# ver el numero de hojas promedio de las historias
	tot = 0
	for i in historias:
		tot += i.count(",") + 1
	tnt += "histo mean: " + str(round(tot / float(historias.size()))) + "\n"
	# ver el numero de hojas mediana de las historias
	var lind = []
	for h in historias:
		lind.append(h.count(",") + 1)
	if lind.is_empty():
		tnt += "histo medi: 0\n"
	else:
		lind.sort()
		tnt += "histo medi: " + str(lind[lind.size() / 2]) + "\n"
	# revisar si hay algun titulo duplicado, en ese caso mostrarlo
	var ok
	for h in libroAll:
		if h.get_node("Indice/Titulo").text == "":
			continue
		ok = true
		for n in libroAll:
			if n == h:
				continue
			if h.get_node("Indice/Titulo").text ==\
					n.get_node("Indice/Titulo").text:
				tnt += "\ntitulo dupli: " + str(h.indice) + " - " +\
					h.get_node("Indice/Titulo").text
				ok = false
				break
		if not ok:
			break
	# poner todo en la GUI
	$Menu/Resultados.text = tnt
	# guardar archivo con las historias
	var fff = FileAccess.open(raiz + "Data/log.txt",\
		FileAccess.WRITE)
	fff.store_line("\n".join(historias))
	fff.close()
	# guardar archivo con los bucles
	fff = FileAccess.open(raiz + "Data/bug.txt",\
		FileAccess.WRITE)
	fff.store_line("\n".join(bucles))
	fff.close()

func _on_bot_ejecutar_pressed():
	ejecuta = not ejecuta
	if ejecuta:
		randomize()
		$Menu/BotEjecutar.text = "Stop"
		$Menu/Resultados.text = "Result: playing"
		$Menu/Actual.text = "0 %"
		# obtener datos: 0:indIni, 1:indFin, 2:itera, 3:actual
		if $Menu/IteraIni.text == "":
			config[0] = HojaInicial()
			if config[0] == null:
				_on_bot_ejecutar_pressed()
				return null
			else:
				config[0] = config[0].indice
		else:
			config[0] = int($Menu/IteraIni.text)
			if FindHoja(config[0]) == null:
				_on_bot_ejecutar_pressed()
				return null
		if $Menu/IteraFin.text == "":
			config[1] = -1
		else:
			config[1] = int($Menu/IteraFin.text)
		config[3] = 0
		libroAll = get_tree().get_nodes_in_group("Hojas")
		historias = []
		bucles = []
		if $Menu/Iteraciones.text == "":
			config[2] = 1.0
			for h in libroAll:
				if h.GetEleccion():
					config[2] += 1.0
			config[2] *= 10.0
			$Menu/Iteraciones.text = str(config[2])
		else:
			config[2] = float($Menu/Iteraciones.text)
		Save("save")
	else:
		$Menu/BotEjecutar.text = "Simulate"
		$Menu/Resultados.text = "Result: aborted"
	$Menu/Iteraciones.editable = not ejecuta
	$Menu/IteraIni.editable = not ejecuta
	$Menu/IteraFin.editable = not ejecuta

func _on_fin_timeout():
	$Camara/Guardando.visible = false

func _on_ver_img_toggled(toggled_on):
	$Esquema1.visible = toggled_on

func PlantillaSave():
	var fff = FileAccess.open(raiz + "Data/plantillas.txt", FileAccess.WRITE)
	for p in $Plantillas.get_children():
		fff.store_csv_line(PackedStringArray([p.text]))
	fff.close()

func NotasSave():
	var fff = FileAccess.open(raiz + "Data/notas.txt", FileAccess.WRITE)
	fff.store_string($Notas.text)
	fff.close()

func PlantillaOpen():
	if not FileAccess.file_exists(raiz + "Data/plantillas.txt"):
		return false
	var fff = FileAccess.open(raiz + "Data/plantillas.txt", FileAccess.READ)
	var dat = []
	while not fff.eof_reached():
		dat.append(fff.get_csv_line())
		dat[-1] = dat[-1][0]
	for _r in range(10):
		dat.erase("")
	fff.close()
	if dat.size() != $Plantillas.get_child_count():
		return false
	var i = 0
	for p in $Plantillas.get_children():
		p.text = dat[i]
		i += 1
	return true

func NotasOpen():
	if not FileAccess.file_exists(raiz + "Data/notas.txt"):
		return false
	var fff = FileAccess.open(raiz + "Data/notas.txt", FileAccess.READ)
	$Notas.text = fff.get_as_text()
	fff.close()
	return true

func _on_hoja_inicio_focus_exited():
	if $Plantillas/HojaInicio.text == "":
		$Plantillas/HojaInicio.text = $Plantillas/HojaInicio.placeholder_text
	PlantillaSave()

func _on_hoja_decision_focus_exited():
	if $Plantillas/HojaDecision.text == "":
		$Plantillas/HojaDecision.text = $Plantillas/HojaDecision.placeholder_text
	PlantillaSave()

func _on_hoja_lineal_focus_exited():
	if $Plantillas/HojaLineal.text == "":
		$Plantillas/HojaLineal.text = $Plantillas/HojaLineal.placeholder_text
	PlantillaSave()

func _on_hoja_fin_focus_exited():
	if $Plantillas/HojaFin.text == "":
		$Plantillas/HojaFin.text = $Plantillas/HojaFin.placeholder_text
	PlantillaSave()

func _on_documento_focus_exited():
	if $Plantillas/Documento.text == "":
		$Plantillas/Documento.text = $Plantillas/Documento.placeholder_text
	PlantillaSave()

func _on_sin_titulos_drag_ended(value_changed):
	if value_changed:
		for h in get_tree().get_nodes_in_group("Hojas"):
			h.SetAlpha()

func _on_sin_textos_drag_ended(value_changed):
	if value_changed:
		for h in get_tree().get_nodes_in_group("Hojas"):
			h.SetAlpha()
