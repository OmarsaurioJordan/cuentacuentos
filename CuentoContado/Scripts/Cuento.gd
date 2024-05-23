extends Panel

var data = [] # toda la estructura del cuento, array de arrays, cada uno es una hoja:
# 0:ind, 1:indA, 2:indB, 3:tit, 4:cont, 5:A, 6:B, 7:dibujoOk

var actual = -1 # ultima hoja que visito
var chk = -1 # hoja que dejo guardada

func _ready():
	_on_to_menu_pressed()
	Open("save")
	# leer configuracion
	if FileAccess.file_exists("user://config.txt"):
		var fff = FileAccess.open("user://config.txt", FileAccess.READ)
		var d = fff.get_line().split(",")
		fff.close()
		if d.size() == 2:
			actual = int(d[0])
			chk = int(d[1])

func Save():
	var fff = FileAccess.open("user://config.txt", FileAccess.WRITE)
	fff.store_string(str(actual) + "," + str(chk))
	fff.close()

func Open(filename):
	# verificar que existe el archivo
	if not FileAccess.file_exists("res://" + filename + ".txt"):
		return false
	# abrir el archivo
	var fff = FileAccess.open("res://" + filename + ".txt",\
		FileAccess.READ)
	var ddd = []
	while not fff.eof_reached():
		ddd.append(fff.get_csv_line())
	fff.close()
	# crear las cosas
	data = []
	var p
	for d in ddd:
		if d.size() == 10:
			# 0:x,1:y,2:ind,3:indA,4:indB,5:tit,6:cont,7:A,8:B,9:esp
			p = [int(d[2]), int(d[3]), int(d[4]), d[5], d[6], d[7], d[8]]
			p[4] = p[4].replace("|", "\n")
			p[5] = p[5].replace("|", "\n")
			p[6] = p[6].replace("|", "\n")
			p.append(FileAccess.file_exists("res://Dibujos/d" + d[2] + ".png"))
			# 0:ind, 1:indA, 2:indB, 3:tit, 4:cont, 5:A, 6:B, 7:dibujoOk
			data.append(p)
	return true

func _on_contents_pressed():
	for h in get_children():
		h.visible = false
	$Contents.visible = true

func GoTo(ind):
	if not $Opciones/Pausa.is_stopped():
		return null
	$Opciones/Pausa.start()
	# encontrar la hoja deseada
	var pp = []
	for d in data:
		# 0:ind, 1:indA, 2:indB, 3:tit, 4:cont, 5:A, 6:B, 7:dibujoOk
		if d[0] == ind:
			pp = d
			break
	# si no encuentra la hoja
	if pp.is_empty():
		return null
	# verificar a que tipo de hoja corresponde
	var hh
	if pp[7] and (actual != ind or $Menu.visible or $Contents.visible):
		hh = $Dibujo
	elif pp[1] != -1 and pp[2] != -1:
		hh = $Opciones
	elif pp[1] == -1 and pp[2] == -1:
		hh = $End
	else:
		hh = $Lineal
	# hacer visible la hoja
	for h in get_children():
		h.visible = false
	hh.visible = true
	# poner informacion en la hoja
	hh.get_node("Titulo").text = pp[3]
	if hh == $Dibujo:
		var art = load("res://Dibujos/d" + str(ind) + ".png")
		hh.get_node("Dibujo").texture = art
	else:
		hh.get_node("Texto").text = pp[4]
	# poner opciones
	if hh == $Opciones:
		hh.get_node("OpcA/TextoA").text = pp[5]
		hh.get_node("OpcB/TextoB").text = pp[6]
		hh.get_node("OpcA").disabled = false
		hh.get_node("OpcB").disabled = false
	# poner las cosas finales
	if hh.has_node("Chk"):
		hh.get_node("Chk").disabled = chk == ind
	actual = ind
	Save()

func _on_checkpoint_pressed():
	if chk != -1:
		GoTo(chk)

func _on_new_pressed():
	var ind
	for d in data:
		# 0:ind, 1:indA, 2:indB, 3:tit, 4:cont, 5:A, 6:B, 7:dibujoOk
		ind = d[0]
		for h in data:
			if h[1] == ind or h[2] == ind:
				ind = -1
				break
		if ind != -1:
			GoTo(ind)
			break

func _on_about_pressed():
	for h in get_children():
		h.visible = false
	$About.visible = true

func _on_retomar_pressed():
	if actual == -1:
		_on_new_pressed()
	else:
		GoTo(actual)

func _on_to_menu_pressed():
	for h in get_children():
		h.visible = false
	$Menu.visible = true

func _on_volver_pressed():
	_on_to_menu_pressed()

func _on_chk_pressed():
	chk = actual
	for h in get_children():
		if h.visible:
			h.get_node("Chk").disabled = true
			break
	Save()

func _on_opc_a_pressed():
	for d in data:
		# 0:ind, 1:indA, 2:indB, 3:tit, 4:cont, 5:A, 6:B, 7:dibujoOk
		if d[0] == actual:
			GoTo(d[1])
			break

func _on_opc_b_pressed():
	for d in data:
		# 0:ind, 1:indA, 2:indB, 3:tit, 4:cont, 5:A, 6:B, 7:dibujoOk
		if d[0] == actual:
			GoTo(d[2])
			break

func _on_continue_pressed():
	if $Dibujo.visible:
		GoTo(actual)
	else:
		for d in data:
			# 0:ind, 1:indA, 2:indB, 3:tit, 4:cont, 5:A, 6:B, 7:dibujoOk
			if d[0] == actual:
				GoTo(d[1])
				break

# puntos clave ...............................................

func _on_part_1_pressed():
	#GoTo(poner_ind_deseado)
	pass

func _on_part_2_pressed():
	#GoTo(poner_ind_deseado)
	pass

func _on_part_3_pressed():
	#GoTo(poner_ind_deseado)
	pass

func _on_part_4_pressed():
	#GoTo(poner_ind_deseado)
	pass
