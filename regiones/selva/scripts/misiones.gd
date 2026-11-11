extends RefCounted
## Contenido y decisiones. El mapa y la interfaz no deciden la progresión.
var state: RefCounted
var questions := {
	"sale_product": {"stage": 1, "title": "Registro · producto", "prompt": "Rosa vendió 2 cuadernos a S/ 6 cada uno. Selecciona el producto que debe registrar.", "answers": ["Cuadernos", "El color favorito del cliente", "El clima de hoy"], "correct": 0, "explain": "El comprobante describe lo vendido; permite reconocer la operación.", "next": "rosa"},
	"sale_quantity": {"stage": 1, "title": "Registro · cantidad", "prompt": "Se vendieron 2 cuadernos de S/ 6 cada uno. ¿Qué cantidad registramos?", "answers": ["6 unidades", "2 unidades", "12 unidades"], "correct": 1, "explain": "La cantidad es 2. El precio por unidad es S/ 6.", "next": "rosa"},
	"sale_total": {"stage": 1, "title": "Registro · importe", "prompt": "Producto: cuaderno · Cantidad: 2 · Precio unitario: S/ 6. Completa el importe total.", "answers": ["S/ 6", "S/ 8", "S/ 12"], "correct": 2, "explain": "2 × S/ 6 = S/ 12. El comprobante deja constancia de la venta.", "next": "rosa"},
	"public_answer": {"stage": 2, "title": "Un presupuesto para todos", "prompt": "La plaza necesita luz y la escuela requiere mantenimiento. ¿Qué decisión beneficia a la comunidad?", "answers": ["Destinar recursos públicos al mantenimiento de los servicios", "Reservarlos para un regalo personal", "Suponer que los servicios no cuestan"], "correct": 0, "explain": "Los tributos contribuyen al presupuesto público. Las instituciones administran esos recursos para servicios y obras; pedir boleta ayuda al registro de las operaciones.", "next": "elena"},
	"reported": {"stage": 3, "title": "Comunicar los indicios", "prompt": "La carga no coincide con la guía, hay una ruta para evitar el control y el estibador escuchó una orden sospechosa. ¿Cómo actuamos?", "answers": ["Acusar públicamente a cualquier vendedor", "Entregar los indicios al personal de control para que investigue", "Ocultar la carga a cambio de monedas"], "correct": 1, "explain": "El personal competente verifica lo ocurrido. Evitar controles para ingresar o sacar mercancías puede constituir contrabando y perjudica al Estado y al comercio formal. Un indicio aislado no prueba un delito.", "next": "control"},
	"receipt_product": {"stage": 4, "title": "Revisa tu boleta · producto", "prompt": "BOLETA SIMULADA · Librería Rosa\n2 cuadernos × S/ 6 = S/ 12\nCompraste dos cuadernos. ¿La descripción coincide?", "answers": ["Sí, dice cuadernos", "No, debería decir juguetes", "No es necesario leerla"], "correct": 0, "explain": "La descripción coincide con tu compra.", "next": "rosa"},
	"receipt_quantity": {"stage": 4, "title": "Revisa tu boleta · cantidad", "prompt": "BOLETA SIMULADA\nCuadernos · Cantidad: 2 · Precio unitario: S/ 6\n¿Qué dato confirma cuántos productos recibiste?", "answers": ["El nombre del local", "Cantidad: 2", "El color del papel"], "correct": 1, "explain": "La cantidad registrada coincide con los dos cuadernos recibidos.", "next": "rosa"},
	"receipt_total": {"stage": 4, "title": "Revisa tu boleta · total", "prompt": "Pagaste S/ 12 por dos cuadernos de S/ 6. La boleta indica S/ 12. ¿Qué haces?", "answers": ["La descarto sin revisar", "Pido que eliminen el registro", "Confirmo el importe y conservo mi comprobante"], "correct": 2, "explain": "Verificaste producto, cantidad e importe. Conserva el comprobante como constancia de la compra y para sustentar una consulta o reclamo.", "next": "rosa"}
}
const TRIVIA := [
	["¿Para qué sirve un comprobante?", ["Para dejar constancia de la operación", "Solo para envolver productos", "Para evitar registrar ventas"], 0, "Identifica y deja constancia de una compra o venta."],
	["¿Qué ayudan a financiar los tributos?", ["Solo regalos privados", "Servicios y obras públicas", "Nada en la comunidad"], 1, "Contribuyen al financiamiento de educación, salud e infraestructura, entre otros."],
	["¿Qué hacemos al encontrar residuos?", ["Arrojarlos al río", "Dejarlos junto a la escuela", "Separarlos en los contenedores adecuados"], 2, "Separar residuos ayuda a cuidar el entorno y los espacios que compartimos."],
	["¿Qué favorece un consumo responsable?", ["Comparar, elegir un comercio que registre la venta y pedir comprobante", "Comprar sin preguntar por el origen", "Elegir siempre sin comprobante"], 0, "El precio es un dato; también cuentan el origen y el registro de la compra."],
	["¿Quién debe cuidar una plaza pública?", ["Nadie", "Las autoridades y la ciudadanía, cada cual con su responsabilidad", "Solo quien vive al lado"], 1, "Las instituciones mantienen los servicios y todos ayudamos a cuidarlos."]
]

