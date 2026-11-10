extends Node2D
## TRIBUTA PERU - Aventura educativa 2D (Godot 4.x)
## Demostracion original, sin servicios en linea ni datos tributarios reales.

const SW := 960.0
const SH := 540.0
const WW := 1920.0
const WH := 1280.0
const SPEED := 220.0
const SAVE_PATH := "user://tributa_peru_tres_amigos_partida.json"
const INK := Color("#183148")
const NAVY := Color("#102e4b")
const CREAM := Color("#fdf4df")
const GOLD := Color("#ffd16a")
const GREEN := Color("#53be8f")

var tex: Dictionary = {}
var font: Font
var player: Vector2 = Vector2(480, 655)
var camera: Vector2 = Vector2.ZERO
var facing: Vector2 = Vector2(0, 1)
var elapsed: float = 0.0
var level: int = 1
var coins: int = 100
var stars: int = 0
var contribution: int = 0
var reputation: int = 100
var obtained: Dictionary = {}
var chests: Dictionary = {}
var cashier_index: int = 0
var igv_index: int = 0
var final_index: int = 0
var sequence_index: int = 0
var sequence_tip: String = ""
var mode: String = "title"
var dialog_title: String = ""
var dialog_body: String = ""
var dialog_next: String = ""
var quiz_title: String = ""
var quiz_question: String = ""
var quiz_options: Array = []
var quiz_answer: int = 0
var quiz_explanation: String = ""
var quiz_action: String = ""
var quiz_error: String = ""
var notification: String = ""
var notification_timer: float = 0.0
var has_saved: bool = false
var sounds: Dictionary = {}

# Heroes creados a partir de las ilustraciones originales aportadas por el usuario.
const HEROES := ["maria", "juan", "luis"]
var hero: String = "juan"
var hero_moving: bool = false
var side_tasks: Dictionary = {}
var delivery_active: bool = false
var delivery_seconds: float = 0.0
var memory_cards: Array = []
var memory_shown: Array = []
var memory_solved: Array = []
var memory_miss_timer: float = 0.0
var journal_from_pause: bool = false
var last_achievement: String = ""
var cashier_feedback: String = ""
var music: AudioStreamPlayer


const LEVEL_NAMES := [
    "Sierra: ¿Para qué sirven los tributos?",
    "Costa: El camino hacia el RUC",
    "Costa: Pide tu comprobante",
    "Costa: Asesoría y reto del IGV",
    "Selva: Festival del emprendedor"
]

var buildings: Array = [
    {"pos": Vector2(230, 200), "tex": "sunat", "title": "ORIENTACION SUNAT (HUANUCO)", "stage": 1},
    {"pos": Vector2(1145, 200), "tex": "registro", "title": "REGISTRO RUC Y ADUANAS", "stage": 2},
    {"pos": Vector2(235, 836), "tex": "tienda", "title": "BODEGA DE ROSA Y JUAN", "stage": 3},
    {"pos": Vector2(1135, 836), "tex": "contaduria", "title": "ASESORIA CONTABLE", "stage": 4},
    {"pos": Vector2(1530, 475), "tex": "municipio", "title": "FESTIVAL AMAZONICO", "stage": 5}
]
var npcs: Array = [
    {"id": "mara", "name": "María", "role": "Compañera guía", "pos": Vector2(360, 491), "stage": 1},
    {"id": "luis", "name": "Luis", "role": "Amigo explorador", "pos": Vector2(1250, 490), "stage": 2},
    {"id": "rosa", "name": "Rosa", "role": "Comerciante", "pos": Vector2(362, 1114), "stage": 3},
    {"id": "elena", "name": "Elena", "role": "Contadora", "pos": Vector2(1260, 1114), "stage": 4},
    {"id": "alcalde", "name": "Mateo", "role": "Organizador", "pos": Vector2(1667, 772), "stage": 5},
    {"id": "juan", "name": "Juan", "role": "Club de retos", "pos": Vector2(1065, 493), "stage": 0}
]
var objects: Array = [
    {"id": "h_escuela", "level": 1, "pos": Vector2(280, 420), "name": "Colegio Leoncio Prado (Escuela)", "kind": "paper", "info": "Educación pública gratuita: carpetas, textos y maestros financiados con el presupuesto tributario nacional."},
    {"id": "h_posta", "level": 1, "pos": Vector2(620, 410), "name": "Posta Médica de Huánuco", "kind": "paper", "info": "Salud pública: vacunas, medicinas y doctores pagados con los tributos que aportamos entre todos."},
    {"id": "h_alumbrado", "level": 1, "pos": Vector2(510, 520), "name": "Alumbrado Público de la Plaza", "kind": "paper", "info": "Servicios comunales: iluminación nocturna en las calles de Huánuco para seguridad de las familias."},
    {"id": "h_pista", "level": 1, "pos": Vector2(360, 650), "name": "Pista y Pavimento (Jr. 2 de Mayo)", "kind": "paper", "info": "Infraestructura vial: pistas asfaltadas sin huecos gracias al financiamiento de obras públicas."},
    {"id": "h_serenazgo", "level": 1, "pos": Vector2(640, 650), "name": "Serenazgo y Seguridad Ciudadana", "kind": "paper", "info": "Seguridad ciudadana: patrulleros y personal municipal que cuidan el orden en la comunidad."},
    {"id": "d1", "level": 2, "pos": Vector2(1185, 576), "name": "Actividad económica", "kind": "paper"},
    {"id": "d2", "level": 2, "pos": Vector2(1326, 643), "name": "Documento de identidad", "kind": "paper"},
    {"id": "d3", "level": 2, "pos": Vector2(1198, 770), "name": "Domicilio fiscal", "kind": "paper"},
    {"id": "f1", "level": 5, "pos": Vector2(920, 635), "name": "Carpeta de emprendimiento", "kind": "chest"}
]
var decor_trees: Array = [
    Vector2(80, 80), Vector2(570, 140), Vector2(775, 175), Vector2(965, 170),
    Vector2(1470, 120), Vector2(1790, 95), Vector2(70, 430), Vector2(680, 390),
    Vector2(1460, 380), Vector2(1840, 425), Vector2(85, 815), Vector2(590, 844),
    Vector2(758, 975), Vector2(970, 1045), Vector2(1495, 1055), Vector2(1770, 925),
    Vector2(1850, 1140), Vector2(90, 1090), Vector2(530, 1150), Vector2(1100, 1150)
]
var bonus_chests: Array = [
    {"id":"c1", "pos":Vector2(550, 742)},
    {"id":"c2", "pos":Vector2(1515, 738)},
    {"id":"c3", "pos":Vector2(925, 290)}
]

func _ready() -> void:
    font = ThemeDB.fallback_font
    for name in ["grass", "road", "paving", "flower", "tree", "alex", "mara", "luis", "rosa", "elena", "alcalde", "sunat", "registro", "tienda", "contaduria", "municipio", "paper", "coin", "chest", "logo"]:
        tex[name] = load("res://assets/%s.png" % name)
    for hero_name in HEROES:
        tex["hero_" + hero_name] = load("res://assets/heroes/%s.png" % hero_name)
    for s in ["pickup", "success", "wrong"]:
        var audio := AudioStreamPlayer.new()
        audio.stream = load("res://assets/%s.wav" % s)
        add_child(audio)
        sounds[s] = audio
    music = AudioStreamPlayer.new()
    music.stream = load("res://assets/aventura_musica.wav")
    music.volume_db = -24.0
    add_child(music)
    music.finished.connect(music.play)
    music.play()
    has_saved = FileAccess.file_exists(SAVE_PATH)
    if has_saved:
        load_game()
    queue_redraw()

