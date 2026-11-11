# Selva · Nueva Semilla

Abrir `res://regiones/selva/escenas/selva.tscn` y pulsar **F6** en Godot 4.7.
También se puede iniciar el proyecto con F5 y pulsar **Explorar nueva Selva** en la portada.
El festival del prototipo sigue siendo un contenido separado.

**Controles:** WASD/flechas, E/Enter para interactuar, 1–3 o ratón para elegir,
J diario, H pista, K guardar, M música y Esc pausa/cerrar diálogo.
Para regresar al prototipo: Esc → Más opciones → Volver al menú principal.

## Recorrido

1. Hablar con Ana (barrio norte) o la docente (escuela noreste), comparar
   Beto y Rosa (mercado suroeste), reservar la oferta con comprobante.
2. Con Rosa, registrar producto, cantidad e importe de la venta simulada.
3. Examinar alumbrado y agua en la plaza y el aviso junto a la escuela;
   conversar con Elena y elegir el uso comunitario del presupuesto.
4. En el embarcadero sureste, examinar cajas, lista y nota de ruta;
   escuchar a Diego y comunicar los indicios a Lucía, responsable del control.
5. Regresar con Rosa, pagar los dos cuadernos y verificar los tres datos
   de la boleta. La capitana confirma la salida preparada hacia Costa.

Las actividades **+** son opcionales: separar tres residuos (papel en barrio,
botella al sur del mercado, cáscara al sur de la plaza), cruzar desde el cartel
sur con señal PASA, y responder las cinco preguntas de Tomi al sur de la plaza.
El diario muestra objetivos completados, materiales y recompensas recibidas.

## Guardado e integración

`user://tributa_peru_selva_v1.json` es una partida lateral independiente.
Conserva personaje, posición, objetivos, recompensas y desbloqueos. Se guarda
en interacciones, cambios de personaje, cada 15 segundos de exploración,
con K y al cerrar la ventana. Una partida ilegible se conserva y se desactiva
su escritura durante esa sesión. Las escrituras usan un archivo temporal.

Si no existe partida de Selva, se leen una sola vez el personaje y la cartera
del prototipo, con las mismas claves y unidades (`hero`, `coins`, `stars`,
`contribution`, `reputation`). La partida original nunca se escribe. El progreso
posterior de ambos modos permanece separado: no se sincronizan carteras.

La única adaptación de la escena existente `main.tscn` es el nodo adicional
`AccesoSelva`, con `scripts/acceso_menu.gd`. `scripts/main.gd` permanece intacto.
Quitar ese nodo y su recurso externo revierte el acceso del menú.

Para conectar Costa, asignar una escena existente a la propiedad exportada
`costa_scene`, o conectar `costa_requested(context)` del nodo raíz para que el
gestor del equipo reciba personaje, cartera y desbloqueos. Si un gestor externo
cambia de escena, debe dejar vacía `costa_scene` para evitar dos transiciones.
La señal se emite una vez por instancia al solicitar viajar, tras completar
las cinco misiones. `state.integration_context()` también permite consultar
los datos. Con la propiedad vacía, solo se muestra un aviso y se conserva Selva.

## Arquitectura

- `escenas/selva.tscn`: entrada F6, crea el módulo en tiempo de ejecución.
- `scripts/selva.gd`: coordinación, controles, audio e integración.
- `scripts/mundo.gd`: mapa, arte procedural local y obstáculos físicos.
- `scripts/jugador.gd`: CharacterBody2D, cámara y sprites existentes.
- `scripts/punto_interactivo.gd`: NPC, objetos e indicadores.
- `scripts/misiones.gd`: diálogos, decisiones y actividades.
- `scripts/progreso.gd`: estados, recompensas únicas y persistencia.
- `scripts/interfaz.gd`: HUD, diálogos y diario con desplazamiento.
- `scripts/acceso_menu.gd`: enlace desde la portada del prototipo.

El mapa y los controles se crean al ejecutar la escena; no se muestran
completos como nodos editables en la vista 2D del editor. El arte nuevo se
dibuja por código y los sprites y sonidos se reutilizan sin sobrescribirlos.

## Verificación

Ejecutar desde la raíz, sustituyendo `godot` por la ruta del ejecutable local:

```text
godot --headless --path . --script res://regiones/selva/pruebas/probar_selva.gd
```

La prueba crea sus archivos únicamente en `.godot/selva_validation/`.
Valida secuencia, errores y reintentos, pagos y recompensas únicas, tres
secundarias, guardado/carga, partida dañada, recursos, tres personajes,
movimiento por teclado, cámara, colisión física, accesibilidad del mapa,
diálogos, diario, cinco misiones mediante el controlador y sus botones,
desbloqueo y señal de Costa. La escena principal anterior también se carga.

Resultado local con Godot 4.7.2: **118 verificaciones, 0 fallos**. Se importó
el proyecto y se ejecutó también la portada existente en modo headless.
El motor informó que no pudo leer el almacén de certificados del sistema;
las pruebas locales finalizaron correctamente. Al cerrar la portada anterior
se reportan recursos de `aventura_musica.wav` aún en uso: se reprodujo el mismo
aviso con el nodo nuevo de acceso retirado en memoria, sin editar el prototipo.
La prueba de Selva finaliza sin ese aviso de recursos.

Pendiente de revisión humana: aspecto final en ventana, fluidez percibida,
volumen de audio y comodidad con teclado y ratón. Las pruebas headless no
equivalen a una revisión visual ni auditiva. Costa y Sierra no se desarrollan
en este módulo. No se incluyen los compañeros animales opcionales.