func _init(progress: RefCounted) -> void:
	state = progress

func message(title: String, body: String, options: Array = []) -> Dictionary:
	return {"title": title, "body": body, "options": options}

func option(label: String, action: String) -> Dictionary:
	return {"label": label, "action": action}

func finish(index: int, body: String) -> Dictionary:
	if not state.complete(index): return message("Objetivos pendientes", state.objective())
	return message("Misión completada · +25 monedas · +1 estrella", body + "\n\n" + state.objective())

func interact(id: String) -> Dictionary:
	var stage: int = state.mission()
	match id:
		"ana", "docente":
			if stage == 0 and not state.has_flag("started"):
				return message("Una compra para el colegio", "La docente necesita dos cuadernos. Compara los dos comercios del mercado y pregunta por el comprobante. Después reservaremos una oferta.", [option("Aceptar el encargo", "start")])
			return message("Docente · nuestro barrio", "Tu grupo puede ayudar a que el barrio compre con responsabilidad.\n\n" + state.objective())
		"beto":
			if stage == 0 and state.has_flag("started"):
				state.mark("offer_informal")
				return message("Beto · puesto de ofertas", "Dos cuadernos por S/ 10. Pero no entrego comprobante.\n\nComparar solo el precio deja fuera información importante. Pregunta también en la librería de Rosa.")
			return message("Beto · puesto de ofertas", "Antes de elegir una compra, compara precios, origen y entrega del comprobante.\n\n" + state.objective())
		"rosa":
			if stage == 0:
				if not state.has_flag("started"): return message("Rosa · librería", "La docente tiene un encargo para ti. Habla primero con ella o con Ana.")
				state.mark("offer_formal")
				if not state.has_flag("offer_informal"):
					return message("Rosa · librería", "Dos cuadernos cuestan S/ 12 e incluyen su boleta. Compara también con el puesto de Beto antes de decidir.")
				return message("Compara y reserva", "Beto: S/ 10 sin comprobante.\nRosa: S/ 12 con boleta.\n¿Qué oferta reservas para la compra escolar? Todavía no gastarás monedas.", [option("Reservar con Rosa y pedir boleta", "choose_formal"), option("Elegir solo el precio menor, sin comprobante", "choose_informal")])
			if stage == 1:
				for key in ["sale_product", "sale_quantity", "sale_total"]:
					if not state.has_flag(key): return question(key)
				return finish(1, "Ayudaste a Rosa a registrar una venta: 2 cuadernos × S/ 6 = S/ 12. Ahora Elena necesita ayuda en la plaza.")
			if stage == 4:
				if not state.has_flag("paid"):
					return message("La decisión correcta", "Tu reserva está lista: 2 cuadernos a S/ 6, total S/ 12. Tienes %d monedas (S/ del juego). ¿Cómo compras?" % int(state.data["coins"]), [option("Pagar S/ 12 y solicitar boleta", "buy"), option("Pedir que no registren la venta", "no_receipt")])
				for key in ["receipt_product", "receipt_quantity", "receipt_total"]:
					if not state.has_flag(key): return question(key)
				return finish(4, "¡Los útiles llegaron al colegio! Elegiste una compra registrada y verificaste el comprobante. Selva completada: el transporte hacia Costa quedó habilitado.")
			return message("Rosa · librería", "Conservamos el registro de tus operaciones.\n\n" + state.objective())
		"elena":
			if stage == 2:
				for key in ["service_light", "service_water", "service_school"]:
					if not state.has_flag(key): return message("Elena · plaza comunitaria", "La luz está averiada, el punto de agua necesita mantenimiento y la escuela requiere reparaciones. Examina los tres indicadores del mapa. Los tributos ayudan a financiar estos servicios.")
				return question("public_answer")
			return message("Elena · plaza comunitaria", "Cuidar los espacios públicos es una responsabilidad compartida.\n\n" + state.objective())
		"service_light", "service_water", "service_school":
			if stage != 2: return message("Servicio público", "Aquí puedes reconocer un servicio que beneficia al barrio.\n\n" + state.objective())
			state.mark(id)
			var details := {"service_light": "El alumbrado necesita reparación. Permite caminar con mayor seguridad por la noche.", "service_water": "El punto de agua requiere mantenimiento para que siga funcionando. La infraestructura y los servicios tienen costos.", "service_school": "La escuela necesita reparar su techo. La educación pública se financia con el presupuesto público, al que contribuyen los tributos."}
			return message("Necesidad comunitaria identificada", details[id] + "\n\n" + state.objective())
		"clue_cargo", "clue_manifest", "clue_route":
			if stage != 3: return message("Carga del embarcadero", "No manipules mercancías ajenas. El personal de control puede orientar sobre su traslado.")
			state.mark(id)
			var clues := {"clue_cargo": "Las etiquetas de estas cajas no coinciden con los productos descritos en la guía. Es un indicio que debe verificarse.", "clue_manifest": "La lista de carga no coincide con la cantidad de bultos presentes. Anotaste la diferencia sin alterar los documentos.", "clue_route": "Una nota propone descargar fuera del punto autorizado para evitar el control. Anotaste el lugar y la hora."}
			return message("Indicio anotado en el diario", clues[id] + "\n\n" + state.objective())
		"estibador":
			if stage == 3:
				state.mark("witness")
				return message("Diego · estibador", "Escuché que querían evitar la revisión. No sé el origen de la carga. Reúne las observaciones y habla con la responsable de control; ella investigará.")
			return message("Diego · estibador", "El registro y los controles ayudan a conocer qué mercancías se transportan.")
		"control":
			if stage != 3: return message("Lucía · control de mercancías", "Revisamos mercancías y documentos. Si observas algo irregular, comunícalo al personal responsable.")
			for key in ["clue_cargo", "clue_manifest", "clue_route", "witness"]:
				if not state.has_flag(key): return message("Lucía · control de mercancías", "Necesitamos información concreta: examina las cajas, la lista y la nota de ruta. Habla también con Diego. No te enfrentes a nadie.\n\n" + state.objective())
			return question("reported")
		"capitana":
			if not state.data["costa_unlocked"]:
				return message("Capitana Inés · transporte", "El viaje se habilitará cuando completes las cinco misiones principales de Selva. Las actividades opcionales no son un requisito.\n\n" + state.objective())
			return message("Selva completada · próximo destino: Costa", "Tu grupo ya puede continuar hacia Costa para aprender a administrar un emprendimiento. El próximo destino todavía no está disponible. Tu progreso está guardado; puedes seguir explorando Selva.", [option("Consultar salida hacia Costa", "travel")])
		"recycle_paper", "recycle_plastic", "recycle_organic":
			if state.has_flag(id): return message("Limpieza del barrio", "Ya recogiste este residuo. Deposítalo en el contenedor de su tipo, junto a la plaza.")
			state.mark(id)
			return message("Residuo recogido", "Llevas un residuo de tipo: %s. Busca su contenedor junto a la plaza. Recoger y separar los tres completa la actividad." % id.get_slice("_", 1).replace("paper", "papel").replace("plastic", "plástico").replace("organic", "orgánico"))
		"bin_paper", "bin_plastic", "bin_organic":
			return message("Separar residuos", "Elige qué residuo depositar en este contenedor: %s." % id.get_slice("_", 1).replace("paper", "papel").replace("plastic", "plástico").replace("organic", "orgánico"), [option("Papel", "sort:%s:paper" % id), option("Plástico", "sort:%s:plastic" % id), option("Orgánico", "sort:%s:organic" % id)])
		"trivia": return trivia()
		"crossing":
			if state.has_flag("crossing_done"): return message("Cruce seguro completado", "Ya recibiste la recompensa. Sigue esperando la señal peatonal y usando el paso marcado.")
			return message("Cruce seguro · actividad opcional", "Colócate al sur del paso peatonal. Espera la señal verde y cruza hacia la acera norte por las franjas. Si cambia a rojo, vuelve a intentarlo sin perder monedas.", [option("Iniciar cruce", "cross_start")])
	return message("Vecindario", "Explora con cuidado y conversa con tus vecinos.")