func _process(delta: float) -> void:
    elapsed += delta
    if notification_timer > 0.0:
        notification_timer -= delta
    if mode == "memory" and memory_miss_timer > 0.0:
        memory_miss_timer -= delta
        if memory_miss_timer <= 0.0:
            memory_shown.clear()
    if delivery_active and mode == "":
        delivery_seconds -= delta
        if delivery_seconds <= 0.0:
            delivery_active = false
            delivery_seconds = 0.0
            toast("Se agoto el tiempo. Pregunta a Juan para reintentar.")
            play_sound("wrong")
    hero_moving = false
    if mode == "":
        var motion := Vector2.ZERO
        if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
            motion.x -= 1.0
        if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
            motion.x += 1.0
        if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W):
            motion.y -= 1.0
        if Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S):
            motion.y += 1.0
        motion = motion.normalized()
        if motion.length() > 0.0:
            hero_moving = true
            facing = motion
            try_move(Vector2(motion.x * SPEED * delta, 0))
            try_move(Vector2(0, motion.y * SPEED * delta))
        check_coin_pickup()
    camera = Vector2(clampf(player.x - SW / 2.0, 0.0, WW - SW), clampf(player.y - SH / 2.0, 0.0, WH - SH))
    queue_redraw()

func try_move(step: Vector2) -> void:
    var new_pos: Vector2 = player + step
    new_pos.x = clampf(new_pos.x, 20.0, WW - 20.0)
    new_pos.y = clampf(new_pos.y, 25.0, WH - 22.0)
    var pbox := Rect2(new_pos - Vector2(11, 5), Vector2(22, 22))
    for b in buildings:
        var blocked: Rect2 = Rect2(b["pos"] + Vector2(10, 27), Vector2(234, 181))
        if pbox.intersects(blocked):
            return
    for t in decor_trees:
        if pbox.intersects(Rect2(t + Vector2(23, 49), Vector2(19, 17))):
            return
    player = new_pos

func check_coin_pickup() -> void:
    # Seis monedas escondidas en la plaza; su recogida se guarda automaticamente.
    for i in range(6):
        var id := "coin_%d" % i
        var pos := Vector2(545.0 + i * 115.0, 689.0 if i % 2 == 0 else 604.0)
        if not obtained.has(id) and player.distance_to(pos) < 23.0:
            obtained[id] = true
            coins += 5
            play_sound("pickup")
            toast("+5 monedas por explorar")
            save_game()

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.pressed and event.button_index == MOUSE_BUTTON_LEFT and mode == "quiz":
            var mp: Vector2 = event.position
            for i in range(quiz_options.size()):
                if Rect2(176, 243 + i * 59, 608, 49).has_point(mp):
                    choose_answer(i)
                    get_viewport().set_input_as_handled()
                    return
        if event.pressed and event.button_index == MOUSE_BUTTON_LEFT and mode == "memory":
            var click: Vector2 = event.position
            for i in range(6):
                var mx := 229 + (i % 3) * 172
                var my := 207 + (i / 3) * 105
                if Rect2(mx, my, 154, 89).has_point(click):
                    flip_memory(i)
                    return
        if event.pressed and event.button_index == MOUSE_BUTTON_LEFT and mode == "cashier":
            if Rect2(185, 298, 258, 93).has_point(event.position):
                choose_cashier(0)
            elif Rect2(515, 298, 258, 93).has_point(event.position):
                choose_cashier(1)
            return
        if event.pressed and event.button_index == MOUSE_BUTTON_LEFT and mode == "message":
            advance_message()
            return
        if event.pressed and event.button_index == MOUSE_BUTTON_LEFT and mode == "select":
            for i in range(3):
                if Rect2(168 + i * 219, 211, 194, 215).has_point(event.position):
                    select_hero(i)
                    return
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    var code: int = event.keycode
    if mode == "title":
        if code == KEY_ENTER or code == KEY_KP_ENTER or code == KEY_SPACE:
            if not has_saved:
                mode = "select"
            elif level >= 6:
                mode = "ending"
            else:
                mode = ""
        elif code == KEY_N:
            reset_game()
            mode = "select"
    elif mode == "select":
        if code in [KEY_1, KEY_KP_1]:
            select_hero(0)
        elif code in [KEY_2, KEY_KP_2]:
            select_hero(1)
        elif code in [KEY_3, KEY_KP_3]:
            select_hero(2)
        elif code == KEY_ESCAPE:
            mode = "title"
    elif mode == "":
        if code == KEY_E or code == KEY_ENTER:
            interact()
        elif code == KEY_ESCAPE:
            mode = "pause"
        elif code == KEY_K:
            save_game()
            toast("Partida guardada")
        elif code == KEY_J:
            journal_from_pause = false
            mode = "journal"
        elif code == KEY_H:
            toast("Pista: " + objective().substr(0, 63))
        elif code == KEY_M:
            toggle_music()
    elif mode == "pause":
        if code in [KEY_ESCAPE, KEY_ENTER, KEY_SPACE]:
            mode = ""
        elif code == KEY_K:
            save_game()
            toast("Partida guardada")
        elif code == KEY_N:
            mode = "title"
        elif code == KEY_J:
            journal_from_pause = true
            mode = "journal"
    elif mode == "journal":
        if code in [KEY_ESCAPE, KEY_ENTER, KEY_J]:
            mode = "pause" if journal_from_pause else ""
    elif mode == "club":
        if code in [KEY_1, KEY_KP_1]:
            begin_memory()
        elif code in [KEY_2, KEY_KP_2]:
            begin_delivery()
        elif code in [KEY_3, KEY_KP_3, KEY_ESCAPE]:
            mode = ""
    elif mode == "cashier":
        if code in [KEY_1, KEY_KP_1]:
            choose_cashier(0)
        elif code in [KEY_2, KEY_KP_2]:
            choose_cashier(1)
        elif code == KEY_ESCAPE:
            mode = ""
    elif mode == "memory":
        var codes := [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6]
        if code in codes:
            flip_memory(codes.find(code))
        elif code == KEY_ESCAPE:
            mode = ""
    elif mode == "message":
        if code in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_E, KEY_ESCAPE]:
            advance_message()
    elif mode == "quiz":
        if code in [KEY_1, KEY_KP_1]:
            choose_answer(0)
        elif code in [KEY_2, KEY_KP_2]:
            choose_answer(1)
        elif code in [KEY_3, KEY_KP_3]:
            choose_answer(2)
    elif mode == "sequence":
        if code in [KEY_1, KEY_KP_1]:
            choose_sequence(0)
        elif code in [KEY_2, KEY_KP_2]:
            choose_sequence(1)
        elif code in [KEY_3, KEY_KP_3]:
            choose_sequence(2)
        elif code == KEY_ESCAPE:
            mode = ""
    elif mode == "ending":
        if code == KEY_N:
            reset_game()
            mode = ""
            open_message("NUEVO COMIENZO", "¡Una nueva oportunidad para emprender! Dirigete a la oficina SUNAT y habla con Mara.", "")
        elif code in [KEY_ESCAPE, KEY_ENTER]:
            mode = "title"
    queue_redraw()

func interact() -> void:
    for ob in objects:
        if int(ob["level"]) == level and not obtained.has(ob["id"]) and player.distance_to(ob["pos"]) < 61.0:
            obtained[ob["id"]] = true
            coins += 10
            contribution += 10
            reputation += 2
            play_sound("pickup")
            save_game()
            var desc: String = ob.get("info", "")
            if desc != "":
                var msg := "%s\n\n%s\n\n¡Sumaste +S/ 10 al Fondo de Huánuco! (%d/5 servicios descubiertos)" % [ob["name"], desc, count_huanuco_services()]
                open_message("SERVICIO PÚBLICO DE HUÁNUCO", msg, "")
            else:
                open_message("¡OBJETO ENCONTRADO!", "%s. Ganaste +10 Monedas y aportaste S/ 10 al Fondo Comunal. %s" % [ob["name"], objective()], "")
            return
    for chest in bonus_chests:
        if not chests.has(chest["id"]) and player.distance_to(chest["pos"]) < 61.0:
            chests[chest["id"]] = true
            coins += 25
            contribution += 25
            reputation += 5
            play_sound("pickup")
            save_game()
            open_message("COFRE DE CULTURA TRIBUTARIA", "Encontraste 25 monedas y sumaste S/ 25 al Fondo de Huánuco. Dato: la educación tributaria permite financiar hospitales, escuelas y pistas.", "")
            return
    var nearest: Dictionary = {}
    var dist := 82.0
    for npc in npcs:
        var d: float = player.distance_to(npc["pos"])
        if d < dist:
            nearest = npc
            dist = d
    if not nearest.is_empty():
        talk_to(str(nearest["id"]))
        return
    toast("Acercate a una persona u objeto y pulsa E")

func count_huanuco_services() -> int:
    var count := 0
    for id in ["h_escuela", "h_posta", "h_alumbrado", "h_pista", "h_serenazgo"]:
        if obtained.has(id):
            count += 1
    return count

func count_objects(prefix: String) -> int:
    var count := 0
    for i in range(1, 4):
        if obtained.has("%s%d" % [prefix, i]):
            count += 1
    return count

func talk_to(id: String) -> void:
    match id:
        "mara":
            var guide_name := "MARA - ORIENTADORA" if hero == "maria" else "MARÍA - GUÍA"
            if delivery_active:
                delivery_active = false
                side_tasks["delivery"] = true
                coins += 40
                stars += 1
                play_sound("success")
                save_game()
                open_message("¡ENTREGA EXPRESS COMPLETADA!", "El equipo de orientación recibió el folleto educativo. ¡Ganaste 40 monedas y una estrella por compartir información tributaria!", "")
                return
            if level == 1:
                var c := count_huanuco_services()
                if c < 5:
                    open_message(guide_name, "¡Hola! Para entender para qué sirven los tributos, recorre la plaza de Huánuco y descubre los 5 servicios públicos esenciales (llevas %d/5)." % c, "")
                else:
                    open_quiz("NIVEL 1 · ¿PARA QUÉ SIRVEN LOS TRIBUTOS?",
                        "LUIS: 'O sea que la escuela donde estudio y la posta médica existen gracias a lo que pagamos entre todos...'\n\nMARÍA: ¡Exacto! ¿Para qué sirven los tributos que aportamos los peruanos?",
                        [
                            "1. Para financiar colegios, postas médicas, pistas y seguridad pública.",
                            "2. Para que las autoridades lo guarden en una caja sin usarlo.",
                            "3. Para regalar premios únicamente a negocios grandes."
                        ],
                        0,
                        "¡Exacto! Los tributos financian los bienes y servicios públicos de Huánuco y todo el Perú. Cuando no se pide boleta, ese dinero no llega a la comunidad.",
                        "finish_1")
            else:
                open_message(guide_name, "¡Buen trabajo en Huánuco! Ahora dirígete a la zona de comercio para aprender sobre los comprobantes de pago.", "")
        "luis":
            var ruc_guide := "GUÍA DE RUC" if hero == "luis" else "LUIS - COMPAÑERO"
            if level == 2:
                if count_objects("d") < 3:
                    open_message(ruc_guide, "¡Yo te acompaño! Para formalizar un negocio hay datos importantes. Busca las tres fichas cercanas a esta oficina y luego ordenemos los pasos juntos.", "")
                else:
                    sequence_index = 0
                    sequence_tip = "Presiona los numeros en el orden adecuado."
                    mode = "sequence"
            else:
                open_message(ruc_guide, "El RUC identifica a los contribuyentes ante la SUNAT y tiene 11 dígitos. Los requisitos dependen de la actividad y la situación de cada persona.", "")
        "rosa":
            if level == 3:
                start_cash_game()
            else:
                open_message("ROSA - COMERCIANTE", "¡Bienvenido a mi bodega! Recuerda pedir el comprobante de pago cuando realizas una compra.", "")
        "elena":
            if level == 4:
                start_igv_game()
            else:
                open_message("ELENA - CONTADORA", "En muchos casos se aplica el IGV a la venta de bienes y servicios. Aprenderas a distinguir el valor de venta, el impuesto y el precio final.", "")
        "juan":
            mode = "club"
        "alcalde":
            if level == 5:
                if not obtained.has("f1"):
                    open_message("MATEO - ORGANIZADOR", "¡Ya casi eres emprendedor responsable! Busca la carpeta dorada de emprendimiento en la avenida central. Regresa conmigo para tu desafio final.", "")
                else:
                    start_final_game()
            else:
                open_message("MATEO - ORGANIZADOR", "¡La feria de Villa Emprende se acerca! Solo podras superar mi reto cuando completes las cuatro primeras misiones.", "")

func open_message(title: String, content: String, next_event: String) -> void:
    mode = "message"
    dialog_title = title
    dialog_body = content
    dialog_next = next_event

func advance_message() -> void:
    var next_event: String = dialog_next
    dialog_next = ""
    mode = ""
    if next_event == "cash":
        start_cash_game()
    elif next_event == "igv":
        start_igv_game()
    elif next_event == "final":
        start_final_game()
    elif next_event == "end":
        mode = "ending"
    elif next_event == "scene1_maria":
        open_quiz("MARÍA · ¿ACEPTAS LA MISIÓN TRIBUTO?",
            "¡Hola! Soy María. Como ves, Villa Esperanza tiene pistas con huecos y la escuela necesita mejoras. ¡Pero tú puedes ayudar a cambiarlos con tus decisiones!\n\n¿Aceptas la Misión Tributo?",
            ["¡Acepto la Misión! Vamos a transformar la ciudad", "Ahora no..."],
            0,
            "¡Gran actitud! Cada comprobante que exigimos y cada tributo pagado ayuda a financiar bienes y servicios públicos para todos.",
            "accept_mission")

func open_quiz(title: String, question: String, options: Array, correct: int, explanation: String, action: String) -> void:
    mode = "quiz"
    quiz_title = title
    quiz_question = question
    quiz_options = options
    quiz_answer = correct
    quiz_explanation = explanation
    quiz_action = action
    quiz_error = ""