func question(key: String) -> Dictionary:
	var q: Dictionary = questions[key]
	var options: Array = []
	for i in range(q["answers"].size()): options.append(option(q["answers"][i], "answer:%s:%d" % [key, i]))
	return message(q["title"], q["prompt"], options)

func trivia() -> Dictionary:
	if state.has_flag("trivia_done"): return message("Trivia completada", "Ya respondiste las cinco preguntas y recibiste tu recompensa. Puedes consultar los aprendizajes en el diario.")
	var index: int = int(state.data["flags"].get("trivia_index", 0))
	var q: Array = TRIVIA[index]
	var options: Array = []
	for i in range(3): options.append(option(q[1][i], "trivia:%d:%d" % [index, i]))
	return message("Trivia opcional · %d de 5" % (index + 1), q[0], options)

func respond(action: String) -> Dictionary:
	if action.begins_with("visit:"): return interact(action.trim_prefix("visit:"))
	match action:
		"start":
			if state.mission() != 0: return message("Encargo recibido", state.objective())
			state.mark("started")
			return message("Encargo aceptado", "Busca ambos comercios del mercado. E o ENTER permite conversar; J abre el diario.\n\n" + state.objective())
		"choose_formal":
			if state.mission() != 0 or not state.has_flag("offer_informal") or not state.has_flag("offer_formal"): return message("Compara primero", state.objective())
			state.mark("choice_receipt")
			return finish(0, "Reservaste con comprobante. No gastaste monedas todavía. Rosa te enseñará a registrar una venta antes de recoger los útiles.")
		"choose_informal", "no_receipt":
			return message("Considera también el comprobante", "El precio menor no reemplaza la constancia de compra. Solicitar el comprobante ayuda a registrar la operación y a sustentar consultas o reclamos.", [option("Volver a decidir", "visit:rosa")])
		"buy":
			if state.mission() != 4 or state.has_flag("paid"): return interact("rosa")
			if int(state.data["coins"]) < 12: return message("Saldo insuficiente", "Necesitas S/ 12 del juego. Las actividades opcionales permiten ganar monedas.")
			state.data["coins"] = int(state.data["coins"]) - 12
			state.mark("paid")
			return message("Compra realizada · −12 monedas", "Recibiste dos cuadernos y tu boleta simulada. Ahora revisa sus datos.", [option("Verificar comprobante", "visit:rosa")])
	if action.begins_with("answer:"):
		var parts := action.split(":")
		var key: String = parts[1]
		if not questions.has(key): return {}
		var q: Dictionary = questions[key]
		if state.mission() != int(q["stage"]): return message("Objetivo actualizado", state.objective())
		# No aceptar pasos fuera del orden de la actividad.
		var active := interact(str(q["next"]))
		if active.get("title", "") != q["title"]: return active
		if int(parts[2]) != int(q["correct"]):
			return message("Revisa la situación", "Esa opción no resuelve el objetivo. " + q["explain"], [option("Reintentar", "visit:" + str(q["next"]))])
		state.mark(key)
		if key == "sale_total": return finish(1, q["explain"] + " Ahora visita la plaza.")
		if key == "public_answer": return finish(2, q["explain"] + " Diego necesita ayuda en el embarcadero.")
		if key == "reported": return finish(3, q["explain"] + " Regresa con Rosa para realizar la compra escolar.")
		if key == "receipt_total": return finish(4, q["explain"] + " ¡Los útiles llegaron al colegio! El transporte hacia Costa está habilitado.")
		return message("Dato verificado", q["explain"], [option("Continuar", "visit:" + str(q["next"]))])
	if action.begins_with("sort:"):
		var parts := action.split(":")
		var kind: String = parts[2]
		if parts[1] != "bin_" + kind: return message("Separa por material", "Ese residuo corresponde a otro contenedor. Lee el rótulo y vuelve a intentarlo.")
		if not state.has_flag("recycle_" + kind): return message("Primero recoge el residuo", "Busca el papel, la botella y la cáscara señalados en el mapa.")
		if state.has_flag("sorted_" + kind): return message("Residuo ya depositado", "Este material ya está en su contenedor.")
		state.mark("sorted_" + kind)
		if state.has_flag("sorted_paper") and state.has_flag("sorted_plastic") and state.has_flag("sorted_organic"):
			state.mark("recycle_done")
			state.reward("side_recycle", 15)
			return message("Limpieza completada · +15 monedas", "Separaste los tres residuos. Cuidar el entorno beneficia a todos.")
		return message("Residuo depositado", "Correcto. Continúa con los otros materiales para completar la limpieza.")
	if action.begins_with("trivia:"):
		var parts := action.split(":")
		var index := int(parts[1])
		if state.has_flag("trivia_done") or index != int(state.data["flags"].get("trivia_index", 0)): return trivia()
		var q: Array = TRIVIA[index]
		if int(parts[2]) != int(q[2]): return message("Piensa otra vez", q[3], [option("Reintentar", "visit:trivia")])
		state.data["flags"]["trivia_index"] = index + 1
		if index == 4:
			state.mark("trivia_done")
			state.reward("side_trivia", 15)
			return message("Trivia completada · +15 monedas", q[3])
		return message("Respuesta correcta", q[3], [option("Siguiente pregunta", "visit:trivia")])
	return {}