func choose_answer(index: int) -> void:
    if mode != "quiz":
        return
    if index != quiz_answer:
        play_sound("wrong")
        if quiz_action == "accept_mission":
            quiz_error = "¡Vamos! La escuela y las pistas no se van a reparar solas. ¡Te necesitamos como aliado tributario!"
        else:
            quiz_error = "Aun no. Piensa en la situacion y vuelve a intentarlo."
        return
    play_sound("success")
    coins += 15
    stars += 1
    contribution += 15
    reputation += 5
    var action: String = quiz_action
    var information: String = quiz_explanation
    if action == "accept_mission":
        save_game()
        open_message("¡MISIÓN TRIBUTO ACEPTADA!", "¡Sumaste tus primeros S/ 15 al Fondo de la Ciudad y +5 de Reputación!\n\nRecorre la plaza de Villa Esperanza (Huánuco) y descubre cómo los tributos financian la escuela, la posta y las pistas.", "")
    elif action.begins_with("finish_"):
        complete_level()
        if level == 6:
            open_message("¡FESTIVAL COMPLETADO!", information + " ¡Has terminado la aventura y recibido tu reconocimiento!", "end")
        else:
            open_message("¡NIVEL SUPERADO!", information + " Ganaste 15 monedas y una estrella. El siguiente nivel ya esta disponible.", "")
    elif action == "cash_next":
        cashier_index += 1
        save_game()
        if cashier_index >= 3:
            complete_level()
            open_message("¡TIENDA COMPLETADA!", information + " Terminaste todas las ventas. ¡Desbloqueaste el nivel de impuestos!", "")
        else:
            open_message("VENTA CORRECTA", information + " +15 monedas y una estrella. Preparando al siguiente cliente...", "cash")
    elif action == "igv_next":
        igv_index += 1
        save_game()
        if igv_index >= 2:
            complete_level()
            open_message("¡DESAFIO SUPERADO!", information + " Ya puedes visitar el festival del emprendedor.", "")
        else:
            open_message("CALCULO CORRECTO", information + " Vamos con otro ejemplo.", "igv")
    elif action == "final_next":
        final_index += 1
        save_game()
        if final_index >= 2:
            complete_level()
            open_message("¡DESAFIO FINAL LOGRADO!", information + " Has completado Tributa Peru.", "end")
        else:
            open_message("¡RESPUESTA ACERTADA!", information + " Llega el ultimo desafio.", "final")
    else:
        open_message("¡CORRECTO!", information, "")
    save_game()

func choose_sequence(index: int) -> void:
    if mode != "sequence":
        return
    # Orden didactico: definir la actividad > inscribirse en RUC > obtener Clave SOL.
    var correct_order := [1, 2, 0]
    if index != correct_order[sequence_index]:
        sequence_tip = "Ese no es el siguiente paso. ¡Intenta otro!"
        play_sound("wrong")
        return
    sequence_index += 1
    play_sound("pickup")
    if sequence_index >= 3:
        stars += 1
        coins += 30
        complete_level()
        open_message("¡RUC COMPRENDIDO!", "Organizaste una secuencia introductoria: identificar la actividad, inscribirte en el RUC y gestionar tu Clave SOL. Los procedimientos concretos dependen del caso. ¡Nivel 3 desbloqueado!", "")
    else:
        sequence_tip = "¡Correcto! Vas %d de 3 pasos. Sigue el orden." % sequence_index
    save_game()

func start_cash_game() -> void:
    if level != 3:
        return
    mode = "cashier"
    cashier_feedback = ""

func choose_cashier(choice: int) -> void:
    if mode != "cashier" or level != 3:
        return
    var expected := [0, 1, 0]
    if choice != expected[cashier_index]:
        cashier_feedback = "No corresponde a este cliente. Lee su pedido e intenta otra vez."
        play_sound("wrong")
        return
    play_sound("success")
    coins += 15
    stars += 1
    cashier_index += 1
    save_game()
    if cashier_index >= 3:
        complete_level()
        open_message("¡TIENDA ATENDIDA!", "Atendiste a los tres clientes y entregaste el comprobante correspondiente. Los consumidores finales suelen recibir boleta; las operaciones empresariales pueden requerir factura según el caso. ¡Desbloqueaste el nivel 4!", "")
    else:
        open_message("¡VENTA COMPLETADA!", "Elegiste el comprobante adecuado y ganaste 15 monedas y una estrella. Un nuevo cliente está esperando en la caja.", "cash")

func start_igv_game() -> void:
    if level != 4:
        return
    if igv_index == 0:
        open_quiz("CALCULA EL IGV - RETO 1", "En un ejemplo de operacion gravada, el valor sin IGV es S/ 100. Si el IGV es 18%, ¿cuanto es el precio total?", ["S/ 100", "S/ 118", "S/ 180"], 1, "18% de S/ 100 es S/ 18. Precio total: S/ 118.", "igv_next")
    else:
        open_quiz("CALCULA EL IGV - RETO 2", "En una operacion gravada, el valor sin IGV es S/ 50. Con IGV de 18%, ¿cuanto se paga en total?", ["S/ 59", "S/ 68", "S/ 50"], 0, "18% de S/ 50 es S/ 9. Precio total: S/ 59.", "igv_next")

func start_final_game() -> void:
    if level != 5:
        return
    if final_index == 0:
        open_quiz("FESTIVAL - PRUEBA 1 DE 2", "Una persona quiere registrarse como contribuyente. ¿Cuantos digitos tiene el RUC en el Peru?", ["8 digitos", "11 digitos", "16 digitos"], 1, "El RUC es un numero de once digitos que identifica al contribuyente.", "final_next")
    else:
        open_quiz("FESTIVAL - PRUEBA 2 DE 2", "Si compras en una tienda, ¿que accion favorece la cultura tributaria?", ["Pedir tu comprobante de pago", "Evitar pedir boleta", "Eliminar el registro de la venta"], 0, "Solicitar comprobantes contribuye a la transparencia y al cumplimiento tributario.", "final_next")

func complete_level() -> void:
    level = mini(level + 1, 6)
    cashier_index = 0 if level != 3 else cashier_index
    igv_index = 0 if level != 4 else igv_index
    final_index = 0 if level != 5 else final_index
    play_sound("success")
    save_game()

func objective() -> String:
    match level:
        1:
            var c := count_huanuco_services()
            if c < 5:
                return "Descubre los 5 servicios en la plaza de Huánuco (%d/5)." % c
            return "¡Los 5 servicios listos! Habla con María en Orientación SUNAT."
        2:
            if count_objects("d") < 3:
                return "Busca tres fichas cerca del registro (%d/3)." % count_objects("d")
            return "Habla con Luis y ordena los pasos del RUC."
        3:
            return "Atiende en la bodega de Rosa: %d/3 clientes." % cashier_index
        4:
            return "Visita a Elena y resuelve %d/2 ejercicios de IGV." % igv_index
        5:
            if not obtained.has("f1"):
                return "Recoge la carpeta en la avenida central."
            return "Habla con Mateo en el festival: %d/2 retos." % final_index
        _:
            return "¡Completaste las cinco etapas educativas!"

func active_npc_pos() -> Vector2:
    if level > 5:
        return player
    for npc in npcs:
        if int(npc["stage"]) == level:
            return npc["pos"]
    return player

func play_sound(sound_name: String) -> void:
    if sounds.has(sound_name):
        sounds[sound_name].play()

func toast(text: String) -> void:
    notification = text
    notification_timer = 2.4

func save_game() -> void:
    var data := {
        "level": level,
        "coins": coins,
        "stars": stars,
        "contribution": contribution,
        "reputation": reputation,
        "x": player.x,
        "y": player.y,
        "obtained": obtained,
        "chests": chests,
        "cashier_index": cashier_index,
        "igv_index": igv_index,
        "final_index": final_index,
        "hero": hero,
        "side_tasks": side_tasks,
        "delivery_active": delivery_active,
        "delivery_seconds": delivery_seconds
    }
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file != null:
        file.store_string(JSON.stringify(data))
        file.close()
        has_saved = true

func load_game() -> void:
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return
    var data = JSON.parse_string(file.get_as_text())
    file.close()
    if not data is Dictionary:
        return
    level = clampi(int(data.get("level", 1)), 1, 6)
    coins = int(data.get("coins", 100))
    stars = int(data.get("stars", 0))
    contribution = int(data.get("contribution", 0))
    reputation = int(data.get("reputation", 100))
    player = Vector2(float(data.get("x", 480)), float(data.get("y", 655)))
    obtained = data.get("obtained", {})
    chests = data.get("chests", {})
    cashier_index = int(data.get("cashier_index", 0))
    igv_index = int(data.get("igv_index", 0))
    final_index = int(data.get("final_index", 0))
    hero = str(data.get("hero", "juan"))
    if not HEROES.has(hero):
        hero = "juan"
    side_tasks = data.get("side_tasks", {})
    delivery_active = bool(data.get("delivery_active", false))
    delivery_seconds = float(data.get("delivery_seconds", 0.0))

func reset_game() -> void:
    level = 1
    coins = 100
    stars = 0
    contribution = 0
    reputation = 100
    player = Vector2(480, 655)
    obtained.clear()
    chests.clear()
    cashier_index = 0
    igv_index = 0
    final_index = 0
    sequence_index = 0
    hero = "juan"
    side_tasks.clear()
    delivery_active = false
    delivery_seconds = 0.0
    has_saved = false
    # Se guarda solo cuando el jugador escoge su personaje.


func _draw() -> void:
    draw_world()
    draw_hud()
    if notification_timer > 0.0 and mode != "title":
        panel(Rect2(306, 468, 350, 37), Color("#194e62"), GOLD, 2.0)
        write_text(Vector2(320, 492), notification, 16, CREAM)
    match mode:
        "title": draw_title()
        "select": draw_select()
        "club": draw_club()
        "memory": draw_memory()
        "cashier": draw_cashier()
        "journal": draw_journal()
        "pause": draw_pause()
        "message": draw_message()
        "quiz": draw_quiz()
        "sequence": draw_sequence()
        "ending": draw_ending()

func draw_world() -> void:
    draw_set_transform(-camera)
    var start_x: int = maxi(0, int(camera.x / 32) - 1)
    var start_y: int = maxi(0, int(camera.y / 32) - 1)
    var stop_x: int = mini(60, int((camera.x + SW) / 32) + 3)
    var stop_y: int = mini(40, int((camera.y + SH) / 32) + 3)
    for yy in range(start_y, stop_y):
        for xx in range(start_x, stop_x):
            var center := Vector2(xx * 32 + 16, yy * 32 + 16)
            var key := "grass"
            if center.y >= 596 and center.y <= 720:
                key = "road"
            if (absf(center.x - 372.0) <= 62.0 or absf(center.x - 1263.0) <= 59.0) and center.y > 415 and center.y < 1180:
                key = "road"
            if absf(center.x - 1667.0) <= 60.0 and center.y >= 682 and center.y <= 920:
                key = "road"
            if xx >= 24 and xx <= 34 and yy >= 2 and yy <= 11:
                key = "paving"
            draw_texture_rect(tex[key], Rect2(xx * 32, yy * 32, 32, 32), false)
            # Tintado de ambiente segun la region (Sierra, Costa, Selva)
            if center.x < 720.0:
                draw_rect(Rect2(xx * 32, yy * 32, 32, 32), Color(0.12, 0.42, 0.18, 0.08))
            elif center.x < 1380.0:
                draw_rect(Rect2(xx * 32, yy * 32, 32, 32), Color(0.85, 0.72, 0.38, 0.16))
            else:
                draw_rect(Rect2(xx * 32, yy * 32, 32, 32), Color(0.05, 0.65, 0.18, 0.16))
            if key == "grass" and (xx * 17 + yy * 29) % 41 == 7:
                draw_texture(tex["flower"], Vector2(xx * 32, yy * 32))
    # Letreros de regiones de Tributa Peru
    world_label(Vector2(220, 565), "--- REGION SIERRA: VILLA ESPERANZA (HUANUCO) ---", Color("#274e30"), 15)
    world_label(Vector2(840, 565), "--- REGION COSTA: MERCADO Y ADUANAS ---", Color("#6d521d"), 15)
    world_label(Vector2(1420, 565), "--- REGION SELVA: FERIA EMPRENDEDORA ---", Color("#195828"), 15)
    # Plaza central, fuente e indicaciones.
    draw_rect(Rect2(853, 216, 115, 80), Color("#88b9c3"))
    draw_rect(Rect2(863, 226, 95, 60), Color("#55b4cc"))
    draw_circle(Vector2(911, 255), 24.0, Color("#6fcfe0"))
    draw_circle(Vector2(911, 255), 7.0, Color("#e0f7e7"))
    world_label(Vector2(858, 342), "PLAZA EMPRENDE", Color("#325b65"), 15)
    for b in buildings:
        var bp: Vector2 = b["pos"]
        if Rect2(bp, Vector2(256, 220)).intersects(Rect2(camera, Vector2(SW, SH))):
            draw_texture(tex[b["tex"]], bp)
            world_label(bp + Vector2(31, 285 - 220), str(b["title"]), CREAM, 13)
            # Camino de entrada.
            draw_rect(Rect2(bp.x + 111, bp.y + 205, 35, 42), Color("#d6ae78"))
    for t in decor_trees:
        if Rect2(t, Vector2(64, 70)).intersects(Rect2(camera, Vector2(SW, SH))):
            draw_texture(tex["tree"], t)
    for i in range(6):
        var id := "coin_%d" % i
        var pos := Vector2(545.0 + i * 115.0, 689.0 if i % 2 == 0 else 604.0)
        if not obtained.has(id):
            draw_texture(tex["coin"], pos - Vector2(16, 16 + sin(elapsed * 4.0 + i) * 4.0))
    for chest in bonus_chests:
        if not chests.has(chest["id"]):
            var cp: Vector2 = chest["pos"]
            draw_texture(tex["chest"], cp - Vector2(16, 16))
            if player.distance_to(cp) < 74:
                world_label(cp + Vector2(-27, -29), "E: COFRE", GOLD, 13)
    for ob in objects:
        if int(ob["level"]) != level or obtained.has(ob["id"]):
            continue
        var p: Vector2 = ob["pos"]
        draw_circle(p, 21 + sin(elapsed * 4.0) * 2.0, Color(1.0, 0.88, 0.43, 0.27))
        draw_texture(tex[ob["kind"]], p - Vector2(16, 15 + sin(elapsed * 3.0) * 4.0))
        if player.distance_to(p) < 83:
            world_label(p + Vector2(-35, -36), "E: RECOGER", GOLD, 14)
    for npc in npcs:
        var np: Vector2 = npc["pos"]
        var npc_id := str(npc["id"])
        if npc_id == "mara" and hero != "maria":
            draw_hero("maria", Rect2(np.x - 35, np.y - 83, 70, 82), 0, 1)
        elif npc_id == "luis" and hero != "luis":
            draw_hero("luis", Rect2(np.x - 38, np.y - 84, 76, 84), 0, 1)
        elif npc_id == "juan" and hero != "juan":
            draw_hero("juan", Rect2(np.x - 35, np.y - 82, 70, 82), 0, 1)
        else:
            draw_texture_rect(tex["alex"] if npc_id == "juan" else tex[npc_id], Rect2(np.x - 20, np.y - 56, 40, 60), false)
        var npc_display := str(npc["name"])
        if hero == "juan" and npc_id == "juan":
            npc_display = "Club de Retos"
        if hero == "maria" and npc_id == "mara":
            npc_display = "Mara"
        if hero == "luis" and npc_id == "luis":
            npc_display = "Guía RUC"
        world_label(np + Vector2(-46, -108), npc_display + " · " + str(npc["role"]), INK, 13)
        if int(npc["stage"]) == level:
            draw_circle(np + Vector2(0, -132 + sin(elapsed * 4.0) * 3.0), 13, GOLD)
            world_label(np + Vector2(-4, -127 + sin(elapsed * 4.0) * 3.0), "!", INK, 19)
        if player.distance_to(np) < 82:
            world_label(np + Vector2(-25, 27), "[E] HABLAR", CREAM, 14)
    # Personaje protagonista y sombra.
    draw_circle(player + Vector2(0, -4), 15, Color(0.12, 0.25, 0.26, 0.22))
    var walk_frame: int = [0, 1, 2, 1][int(elapsed * 8.0) % 4] if hero_moving else 1
    var walk_dir: int = 0
    if absf(facing.x) > absf(facing.y):
        walk_dir = 1 if facing.x < 0.0 else 2
    elif facing.y < 0.0:
        walk_dir = 3
    draw_hero(hero, Rect2(player.x - 38, player.y - 84, 76, 84), walk_dir, walk_frame)
    world_label(player + Vector2(-23, -88), hero.to_upper(), CREAM, 14)
    draw_set_transform(Vector2.ZERO)

func world_label(where: Vector2, content: String, color: Color, size: int) -> void:
    draw_string(font, where + Vector2(1, 1), content, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color("#182c42"))
    draw_string(font, where, content, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func panel(r: Rect2, bg: Color, outline: Color, thick: float = 2.0) -> void:
    draw_rect(r, Color("#091828"))
    draw_rect(r.grow(-3), bg)
    draw_rect(r.grow(-2), outline, false, thick)

func write_text(where: Vector2, content: String, size: int = 17, color: Color = INK) -> void:
    draw_string(font, where, content, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func wrap_lines(text: String, max_chars: int) -> Array:
    var lines: Array = []
    for para in text.split("\n"):
        var current := ""
        for word in para.split(" "):
            if current.length() + word.length() + 1 > max_chars and current != "":
                lines.append(current)
                current = ""
            current += (" " if current != "" else "") + word
        lines.append(current)
    return lines

func multiline(where: Vector2, content: String, size: int, max_chars: int, line_height: int, color: Color, max_lines: int = 12) -> void:
    var ls: Array = wrap_lines(content, max_chars)
    for i in range(mini(ls.size(), max_lines)):
        write_text(where + Vector2(0, i * line_height), str(ls[i]), size, color)

func current_region() -> String:
    if player.x < 720.0:
        return "SIERRA · HUÁNUCO"
    elif player.x < 1380.0:
        return "COSTA · ADUANAS Y COMERCIO"
    else:
        return "SELVA · FERIA DEL EMPRENDEDOR"

func draw_hud() -> void:
    panel(Rect2(12, 12, 516, 122), NAVY, GOLD)
    write_text(Vector2(27, 36), "TRIBUTA PERÚ  /  " + hero.to_upper(), 20, GOLD)
    write_text(Vector2(245, 36), "📍 " + current_region(), 14, Color("#88ddff"))
    var level_text := "AVENTURA COMPLETA" if level > 5 else "NIVEL %d  ·  %s" % [level, LEVEL_NAMES[level - 1]]
    write_text(Vector2(27, 63), level_text, 16, Color("#ffffff"))
    multiline(Vector2(27, 90), objective(), 14, 57, 18, Color("#c9e9e3"), 2)

    # 3 CONTADORES OFICIALES DEL GDD
    panel(Rect2(538, 12, 202, 122), NAVY, GOLD)
    draw_texture_rect(tex["coin"], Rect2(548, 22, 20, 20), false)
    write_text(Vector2(576, 38), "Monedas: %d" % coins, 15, CREAM)
    write_text(Vector2(548, 70), "🏛 Fondo: S/ %d" % contribution, 15, GREEN)
    write_text(Vector2(548, 102), "★ Reputación: %d pts" % reputation, 15, GOLD)

    panel(Rect2(750, 12, 198, 147), NAVY, GOLD)
    write_text(Vector2(762, 32), "MINIMAPA", 14, GOLD)
    var mr := Rect2(763, 41, 172, 107)
    draw_rect(mr, Color("#8ac77e"))
    draw_rect(Rect2(mr.position + Vector2(0, 600.0 / WH * 107.0), Vector2(172, 12)), Color("#e8ce9e"))
    for b in buildings:
        var bp: Vector2 = b["pos"]
        var p := mr.position + Vector2(bp.x / WW * mr.size.x, bp.y / WH * mr.size.y)
        draw_rect(Rect2(p, Vector2(22, 13)), Color("#405f79"))
    var target := active_npc_pos()
    var target_mini := mr.position + Vector2(target.x / WW * mr.size.x, target.y / WH * mr.size.y)
    draw_circle(target_mini, 4.5, GOLD)
    var pmini := mr.position + Vector2(player.x / WW * mr.size.x, player.y / WH * mr.size.y)
    draw_circle(pmini, 4.5, Color("#ec4448"))
    panel(Rect2(14, 505, 682, 27), NAVY, Color("#5e8299"), 1)
    write_text(Vector2(25, 524), "WASD: moverse    E: hablar    J: diario    H: pista    K: guardar    ESC: pausa", 14, CREAM)
    if delivery_active and mode != "title":
        panel(Rect2(538, 140, 202, 34), NAVY, GOLD)
        write_text(Vector2(548, 163), "ENTREGA: %ds" % int(ceil(delivery_seconds)), 15, GOLD)

func dim() -> void:
    draw_rect(Rect2(0, 0, SW, SH), Color(0.04, 0.10, 0.18, 0.78))

func draw_title() -> void:
    dim()
    panel(Rect2(118, 50, 725, 435), NAVY, GOLD, 3.0)
    draw_texture_rect(tex["logo"], Rect2(450, 71, 62, 62), false)
    write_text(Vector2(326, 180), "TRIBUTA PERU", 42, GOLD)
    write_text(Vector2(261, 213), "LA AVENTURA DE LOS TRES AMIGOS", 21, CREAM)
    draw_hero("maria", Rect2(281, 226, 91, 104), 0, 1)
    draw_hero("juan", Rect2(434, 226, 91, 104), 0, 1)
    draw_hero("luis", Rect2(587, 226, 91, 104), 0, 1)
    write_text(Vector2(281, 356), "5 NIVELES  ·  RETOS  ·  EXPLORACION", 19, CREAM)
    write_text(Vector2(279, 401), "ENTER: " + ("CONTINUAR PARTIDA" if has_saved else "ELEGIR PERSONAJE"), 20, GOLD)
    write_text(Vector2(331, 432), "N: NUEVA AVENTURA", 17, CREAM)
    write_text(Vector2(308, 468), "Juego educativo no oficial sobre SUNAT", 13, Color("#bcd4db"))

func draw_message() -> void:
    dim()
    panel(Rect2(101, 148, 758, 258), CREAM, GOLD, 3.0)
    draw_rect(Rect2(107, 154, 746, 47), NAVY)
    write_text(Vector2(127, 185), dialog_title, 23, GOLD)
    multiline(Vector2(130, 240), dialog_body, 20, 57, 30, INK, 5)
    if dialog_title.begins_with("MARÍA") and hero != "maria":
        draw_hero("maria", Rect2(763, 293, 70, 80), 0, 1)
    elif dialog_title.begins_with("LUIS") and hero != "luis":
        draw_hero("luis", Rect2(763, 293, 70, 80), 0, 1)
    elif dialog_title.begins_with("JUAN") and hero != "juan":
        draw_hero("juan", Rect2(763, 293, 70, 80), 0, 1)
    write_text(Vector2(285, 382), "ENTER / ESPACIO para continuar ▶", 17, Color("#406077"))

func draw_quiz() -> void:
    dim()
    panel(Rect2(120, 92, 720, 368), CREAM, GOLD, 3.0)
    draw_rect(Rect2(126, 98, 708, 45), NAVY)
    write_text(Vector2(151, 129), quiz_title, 22, GOLD)
    multiline(Vector2(158, 178), quiz_question, 19, 60, 26, INK, 2)
    for i in range(quiz_options.size()):
        var y := 243 + i * 59
        draw_rect(Rect2(176, y, 608, 49), Color("#d7e6dd"))
        draw_rect(Rect2(176, y, 608, 49), Color("#4b7b7a"), false, 2)
        draw_circle(Vector2(202, y + 24), 16, NAVY)
        write_text(Vector2(197, y + 30), str(i + 1), 19, GOLD)
        write_text(Vector2(230, y + 30), str(quiz_options[i]), 17, INK)
    if quiz_error != "":
        write_text(Vector2(191, 442), quiz_error, 14, Color("#bd4343"))
    else:
        write_text(Vector2(232, 442), "Pulsa 1, 2 o 3 (o haz clic).", 15, Color("#4d6575"))

func draw_sequence() -> void:
    dim()
    panel(Rect2(134, 104, 692, 343), CREAM, GOLD, 3.0)
    draw_rect(Rect2(140, 110, 680, 44), NAVY)
    write_text(Vector2(163, 140), "MINIJUEGO: ORDENAR EL PROCESO", 22, GOLD)
    write_text(Vector2(161, 185), "Selecciona los pasos en el orden mas adecuado:", 17, INK)
    var labels := ["Obtener Clave SOL", "Definir tu actividad economica", "Inscribirte en el RUC"]
    for i in range(3):
        var y := 204 + i * 62
        draw_rect(Rect2(165, y, 630, 52), Color("#d8e7db"))
        draw_rect(Rect2(165, y, 630, 52), Color("#6a9696"), false, 2)
        write_text(Vector2(187, y + 33), "%d.  %s" % [i + 1, labels[i]], 19, INK)
    write_text(Vector2(172, 410), "Paso %d/3  |  %s" % [sequence_index, sequence_tip], 15, Color("#34586d"))

func draw_pause() -> void:
    dim()
    panel(Rect2(254, 146, 452, 232), NAVY, GOLD, 3.0)
    write_text(Vector2(390, 204), "PAUSA", 31, GOLD)
    write_text(Vector2(303, 251), "ESC o ENTER: volver al juego", 19, CREAM)
    write_text(Vector2(303, 285), "K: guardar partida", 19, CREAM)
    write_text(Vector2(303, 318), "N: volver al menu principal", 18, CREAM)

func draw_ending() -> void:
    dim()
    panel(Rect2(121, 63, 718, 409), NAVY, GOLD, 3.0)
    draw_texture_rect(tex["logo"], Rect2(446, 83, 70, 70), false)
    write_text(Vector2(273, 206), "¡EMPRENDEDOR RESPONSABLE!", 29, GOLD)
    write_text(Vector2(325, 248), "COMPLETASTE LOS 5 NIVELES", 20, CREAM)
    write_text(Vector2(336, 291), "Monedas: %d    Estrellas: %d" % [coins, stars], 21, GREEN)
    multiline(Vector2(270, 331), "Aprendiste sobre SUNAT, RUC, comprobantes, IGV y cultura tributaria.", 17, 47, 25, CREAM, 3)
    write_text(Vector2(270, 425), "N: volver a jugar   |   ENTER: menu", 17, GOLD)


# =================== VERSION AMPLIADA: PERSONAJES Y RETOS ===================
func draw_hero(who: String, target: Rect2, direction: int = 0, frame: int = 1) -> void:
    var key := "hero_" + who
    if not tex.has(key):
        return
    var area := Rect2(float(frame * 96), float(direction * 96), 96.0, 96.0)
    draw_texture_rect_region(tex[key], target, area)

func select_hero(index: int) -> void:
    hero = HEROES[clampi(index, 0, 2)]
    mode = ""
    save_game()
    play_sound("success")
    start_scene_1()

func start_scene_1() -> void:
    open_message("ESCENA 1 · PLAZA DE VILLA ESPERANZA", 
        "Plaza de Villa Esperanza (Huánuco). Pistas con baches y la escuela necesita reparaciones.\n\nLUIS: Don Juan, una gaseosa y unas galletas, por favor.\nJUAN: Son cinco soles, Luis. Aquí tienes.\n\n[Luis paga y se va sin pedir comprobante. Juan guarda el dinero en un cajón sin anotar nada. María observa desde la puerta de la bodega...]", 
        "scene1_maria")

func draw_select() -> void:
    dim()
    panel(Rect2(102, 66, 755, 419), NAVY, GOLD, 3.0)
    write_text(Vector2(289, 124), "ELIGE TU PERSONAJE", 29, GOLD)
    write_text(Vector2(223, 161), "Cada amigo aprende y explora a su manera", 18, CREAM)
    var labels := ["1. MARÍA", "2. JUAN", "3. LUIS"]
    var traits := ["Solidaria y líder", "Atento y protector", "Valiente y alegre"]
    for i in range(3):
        var bx: int = 168 + i * 219
        draw_rect(Rect2(bx, 210, 194, 216), Color("#22536a"))
        draw_rect(Rect2(bx, 210, 194, 216), GOLD, false, 2)
        draw_hero(HEROES[i], Rect2(bx + 43, 233, 110, 123), 0, 1)
        write_text(Vector2(bx + 29, 379), labels[i], 22, GOLD)
        write_text(Vector2(bx + 19, 405), traits[i], 13, CREAM)
    write_text(Vector2(326, 463), "Pulsa 1, 2, 3 o haz clic", 17, CREAM)

func draw_club() -> void:
    dim()
    panel(Rect2(154, 109, 650, 334), NAVY, GOLD, 3.0)
    draw_hero("juan", Rect2(188, 149, 89, 104), 0, 1)
    write_text(Vector2(297, 170), "JUAN · CLUB DE RETOS", 27, GOLD)
    multiline(Vector2(298, 207), "¿Te animas a ayudar al pueblo? Estos retos opcionales dan monedas y estrellas.", 17, 43, 26, CREAM, 3)
    write_text(Vector2(212, 294), "1  MEMORIA TRIBUTARIA" + ("  ✓" if side_tasks.has("memory") else ""), 20, CREAM)
    write_text(Vector2(212, 337), "2  ENTREGA EXPRESS" + ("  ✓" if side_tasks.has("delivery") else ""), 20, CREAM)
    write_text(Vector2(212, 381), "3  VOLVER A EXPLORAR", 19, GOLD)

func begin_memory() -> void:
    memory_cards = ["RUC", "IGV", "BOLETA", "RUC", "IGV", "BOLETA"]
    memory_cards.shuffle()
    memory_shown.clear()
    memory_solved.clear()
    memory_miss_timer = 0.0
    mode = "memory"

func flip_memory(index: int) -> void:
    if mode != "memory" or memory_miss_timer > 0.0:
        return
    if index < 0 or index >= memory_cards.size():
        return
    if memory_solved.has(index) or memory_shown.has(index):
        return
    memory_shown.append(index)
    play_sound("pickup")
    if memory_shown.size() == 2:
        var a: int = int(memory_shown[0])
        var b: int = int(memory_shown[1])
        if memory_cards[a] == memory_cards[b]:
            memory_solved.append(a)
            memory_solved.append(b)
            memory_shown.clear()
            play_sound("success")
            if memory_solved.size() == 6:
                if not side_tasks.has("memory"):
                    coins += 50
                    stars += 1
                    side_tasks["memory"] = true
                save_game()
                open_message("¡MEMORIA TRIBUTARIA RESUELTA!", "Formaste las parejas RUC, IGV y BOLETA. RUC identifica contribuyentes, el IGV es un impuesto y la boleta es un comprobante de pago. ¡Reto completado!", "")
        else:
            memory_miss_timer = 0.85
            play_sound("wrong")

func draw_memory() -> void:
    dim()
    panel(Rect2(140, 82, 681, 387), NAVY, GOLD, 3.0)
    write_text(Vector2(281, 136), "MEMORIA TRIBUTARIA", 27, GOLD)
    write_text(Vector2(220, 172), "Encuentra las tres parejas de conceptos", 18, CREAM)
    for i in range(6):
        var x := 229 + (i % 3) * 172
        var y := 207 + (i / 3) * 105
        var revealed: bool = memory_shown.has(i) or memory_solved.has(i)
        draw_rect(Rect2(x, y, 154, 89), Color("#d5f1df") if revealed else Color("#287e90"))
        draw_rect(Rect2(x, y, 154, 89), GOLD if memory_solved.has(i) else CREAM, false, 2)
        var label: String = str(memory_cards[i]) if revealed else "?  %d" % (i + 1)
        write_text(Vector2(x + 26, y + 54), label, 20, NAVY if revealed else CREAM)
    write_text(Vector2(272, 450), "Teclas 1 a 6 o clic · ESC salir", 16, CREAM)

func begin_delivery() -> void:
    if delivery_active:
        mode = ""
        toast("¡Ya llevas un folleto! Busca a María.")
        return
    delivery_active = true
    delivery_seconds = 65.0
    mode = ""
    save_game()
    open_message("ENTREGA EXPRESS", "¡Misión especial! Juan te entrega un folleto sobre cultura tributaria. Busca a María junto a la oficina de orientación antes de 65 segundos y habla con ella. El tiempo avanza solo al explorar.", "")

func draw_journal() -> void:
    dim()
    panel(Rect2(114, 71, 736, 403), CREAM, GOLD, 3.0)
    draw_rect(Rect2(121, 78, 722, 51), NAVY)
    write_text(Vector2(158, 113), "DIARIO DE AVENTURAS", 27, GOLD)
    var info := [
        "1  SUNAT: administra tributos nacionales y aduanas.",
        "2  RUC: identificador tributario de 11 dígitos.",
        "3  BOLETA: comprobante para consumidores finales.",
        "4  IGV: impuesto que grava ciertas operaciones.",
        "5  CULTURA TRIBUTARIA: cumplir de manera responsable."
    ]
    for i in range(5):
        var checked := "✓" if level > i + 1 else "·"
        write_text(Vector2(148, 167 + i * 43), checked + "  " + info[i], 17, INK)
    draw_rect(Rect2(149, 393, 661, 46), Color("#e5ecdf"))
    write_text(Vector2(162, 413), "Extra: memoria " + ("✓" if side_tasks.has("memory") else "-") + "  /  entrega " + ("✓" if side_tasks.has("delivery") else "-"), 16, INK)
    write_text(Vector2(175, 458), "ENTER, J o ESC: volver", 14, INK)


func draw_cashier() -> void:
    dim()
    panel(Rect2(115, 83, 729, 375), CREAM, GOLD, 3.0)
    draw_rect(Rect2(122, 90, 715, 51), NAVY)
    write_text(Vector2(238, 124), "MINIJUEGO: ATIENDE LA TIENDA", 24, GOLD)
    write_text(Vector2(154, 181), "CLIENTE %d DE 3" % (cashier_index + 1), 20, INK)
    var clients := [
        "Un vecino compra pan para su familia. No lo usará para un negocio.",
        "Una empresa solicita un comprobante para sustentar su compra.",
        "Una niña compra un cuaderno para uso personal."
    ]
    multiline(Vector2(154, 212), clients[cashier_index], 18, 67, 26, INK, 3)
    write_text(Vector2(154, 277), "¿Qué comprobante emites en esta venta?", 18, INK)
    draw_rect(Rect2(185, 298, 258, 93), Color("#cbe8d6"))
    draw_rect(Rect2(185, 298, 258, 93), Color("#467c83"), false, 2)
    write_text(Vector2(225, 342), "1 · BOLETA", 22, INK)
    write_text(Vector2(225, 371), "Consumidor final", 15, INK)
    draw_rect(Rect2(515, 298, 258, 93), Color("#d4d9f1"))
    draw_rect(Rect2(515, 298, 258, 93), Color("#467c83"), false, 2)
    write_text(Vector2(544, 342), "2 · FACTURA", 22, INK)
    write_text(Vector2(544, 371), "Uso empresarial", 15, INK)
    if cashier_feedback != "":
        write_text(Vector2(150, 427), cashier_feedback, 15, Color("#ac4243"))
    else:
        write_text(Vector2(248, 427), "Pulsa 1 o 2, o haz clic en el comprobante", 15, INK)

func toggle_music() -> void:
    music.stream_paused = not music.stream_paused
    toast("Música encendida" if not music.stream_paused else "Música en pausa")
