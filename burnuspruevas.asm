	output "BURNUS.rom"
	
	
CLS			equ	#00C3	;CLS											;borra la pantalla
SCREEN0		equ	#006C	;INITXT											;pasa a modo screen 0
SCREEN1		equ	#006F	;INIT32											;pasa a modo screen 1 
MODOTEXTO	equ	#00D2	;TOTEXT											:fuerza a modo texto
LOCATE		equ	#00C6	;POSIT											;coloca el cursor en una directrices h,l
CHPUT		equ	#00A2	;CHPUT											;escribe un caracter en pantalla
KEYOFF		equ	#00CC	;ERAFNK											;hace desaparecer las teclas de función
COLOR		equ	#0062	;CHGCLR											;da color a la pantalla
COLLETRA	equ	#F3E9	;FORCLR											;define el color de letras para CHGCLR
COLFONDO	equ	#F3EA	;BAKCLR											;define el color de fondo para CHGCLR
COLBORDE	equ	#F3EB	;BDRCLR											;defeine el color de bordes para CHGCLR
INPUT		equ	#009F	;CHGET											;espera que pulses una tecla y manda el valor a registro a
ANCHOSC0	equ	#F3AF	;LINL40											;define el width de screen 0
ANCHOSC1	equ	#f3AF	;LINL32											;define el width de screen 1
CLICKOFF	equ	#f3DB	;CLIKSW											;quita el sonido del toque de teclas
DISSCR		equ	#0041													;desconecta la pantalla_en_blanco
ENASCR		equ	#0044													;conecta la pantalla


RDVDP		equ	#013E													;lee registro 8 del VDP
WRTVDP		equ	#0047													;escribe registros del VDP
GRABAVRAM	equ	#005C	;LDIRVM											;graba en vram una parte de ram
GRABARAM	equ	#0059	;LDIRMV											;grava en ram una parte de vram

SCREENX		equ	#005F	;CHGMOD											;elige el modo grafico
ONSTICK		equ	#00D5	;GTSTCK											;controla el stick
ONSTRIG		equ	#00D8	;GTTRIG											;controla los botones del joystick o la barra espaciadora
RESET		equ #003B	;INITIO											;reinicia el ordenador

H.KEYI		equ	#FD9A	;H.KEYI
H.TIMI		equ	#FD9F	;H.TIMI

SNSMAT		equ	#0141	;INKEY$											;controla si se ha pulsado una tecla_pulsada

ENASLT		equ	#0024													;para ampliar la rom		
RSLREG  	equ	#0138
SLOTVAR		equ	#C000

RG0SAV		equ	#F3DF													;COPIA DE vdp DEL REGISTRO 0 (BASIC:VDP(0))
RG1SAV		equ	#F3E0													;COPIA DE vdp DEL REGISTRO 1 (BASIC:VDP(1))
RG2SAV		equ	#F3E1													;COPIA DE vdp DEL REGISTRO 2 (BASIC:VDP(2))
RG3SAV		equ	#F3E2													;COPIA DE vdp DEL REGISTRO 3 (BASIC:VDP(3))
RG4SAV		equ	#F3E3													;COPIA DE vdp DEL REGISTRO 4 (BASIC:VDP(4))
RG5SAV		equ	#F3E4													;COPIA DE vdp DEL REGISTRO 5 (BASIC:VDP(5))
RG6SAV		equ	#F3E5													;COPIA DE vdp DEL REGISTRO 6 (BASIC:VDP(6))
RG7SAV		equ	#F3E6													;COPIA DE vdp DEL REGISTRO 7 (BASIC:VDP(7))
STATFL		equ	#F3E7													;COPIA DE vdp DEL REGISTRO 8 (EL QUE ES DE ESCRITURA (S#0))

	org		#4000	

	db	"AB"															;Cabecera de fichero ROM
	word	START														;Dónde empieza la ejecución
	word	0,0,0,0,0,0
		
;original from Ramones (http://karoshi.auic.es/index.php?topic=628.0)
; -----------------------
; SEARCH_SLOTSET
; Posiciona en pagina 2
; Nuestro ROM.
; -----------------------

search_slotset:
		call search_slot
		jp ENASLT


; -----------------------
; SEARCH_SLOT
; Busca slot de nuestro rom
; -----------------------

search_slot:

	call RSLREG
	rrca
	rrca
	and 3
	ld c,a
	ld b,0
	ld hl,0FCC1h
	add hl,bc
	ld a,(hl)
	and 080h
	or c
	ld c,a
	inc hl
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	and 0Ch
	or c
	ld h,080h
	ld (SLOTVAR),a
	ret		
	
START:

; ampliamos la lectura de rom a 32 k

		di
		
		im		1														;modo de interrupciones 1
		ld		sp,#F380												; colocmos la pila en esta posicion, que suele ser donde empieza las zona ram que usa el S.O. del MSX. Recuerda que la pila crece hacia abajo así que no pisaremos nada

		call	search_slotset
		
		ei

;descomprimimos la musica

		ld		hl,CANCION												;descomprime musica de inicio
		ld		de,SAXOLO
		call	depack
		
		ld		hl,MUSICA_GAMEOVER										;descomprime musica game over
		ld		de,GAME_OVER
		call	depack
		
;		ld		hl,MUSICA_FASES											;descomprime musica game over
;		ld		de,FASES
;		call	depack	
		
		ld		hl,SILENCIO												;descomprime musica mute
		ld		de,MUTE
		call	depack
		
		ld		hl,MUSICA_MUERTO										;descomprime musica mute
		ld		de,MUERTO
		call	depack
		
		ld		hl,MUSICA_ENTRE_FASES									;descomprime musica entre fases
		ld		de,ENTRE_FASES
		call	depack
								
;inicializamos la música
		
		call	activa_musica_menu
		
		ld		hl,EFECTOS_BANCO										;hl ahora vale la direccion donde se encuentran los efectos
		call	ayFX_SETUP												;inicia el reproductor de efectos
		
;salva actual rutina en H.KEYI

		ld		de,VIEJA_INTERR											;coge la dirección de la antigua interrupcion de gancho
		ld		hl,H.TIMI												;coge la dirección de la entrada de gancho de interrupción
		ld		bc,5													;longitud del gancho a 5 bytes
		ldir															;lo transfiere
		
;engancha nuestra rutina de servicio al gancho que djea preparada la BIOS cuando se termina de pintar la pantalla (50 o 60 veces por segundo)

		ld		a,#C3													;#c3 es el código binario de jump (jp)
		ld		[H.TIMI],a												;metemos en H.TIMI ese jp
		ld		hl,nuestra_isr											;cargamos nuestra secuencia en hl
		ld		[H.TIMI+1],hl											;la ponemos a continuación del jp
		
		ei																;conectamos las interrupciones
		
		call	musica_con_bucle

PANTALLA_DE_CARGA:
		
		call	PREPARACION_SCREEN_2
		call	DISSCR													;desconectamos la pantalla
		call	limpia_sprites
		
		xor		a
		ld		[COLLETRA],a											;aunque sólo quieras cambiar uno de los colores, tienes que volver a definir los otros dos para que te acepte un cambio
		ld		[COLFONDO],a
		ld		[COLBORDE],a
		call	COLOR
		
		ld		hl,pant_carga_til										;cargamos patrones
		ld		de,#0000
		call	depack_VRAM
		
		ld		hl,pant_carga											;carga el marcador
		ld		de,#1800
		call	depack_VRAM
		
		ld		hl,pant_carga_col										;cargamos colores de patrones
		ld		de,#2000
		call	depack_VRAM
			
		call	SPRITES_PETISOS
		
		call	ENASCR													;conectamos la pantalla
		
INICIA_MUSICA:

		call	activa_musica_menu										;inicia el reproductor de PT3
		
		ld		a,15
		ld		(petisoy),a
		ld		a,110
		ld		(petisox),a
		ld		a,40
		ld		(espera_petiso),a
		ld		(espera_petiso_resta_2),a
		ld		(espera_petiso_resta),a
petisos:
		
		xor		a
		CALL	ONSTRIG
		cp		0
		jr.		nz,MENU
		
		
		call	petiso_activity
		
		jr.		petisos
		
		jr.		MENU

petiso_activity:

		ld		a,(espera_petiso_resta)
		dec		a
		cp		0
		ld		(espera_petiso_resta),a
		ret		nz
		ld		a,(espera_petiso)
		ld		(espera_petiso_resta),a
		ld		a,(espera_petiso_resta_2)
		dec		a
		cp		0
		ld		(espera_petiso_resta_2),a
		ret		nz
		ld		a,(espera_petiso)
		ld		(espera_petiso_resta),a
		ld		(espera_petiso_resta_2),a
		
		ld		hl,(espera_petiso)
		ld		(espera_petiso_resta),hl

		ld		a,(petiso_que_toca)
		cp		0
		jr.		z,petiso_a_saltar
		
		xor		a
		ld		(petiso_que_toca),a
		ld		a,(petisoy)
		add		3
		ld		(petisoy),a
		jr.		registros_petiso
		
petiso_a_saltar:
		
		ld		a,16
		ld		(petiso_que_toca),a
		ld		a,(petisoy)
		sub		3
		ld		(petisoy),a
		jr.		registros_petiso

registros_petiso:

		halt
		ld		ix,atributos_sprite_general
		ld		a,(petisoy)
		ld		(ix),a
		ld		(ix+4),a
		ld		(ix+8),a
		ld		(ix+12),a
		ld		a,(petisox)
		ld		(ix+1),a
		ld		(ix+5),a
		ld		(ix+9),a
		ld		(ix+13),a
		ld		a,(petiso_que_toca)
		ld		(ix+2),a
		add		4
		ld		(ix+6),a
		add		4
		ld		(ix+10),a
		add		4
		ld		(ix+14),a
		ld		a,1
		ld		(ix+3),a
		ld		a,4
		ld		(ix+7),a
		ld		a,10
		ld		(ix+11),a
		ld		a,15
		ld		(ix+15),a
		
		jr.	atributos_sprites
						
MENU:		

		;prepara la pantalla
		
		call	limpia_sprites
		call	PREPARACION_SCREEN_2
		
		xor		a														;XOR se lo carga todo poniendolo a 0, es como un ld a,0 pero ocupa menos
		call	CLS
		
		ld		a,32													;pone el width a 32
		ld		[ANCHOSC1],a
		ld		a,0
		ld		[CLICKOFF],a											;quita el click de las teclas
		call	SCREEN1													;pasa a modo screen 1
	
		call	KEYOFF													;borramos las teclas de función
		call	SPRITES_PETISOS

PREPARA_VARIABLES_SERPIENTE:

		ld		a,2
		ld		(estado_serp),a
		ld		a,16
		ld		(y_serp),a
		ld		bc,1000
		ld		(clock),bc
		
		ld		a,174
		ld		(petisoy),a
		ld		a,49
		ld		(petisox),a
		ld		a,4
		ld		(espera_petiso),a
		ld		(espera_petiso_resta_2),a
		ld		(espera_petiso_resta),a
		
RUTINA_DE_MENU:

		ld		hl,letras_A					;redefine las letras
		ld		de,#0208
		ld		bc,8*26
		call	GRABAVRAM
		
		ld		hl,titulo_centro1			;redefine tiles de título
		ld		de,#0308
		ld		bc,8*15
		call	GRABAVRAM
		
		ld		hl,parentesis_a				;redefine parentesis
		ld		de,#0140
		ld		bc,8*2
		call	GRABAVRAM
		
		ld		hl,guion					;redefine guion y punto
		ld		de,#0158
		ld		bc,8*2
		call	GRABAVRAM
		
		ld		hl,numero0					;redefine numeros y dos puntos
		ld		de,#0180	
		ld		bc,8*11
		call	GRABAVRAM
				
PANTALLA_DE_SELECCION:
		
		xor		a
		call	CLS
				
		ld		h,1
		ld		l,4
		call	LOCATE
		ld		hl,titulo_1
		call	lee_pinta_una
				
		ld		h,1
		ld		l,11
		call	LOCATE
		ld		hl,titulo_8
		call	lee_pinta_una
		
		ld		h,15
		ld		l,14
		call	LOCATE
		ld		hl,mensaje
		call	lee_pinta_una
		
		ld		h,5
		ld		l,24
		call	LOCATE
		ld		hl,copyright
		call	lee_pinta_una
		
		ld		a,(idioma)
		cp		0
		jr.		z,menu_castellano

menu_ingles:

		ld		h,3							;escribe pantalla de menu
		ld		l,1
		call	LOCATE
		ld		hl,empresa
		call	lee_pinta_una
			
		ld		h,12
		ld		l,16
		call	LOCATE
		ld		hl,teclado
		call	lee_pinta_una	
		
		ld		h,12
		ld		l,18
		call	LOCATE
		ld		hl,mando
		call	lee_pinta_una
				
		ld		h,12
		ld		l,20
		call	LOCATE
		ld		hl,instrucciones
		call	lee_pinta_una
		
		ld		h,12
		ld		l,22
		call	LOCATE
		ld		hl,salir
		call	lee_pinta_una
		
		jr.		rutina_colores_inicio
		
menu_castellano:

		ld		h,3							;escribe pantalla de menu
		ld		l,1
		call	LOCATE
		ld		hl,empresa_e
		call	lee_pinta_una
		
		ld		h,12
		ld		l,16
		call	LOCATE
		ld		hl,teclado_e
		call	lee_pinta_una	
		
		ld		h,12
		ld		l,18
		call	LOCATE
		ld		hl,mando_e
		call	lee_pinta_una
				
		ld		h,12
		ld		l,20
		call	LOCATE
		ld		hl,instruccion_e
		call	lee_pinta_una
		
		ld		h,12
		ld		l,22
		call	LOCATE
		ld		hl,salir_e
		call	lee_pinta_una		
				
rutina_colores_inicio:						;rutina de colores
		
		ld		a,15
		
rutina_colores:		
					
		ld		[COLLETRA],a				;aunque sólo quieras cambiar uno de los colores, tienes que volver a definir los otros dos para que te acepte un cambio
		push	af							;guardo el valor de a en la pila para utilizar ese registro pero la pila son dos bytes, por lo que debo guardar tambien f aunque no lo use
		ld		a,0
		ld		[COLFONDO],a
		ld		a,1
		ld		[COLBORDE],a
		call	COLOR
		pop		af							;recupero el valor de a
		dec		a
		ld		b,a
		cp		2
		jp		nz,rutina_colores
		
		push	af

contro_serpiente_a_pintar:

		call	petiso_activity

		ld		a,(estado_serp)
		inc		a
		ld		(estado_serp),a										;controla la serpiente que se pinta
		cp		2
		jp		z,pinta_serpiente_2
		cp		3
		jp		z,pinta_serpiente_2
		jp		pinta_serpiente_1
		
		
		
control_stick_menu:
		
		xor		a							;controla el movimiento de la serpiente en menu
		call	ONSTICK
		cp		1
		jp		z,sube_cursor
		cp		5
		jp		z,baja_cursor
		cp		0
		jp		z,control_strig_menu
		
control_strig_menu:							;controla si pulsa espacio para seleccionar una opcion

		xor		a
		CALL	ONSTRIG
		cp		0
		jp		nz,que_ha_elegido
				
controla_tiempo_para_cambio:				;contador para ir a mostrar los creditos

		ld		hl,(clock)
		ld		bc,1		
		sbc		hl,bc
		ld		(clock),hl
		jr		nz,termina_secuencia_color
								
		ld		bc,60000
		ld		(clock),bc
				
		jp		CREDITOS
		
		
termina_secuencia_color:					;cerramos este loop
				
		pop		af
		
		jp		rutina_colores_inicio
				
CREDITOS:
		
		call	limpia_sprites
						
		xor		a
		call	CLS
				
		ld		h,18
		ld		l,2
		call	LOCATE
		ld		hl,benja
		call	lee_pinta_una
				
		ld		h,28
		ld		l,7
		call	LOCATE
		ld		hl,royal
		call	lee_pinta_una
					
		ld		h,19
		ld		l,10
		call	LOCATE
		ld		hl,manu
		call	lee_pinta_una
		
		ld		h,1
		ld		l,12
		call	LOCATE
		ld		hl,ramon
		call	lee_pinta_una
		
		ld		h,1
		ld		l,14
		call	LOCATE
		ld		hl,fernando1
		call	lee_pinta_una
		
		ld		h,1
		ld		l,16
		call	LOCATE
		ld		hl,fernando2
		call	lee_pinta_una
		
		ld		h,1
		ld		l,18
		call	LOCATE
		ld		hl,felix
		call	lee_pinta_una
		
		ld		h,11
		ld		l,4
		call	LOCATE
		ld		hl,tromax
		call	lee_pinta_una
		
		ld		a,(idioma)
		cp		0
		jr.		z,creditos_castellano

creditos_ingles:

		ld		h,1
		ld		l,3
		call	LOCATE
		ld		hl,mano_derecha_e
		call	lee_pinta_una
		
		ld		h,1
		ld		l,1
		call	LOCATE
		ld		hl,programacion
		call	lee_pinta_una
		
		ld		h,1
		ld		l,6
		call	LOCATE
		ld		hl,musica
		call	lee_pinta_una
		
		ld		h,1
		ld		l,9
		call	LOCATE
		ld		hl,agradec
		call	lee_pinta_una
		
		jr.		controla_tiempo_para_cambio_2
		
creditos_castellano:
		
		ld		h,1
		ld		l,3
		call	LOCATE
		ld		hl,mano_derecha
		call	lee_pinta_una
		
		ld		h,1
		ld		l,1
		call	LOCATE
		ld		hl,programacion_e
		call	lee_pinta_una
		
		ld		h,1
		ld		l,6
		call	LOCATE
		ld		hl,musica_e
		call	lee_pinta_una
		
		ld		h,1
		ld		l,9
		call	LOCATE
		ld		hl,agradec_e
		call	lee_pinta_una
		
controla_tiempo_para_cambio_2:

		xor		a
		CALL	ONSTRIG
		cp		0
		jp		nz,prepara_contador_para_menu
		
		ld		hl,(clock)	
		ld		bc,1				
		sbc		hl,bc
		ld		(clock),hl
		
		jr		nz,controla_tiempo_para_cambio_2
			
prepara_contador_para_menu:

		ld		bc,1000
		ld		(clock),bc

		jp		MENU
				
que_ha_elegido:

		ld		a,1							;efecto de pinchar opción
		call	efecto_sonido
		
		ld		a,(y_serp)
		cp		16
		jp		z,prepara_teclado
		cp		18
		jp		z,prepara_mando
		cp		20
		jp		z,idioma_a_pintar
		cp		22
		jp		z,PANTALLA_DE_CARGA

idioma_a_pintar:
		
		ld		a,(idioma)
		cp		0
		jr.		nz,ingles

castellano

		ld		a,1
		ld		(idioma),a
		
		jr.		MENU
		
ingles:
	
		xor		a
		ld		(idioma),a
		
		JR.		MENU
					
prepara_teclado:

		xor		a
		ld		(stick_a_usar),a
		call	prepara_juego

prepara_mando:

		ld		a,1
		ld		(stick_a_usar),a
		call	prepara_juego
		
lee_pinta_una:								;imprime el texto fijo
		ld		a,[hl]
		ld		b,a
		
loop_lee_pinta_una:
		inc		hl
		ld		a,[hl]
		call	CHPUT
		djnz	loop_lee_pinta_una
		ret
		
controla_serpiente:

		ld		a,(estado_serp)
		cp		4
		ret		nz
		xor		a
		ld		(estado_serp),a
		ret
		
pinta_serpiente_1:
		
		ld		bc,[y_serp]
		ld		h,10
		ld		l,c
		call	LOCATE
		ld		hl,serp_1
		call	lee_pinta_una
		call	controla_serpiente
		ld		[y_serp],bc
		jp		control_stick_menu

pinta_serpiente_2:
		
		ld		bc,[y_serp]
		ld		h,10
		ld		l,c
		call	LOCATE
		ld		hl,serp_2
		call	lee_pinta_una
		call	controla_serpiente
		ld		[y_serp],bc
		jp		control_stick_menu
	
sube_cursor:								;comprueva si lo puede subir
 		 		
 		ld		a,(y_serp)
 		cp		16
 		jp		nz,lo_sube
 		jp		termina_secuencia_color

lo_sube:									;lo sube porque es posible

[5]		halt								;espera hasta el vblank 5 veces
	
		xor		a							;efecto de movimiento
		call	efecto_sonido
		
		ld		a,(y_serp)
		ld		h,10
		ld		l,a
		call	LOCATE
		ld		hl,nada
		call	lee_pinta_una
		
		ld		a,(y_serp)
		sub		2							;decrementa a 2 veces
		ld		(y_serp),a
		jp		termina_secuencia_color

baja_cursor:								;comprueva si lo puede bajar
	
		ld		a,(y_serp)
 		cp		22
 		jp		nz,lo_baja
 		jp		termina_secuencia_color	

lo_baja:									;lo baja porque es posbile

[5]		halt								;espera hasta el vblank 5 veces

		xor		a							;efecto de movimiento
		call	efecto_sonido
		
		ld		a,(y_serp)
		ld		h,10
		ld		l,a
		call	LOCATE
		ld		hl,nada
		call	lee_pinta_una
				
		ld		a,(y_serp)
		add		2					;incrementa a 2 veces
		ld		(y_serp),a
		jp		termina_secuencia_color

limpia_sprites:

		ld		a,192
		ld		ix,atributos_sprite_general
				
		ld		(ix),a
		ld		(ix+4),a
		ld		(ix+8),a
		ld		(ix+12),a
		ld		(ix+16),a
		ld		(ix+20),a
		ld		(ix+24),a
		ld		(ix+28),a
		ld		(ix+32),a
		ld		(ix+36),a
		ld		(ix+40),a
		ld		(ix+44),a
				
		call	atributos_sprites
		
		ret
		
prepara_juego:
		
		call	limpia_sprites
		
		call	activa_mute												
		
		call	PREPARACION_SCREEN_2
		
		call	SPRITES_UNO
		
		call	DISSCR													;desconectamos la pantalla
		
		call	limpia_sprites
		
		ld		hl,tiles_1												;cargamos patrones
		ld		de,#0000
		call	depack_VRAM
		
		ld		hl,colores_1											;cargamos colores de patrones
		ld		de,#2000
		call	depack_VRAM

		ld		a,(idioma)
		cp		0
		jr.		z,instrucciones_en_castellano

instrucciones_en_ingles:

		ld		hl,instru_ingle											;instrucciones en castellano
		ld		de,#1800
		call	depack_VRAM
		jr.		esperando
		
instrucciones_en_castellano:

		ld		hl,instru_caste											;instrucciones en castellano
		ld		de,#1800
		call	depack_VRAM
		
esperando:
		
		call	ENASCR													;conectamos la pantalla
		ld		a,(stick_a_usar)
		CALL	ONSTRIG
		cp		0
		jp		z,esperando
		
		call	DISSCR		
		ld		hl,blanco												;tiles de base de pantalla
		ld		de,#1820
		call	depack_VRAM
		
		ld		hl,marcador												;carga el marcador
		ld		de,#1800
		call	depack_VRAM
		CALL	ENASCR
		
		ld		a,192
		ld		(posicion_del_punto_centenas),a
		ld		(posicion_del_punto_decenas),a
		ld		(posicion_del_punto_millares),a
		ld		(posicion_del_punto_unidades),a
		
		ld		a,6
		ld		(vidas_prota),a
		
		ld		a,1
		ld		(ESTADO_MUSICA),a
		
		xor		a
		ld		(score),a

bloque_sanctuary_1:
		
		call	pantalla_en_blanco
		
		ld		a,(idioma)												;anunciamos sanctuary 1
		cp		0
		jr.		z,bloque_sanctuary_1_esp
		ld		hl,sanctuary_1
		jr.		bloque_sanctuary_1_cont

bloque_sanctuary_1_esp:

		ld		hl,sanctuario_1

bloque_sanctuary_1_cont:
		
		call	anunciamos_el_santuario_correspondiente

		;		coordenadas prota
		ld		a,232						;define variables
		ld		(px),a
		ld		(px_salida),a
		ld		a,24						
		ld		(py),a
		ld		(py_salida),a
		
		call	variables_iguales
				
		;		coordenadas serpientes
		
		ld		iy,variables_serpiente_1
		ld		a,152
		ld		(iy),a
		ld		a,167
		ld		(iy+1),a
		xor	a
		ld		(iy+2),a
		ld		(iy+3),a
		ld		a,8
		ld		(iy+4),a
		ld		(iy+5),a
		xor		a
		ld		(iy+6),a
		ld		a,1
		ld		(iy+7),a
		ld		a,255
		ld		(iy+8),a
				
		ld		a,1
		ld		(serp1),a
		
		;		otras variables
		ld		a,1
		ld		(fase_en_la_que_esta),a
		ld		hl,125
		ld		(posicion_puerta),hl
		
		ld		hl,200
		ld		(clock),hl						
		call	rutina_de_esperar_un_rato

		call	activa_musica_fases										;inicia el reproductor de PT3
		
		ld		hl,fase_1												;cargamos sanctuary 1 en ram
		ld		de,buffer_colisiones
		call	depack
		
		call	copiamos_en_pantalla_lo_de_memoria

		call 	gran_rutina												;vamos a la rutina de movimientos general
		
		jr.		repite_fase
								
bloque_sanctuary_2:
		
		call	pantalla_en_blanco
		
		ld		a,(idioma)												;anunciamos sanctuary 1
		cp		0
		jr.		z,bloque_sanctuary_2_esp
		ld		hl,sanctuary_2
		jr.		bloque_sanctuary_2_cont

bloque_sanctuary_2_esp:

		ld		hl,sanctuario_2

bloque_sanctuary_2_cont:
		
		call	anunciamos_el_santuario_correspondiente

		;		coordenadas prota
		ld		a,208						;define variables
		ld		(px),a
		ld		(px_salida),a
		ld		a,167						
		ld		(py),a
		ld		(py_salida),a
		
		call	variables_iguales
				
		;		coordenadas serpientes
		
		ld		iy,variables_serpiente_1
		ld		a,64
		ld		(iy),a
		ld		a,167
		ld		(iy+1),a
		xor	a
		ld		(iy+2),a
		ld		(iy+3),a
		ld		a,8
		ld		(iy+4),a
		ld		(iy+5),a
		xor		a
		ld		(iy+6),a
		ld		a,1
		ld		(iy+7),a
		ld		a,255
		ld		(iy+8),a
		
		ld		iy,variables_serpiente_2
		ld		a,152
		ld		(iy),a
		ld		a,143
		ld		(iy+1),a
		ld		(iy+2),a
		ld		a,255
		ld		(iy+8),a
		ld		a,15
		ld		(iy+5),a
		ld		a,10
		ld		(iy+4),a
		ld		a,2
		ld		(iy+7),a
		
		ld		a,1
		ld		(serp1),a
		ld		(serp2),a
		
		;		otras variables
		ld		a,2
		ld		(fase_en_la_que_esta),a
		ld		hl,698
		ld		(posicion_puerta),hl
		
		ld		hl,200
		ld		(clock),hl						
		call	rutina_de_esperar_un_rato

		call	activa_musica_fases										;inicia el reproductor de PT3
		
		ld		hl,fase_2												;cargamos sanctuary 1 en ram
		ld		de,buffer_colisiones
		call	depack
		
		call	copiamos_en_pantalla_lo_de_memoria

		call 	gran_rutina												;vamos a la rutina de movimientos general
		
		jr.		repite_fase
		
bloque_sanctuary_3:
		
		call	pantalla_en_blanco
		
		ld		a,(idioma)												;anunciamos sanctuary 3
		cp		0
		jr.		z,bloque_sanctuary_3_esp
		ld		hl,sanctuary_3
		jr.		bloque_sanctuary_3_cont

bloque_sanctuary_3_esp:

		ld		hl,sanctuario_3

bloque_sanctuary_3_cont:

		call	anunciamos_el_santuario_correspondiente

		;		variables coordenadas prota
		
		ld		a,16						;define variables
		ld		(px),a
		ld		(px_salida),a
		ld		a,64						
		ld		(py),a
		ld		(py_salida),a
		
		call	variables_iguales
		
		;variables coordenadas serpientes
		
		ld		iy,variables_serpiente_1
		
		ld		a,168
		ld		(iy+1),a
		ld		a,176
		ld		(iy),a
		ld		(iy+2),a
		ld		a,255
		ld		(iy+8),a
		ld		a,5
		ld		(iy+5),a
		ld		a,1
		ld		(iy+7),a
		ld		a,8
		ld		(iy+4),a
				
		ld		a,1	
		ld		(serp1),a
		
		;		otras variables
			
		ld		a,3
		ld		(fase_en_la_que_esta),a
		ld		hl,258
		ld		(posicion_puerta),hl

		ld		hl,200
		ld		(clock),hl						
		call	rutina_de_esperar_un_rato
		
		call	activa_musica_fases
		
		ld		hl,fase_3												;cargamos sanctuary 3 en ram
		ld		de,buffer_colisiones
		call	depack
		
		call	copiamos_en_pantalla_lo_de_memoria

		call 	gran_rutina												;vamos a la rutina de movimientos general
		
		jr.		repite_fase

bloque_sanctuary_4:
		
		call	pantalla_en_blanco
		
		ld		a,(idioma)												;anunciamos sanctuary 4
		cp		0
		jr.		z,bloque_sanctuary_4_esp
		ld		hl,sanctuary_4
		jr.		bloque_sanctuary_4_cont

bloque_sanctuary_4_esp:

		ld		hl,sanctuario_4

bloque_sanctuary_4_cont:

		call	anunciamos_el_santuario_correspondiente

		;		variables coordenadas prota
		
		ld		a,168													;define variables
		ld		(px),a
		ld		(px_salida),a
		ld		a,168						
		ld		(py),a
		ld		(py_salida),a
		
		call	variables_iguales
		
		;variables coordenadas serpientes
		
		ld		iy,variables_serpiente_1
		
		ld		a,168
		ld		(iy+1),a
		ld		a,96
		ld		(iy),a
		ld		(iy+2),a
		ld		a,255
		ld		(iy+8),a
		ld		a,5
		ld		(iy+5),a
		ld		a,1
		ld		(iy+7),a
		ld		a,8
		ld		(iy+4),a
		
		ld		iy,variables_serpiente_2
		
		ld		a,16
		ld		(iy+1),a
		ld		a,120
		ld		(iy),a
		ld		a,1
		ld		(iy+2),a
		ld		a,255
		ld		(iy+8),a
		ld		a,14
		ld		(iy+5),a
		ld		a,2
		ld		(iy+7),a
		ld		a,8
		ld		(iy+4),a		
		
		ld		a,1	
		ld		(serp1),a
		ld		(serp2),a
		
		;		otras variables
		
		ld		a,4
		ld		(fase_en_la_que_esta),a
		ld		hl,693
		ld		(posicion_puerta),hl

		ld		hl,200
		ld		(clock),hl						
		call	rutina_de_esperar_un_rato
		
		call	activa_musica_fases
		
		ld		hl,fase_4												;cargamos sanctuary 4 en ram
		ld		de,buffer_colisiones
		call	depack
		
		call	copiamos_en_pantalla_lo_de_memoria

		call 	gran_rutina												;vamos a la rutina de movimientos general
		
		jr.		repite_fase

bloque_sanctuary_5:
		
		call	pantalla_en_blanco
		
		ld		a,(idioma)												;anunciamos sanctuary 5
		cp		0
		jr.		z,bloque_sanctuary_5_esp
		ld		hl,sanctuary_5
		jr.		bloque_sanctuary_5_cont

bloque_sanctuary_5_esp:

		ld		hl,sanctuario_5

bloque_sanctuary_5_cont:
											;anunciamos sanctuary 5
		call	anunciamos_el_santuario_correspondiente

		;		coordenadas prota
		
		ld		a,120													;define variables
		ld		(px),a
		ld		(px_salida),a
		ld		a,24						
		ld		(py),a
		ld		(py_salida),a
		
		call	variables_iguales
		
		;		coordenadas serpientes
		
		ld		iy,variables_serpiente_1
		ld		a,120
		ld		(iy),a
		ld		a,168
		ld		(iy+1),a
		xor	a
		ld		(iy+2),a
		ld		(iy+3),a
		ld		a,8
		ld		(iy+4),a
		ld		(iy+5),a
		xor		a
		ld		(iy+6),a
		ld		a,1
		ld		(iy+7),a
		ld		a,255
		ld		(iy+8),a
				
		ld		a,1
		ld		(serp1),a
						
		;		otras variables
		
		ld		hl,210
		ld		(posicion_escalera),hl
		ld		hl,82
		ld		(limite_escalera),hl
		ld		a,5
		ld		(fase_en_la_que_esta),a
		ld		hl,111
		ld		(posicion_puerta),hl
		
		ld		hl,200
		ld		(clock),hl						
		call	rutina_de_esperar_un_rato
		
		call	activa_musica_fases

		ld		hl,fase_5					;cargamos sanctuary 1 en ram
		ld		de,buffer_colisiones
		call	depack
		
		call	copiamos_en_pantalla_lo_de_memoria

		call 	gran_rutina					;vamos a la rutina de movimientos general
		
		jr.		repite_fase

bloque_sanctuary_6:
		
		call	pantalla_en_blanco
		
		ld		a,(idioma)												;anunciamos sanctuary 6
		cp		0
		jr.		z,bloque_sanctuary_6_esp
		ld		hl,sanctuary_6
		jr.		bloque_sanctuary_6_cont

bloque_sanctuary_6_esp:

		ld		hl,sanctuario_6

bloque_sanctuary_6_cont:

		call	anunciamos_el_santuario_correspondiente

		;		coordenadas prota

		ld		a,232						;define variables
		ld		(px),a
		ld		(px_salida),a
		ld		a,24						
		ld		(py),a
		ld		(py_salida),a
		
		call	variables_iguales
		
		;		coordenadas serpientes
		
		ld		iy,variables_serpiente_1
		ld		a,200
		ld		(iy),a
		ld		a,56
		ld		(iy+1),a
		xor	a
		ld		(iy+2),a
		ld		(iy+3),a
		ld		a,8
		ld		(iy+4),a
		ld		(iy+5),a
		xor		a
		ld		(iy+6),a
		ld		a,2
		ld		(iy+7),a
		ld		a,255
		ld		(iy+8),a
		
		ld		iy,variables_serpiente_2
		ld		a,120
		ld		(iy),a
		ld		a,80
		ld		(iy+1),a
		xor	a
		ld		(iy+2),a
		ld		(iy+3),a
		ld		a,14
		ld		(iy+4),a
		ld		(iy+5),a
		xor		a
		ld		(iy+6),a
		ld		a,3
		ld		(iy+7),a
		ld		a,255
		ld		(iy+8),a
		
		ld		iy,variables_serpiente_3
		ld		a,104
		ld		(iy),a
		ld		a,144
		ld		(iy+1),a
		xor	a
		ld		(iy+2),a
		ld		(iy+3),a
		ld		a,2
		ld		(iy+4),a
		ld		(iy+5),a
		xor		a
		ld		(iy+6),a
		ld		a,1
		ld		(iy+7),a
		ld		a,255
		ld		(iy+8),a
		
				
		ld		a,1
		ld		(serp1),a
		ld		(serp2),a
		ld		(serp3),a
						
		;		otras variables
		
		ld		hl,207
		ld		(posicion_escalera),hl
		ld		hl,79
		ld		(limite_escalera),hl
		ld		a,6
		ld		(fase_en_la_que_esta),a
		ld		hl,125
		ld		(posicion_puerta),hl
					
		ld		hl,200
		ld		(clock),hl						
		call	rutina_de_esperar_un_rato
		
		call	activa_musica_fases
		
		ld		hl,fase_6												;cargamos sanctuary 6 en ram
		ld		de,buffer_colisiones
		call	depack
		
		call	copiamos_en_pantalla_lo_de_memoria

		call 	gran_rutina												;vamos a la rutina de movimientos general
		
		jr.		repite_fase

bloque_sanctuary_7:
		
		call	pantalla_en_blanco
		
		ld		a,(idioma)												;anunciamos sanctuary 7
		cp		0
		jr.		z,bloque_sanctuary_7_esp
		ld		hl,sanctuary_7
		jr.		bloque_sanctuary_7_cont

bloque_sanctuary_7_esp:

		ld		hl,sanctuario_7

bloque_sanctuary_7_cont:

		call	anunciamos_el_santuario_correspondiente

		call	SPRITES_DOS
		
		;		coordenadas prota

		ld		a,120													;define variables
		ld		(px),a
		ld		(px_salida),a
		ld		a,24						
		ld		(py),a
		ld		(py_salida),a
		
		call	variables_iguales
		
		;		coordenadas bombero
		
		ld		iy,bombero_control
		ld		a,120
		ld		(iy),a
		ld		a,24
		ld		(iy+1),a
		ld		a,2
		ld		(iy+2),a
		ld		a,150
		ld		(iy+3),a
		ld		a,10
		ld		(iy+4),a
		xor		a
		ld		(iy+5),a
		ld		(iy+6),a
		ld		(iy+7),a
		ld		(iy+10),a
		ld		a,200
		ld		(iy+8),a
		ld		a,1
		ld		(iy+9),a
								
		;		otras variables
		
		ld		hl,687
		ld		(posicion_escalera),hl
		ld		hl,559
		ld		(limite_escalera),hl
		ld		a,7
		ld		(fase_en_la_que_esta),a
		ld		hl,111
		ld		(posicion_puerta),hl
		ld		a,1
		ld		(bombero_1),a
					
		ld		hl,200
		ld		(clock),hl						
		call	rutina_de_esperar_un_rato
		
		call	activa_musica_fases

		ld		hl,fase_7					;cargamos sanctuary 1 en ram
		ld		de,buffer_colisiones
		call	depack
		
		call	copiamos_en_pantalla_lo_de_memoria

		call 	gran_rutina					;vamos a la rutina de movimientos general
		
		jr.		repite_fase

bloque_sanctuary_8:
		
		call	pantalla_en_blanco
		
		ld		a,(idioma)												;anunciamos sanctuary 8
		cp		0
		jr.		z,bloque_sanctuary_8_esp
		ld		hl,sanctuary_8
		jr.		bloque_sanctuary_8_cont

bloque_sanctuary_8_esp:

		ld		hl,sanctuario_8

bloque_sanctuary_8_cont:

		call	anunciamos_el_santuario_correspondiente
		
		call	SPRITES_DOS
		
		;		coordenadas prota

		ld		a,16													;define variables
		ld		(px),a
		ld		(px_salida),a
		ld		a,24						
		ld		(py),a
		ld		(py_salida),a
		
		call	variables_iguales
		
		;		coordenadas bombero
		
		ld		iy,bombero_control
		ld		a,16
		ld		(iy),a
		ld		a,24
		ld		(iy+1),a
		ld		a,2
		ld		(iy+2),a
		ld		a,150
		ld		(iy+3),a
		ld		a,10
		ld		(iy+4),a
		xor		a
		ld		(iy+5),a
		ld		(iy+6),a
		ld		(iy+7),a
		ld		(iy+10),a
		ld		a,200
		ld		(iy+8),a
		ld		a,1
		ld		(iy+9),a
								
		;		otras variables
		
		ld		hl,676
		ld		(posicion_escalera),hl
		ld		hl,548
		ld		(limite_escalera),hl
		ld		a,8
		ld		(fase_en_la_que_esta),a
		ld		hl,98
		ld		(posicion_puerta),hl
		ld		a,1
		ld		(bombero_1),a
					
		ld		hl,200
		ld		(clock),hl						
		call	rutina_de_esperar_un_rato
		
		call	activa_musica_fases

		ld		hl,fase_8												;cargamos sanctuary 8 en ram
		ld		de,buffer_colisiones
		call	depack
		
		call	copiamos_en_pantalla_lo_de_memoria

		call 	gran_rutina												;vamos a la rutina de movimientos general
		
		jr.		repite_fase

bloque_sanctuary_9:
		
		call	pantalla_en_blanco
		
		ld		a,(idioma)												;anunciamos sanctuary 9
		cp		0
		jr.		z,bloque_sanctuary_9_esp
		ld		hl,sanctuary_9
		jr.		bloque_sanctuary_9_cont

bloque_sanctuary_9_esp:

		ld		hl,sanctuario_9

bloque_sanctuary_9_cont:

		call	anunciamos_el_santuario_correspondiente

		call	SPRITES_UNO
		
		;		coordenadas prota

		ld		a,106													;define variables
		ld		(px),a
		ld		(px_salida),a
		ld		a,168						
		ld		(py),a
		ld		(py_salida),a
		
		call	variables_iguales
		
		;		coordenadas serpientes
		
		ld		iy,variables_serpiente_1
		ld		a,120
		ld		(iy),a
		ld		(iy+1),a
		xor	a
		ld		(iy+2),a
		ld		(iy+3),a
		ld		a,8
		ld		(iy+4),a
		ld		(iy+5),a
		xor		a
		ld		(iy+6),a
		ld		a,2
		ld		(iy+7),a
		ld		a,255
		ld		(iy+8),a
		
		ld		a,1
		ld		(serp1),a
								
		;		otras variables
		
		ld		hl,221
		ld		(posicion_escalera),hl
		ld		hl,93
		ld		(limite_escalera),hl
		ld		a,9
		ld		(fase_en_la_que_esta),a
		ld		hl,685
		ld		(posicion_puerta),hl
							
		ld		hl,200
		ld		(clock),hl						
		call	rutina_de_esperar_un_rato
		
		call	activa_musica_fases

		ld		hl,fase_9					;cargamos sanctuary 1 en ram
		ld		de,buffer_colisiones
		call	depack
		
		call	copiamos_en_pantalla_lo_de_memoria

		call 	gran_rutina					;vamos a la rutina de movimientos general
		
		jr.		repite_fase

bloque_sanctuary_10:
		
		call	pantalla_en_blanco
		
		ld		a,(idioma)												;anunciamos sanctuary 10
		cp		0
		jr.		z,bloque_sanctuary_10_esp
		ld		hl,sanctuary_10
		jr.		bloque_sanctuary_10_cont

bloque_sanctuary_10_esp:

		ld		hl,sanctuario_10

bloque_sanctuary_10_cont:

		call	anunciamos_el_santuario_correspondiente

		call	SPRITES_DOS
		
		;		coordenadas prota

		ld		a,216													;define variables
		ld		(px),a
		ld		(px_salida),a
		ld		a,24						
		ld		(py),a
		ld		(py_salida),a
		
		call	variables_iguales
		
		;		coordenadas bombero
		
		ld		iy,bombero_control
		ld		a,216
		ld		(iy),a
		ld		a,24
		ld		(iy+1),a
		ld		a,2
		ld		(iy+2),a
		ld		a,150
		ld		(iy+3),a
		ld		a,10
		ld		(iy+4),a
		xor		a
		ld		(iy+5),a
		ld		(iy+6),a
		ld		(iy+7),a
		ld		(iy+10),a
		ld		a,200
		ld		(iy+8),a
		ld		a,4
		ld		(iy+9),a
								
		;		otras variables
		
		ld		hl,221
		ld		(posicion_escalera),hl
		ld		hl,93
		ld		(limite_escalera),hl
		ld		a,10
		ld		(fase_en_la_que_esta),a
		ld		hl,122
		ld		(posicion_puerta),hl
		xor		a
		ld		(vision_estado),a
		ld		a,1
		ld		(bombero_1),a
							
		ld		hl,200
		ld		(clock),hl						
		call	rutina_de_esperar_un_rato
		
		call	activa_musica_fases

		ld		hl,fase_10												;cargamos sanctuary 10 en ram
		ld		de,buffer_colisiones
		call	depack
		
		call	pantalla_en_blanco

		ld		a,93
		ld		[#eeee],a
		ld		hl,#eeee												;pinta el mando de la luz
		ld		de,#19c4
		ld		bc,1
		call	GRABAVRAM

		call 	gran_rutina												;vamos a la rutina de movimientos general
		
		jr.		repite_fase
		
FINAL_TEMPLO:
		
		call	DISSCR
		ld		hl,FINAL												;cargamos FINAL en ram
		ld		de,buffer_colisiones
		call	depack
		
		call	copiamos_en_pantalla_lo_de_memoria
		ld		a,(idioma)
		cp		0
		jr.		nz,FINAL_TEMPLO_CONTINUA
		
		ld		hl,lo_has_logrado
		ld		de,#1880
		ld		bc,31
		call	GRABAVRAM
		
		ld		hl,felicidades
		ld		de,#1aa1
		ld		bc,30
		call	GRABAVRAM
		
FINAL_TEMPLO_CONTINUA:

		call	ENASCR
		;		coordenadas prota

		ld		a,112													;define variables
		ld		(px),a
		ld		(py),a

		ld		a,12
		ld		(fase_en_la_que_esta),a
		
		ld		a,(RG1SAV)
		or		00000001b												;modo sprites ampliados
		ld		b,a
		ld		c,1
		call	WRTVDP													;lo escribe en el registro 1 del VDP
		
		call	activa_musica_menu
		
		ld		ix,atributos_sprite_general
		
		ld		a,50
		ld		(petisoy),a
		ld		a,112
		ld		(petisox),a
		ld		a,10
		ld		(espera_petiso),a
		ld		(espera_petiso_resta_2),a
		ld		(espera_petiso_resta),a
		
		call	SPRITES_PETISOS
		
animacion_final:
		
		
		
		ld		a,(py)
		ld		(ix+16),a
		ld		(ix+20),a
		ld		a,(px)
		ld		(ix+17),a
		ld		(ix+21),a
		ld		a,51*4
		ld		(ix+18),a
		ld		a,52*4
		ld		(ix+22),a
		ld		a,1
		ld		(ix+19),a
		ld		a,8
		ld		(ix+23),a
		
		call	petiso_activity	
			
		call	atributos_sprites
		
		ld		a,53*4
		ld		(ix+18),a
		ld		a,54*4
		ld		(ix+22),a
		
		call	atributos_sprites
		
		ld		a,(stick_a_usar)
		CALL	ONSTRIG
		cp		0
		jp		z,animacion_final
			
		jr.		MENU
		
pantalla_en_blanco:
		
		call	DISSCR
		ld		hl,blanco												;tiles de base de pantalla
		ld		de,#1820
		call	depack_VRAM
		
		ld		hl,trofeos												;carga objetos
		ld		de,#1818
		call	depack_VRAM
		call	ENASCR
		ret

copiamos_en_pantalla_lo_de_memoria:

		ld		hl,buffer_colisiones									;copia en vram para que lo vea el jugador
		ld		de,#1820
		ld		bc,736
		jr.		GRABAVRAM

anunciamos_el_santuario_correspondiente:

		ld		de,#198a
		ld		bc,12
		jr.		GRABAVRAM
		
variables_iguales:

		ld		a,8
		ld		(color_prota),a
		ld		a,1
		ld		(color_lineas_prota),a
		ld		(muerto),a
		ld		(grifo_estado),a
		ld		(vision_estado),a
		ld		(puede_cambiar_de_direccion),a

		xor		a
		ld		(estado_prota),a
		ld		(pasamos_la_fase),a
		ld		(gasolina),a
		ld		(mechero),a
		ld		(ya_ha_cambiado_puerta),a
		ld		(tiene_objeto),a
		ld		(pasos_de_salto),a
		ld		(estado_de_salto),a
		ld		(momento_lanzamiento),a
		ld		(escalera_activada),a
		ld		(serp1),a
		ld		(serp2),a
		ld		(serp3),a
		ld		(serp4),a
		ld		(bombero_1),a
		ld		(colision_bombero_prota_real),a
		ld		(colision_cuchillo_serp_real),a
		
		ld		(dir_cuchillo),a
		ld		(cx),a
		ld		(cy),a

		ld		a,5
		ld		(cont_no_salta_dos_seguidas),a
		ld		(contador_poses_lanzar),a
		ld		a,50
		ld		(contador_escalera),a
		
		ret

SPRITES_PETISOS:

		ld		hl,sprites_pet											;cargamos petisos
		ld		de,#3800
		ld		bc,256
		call	GRABAVRAM
		
		ret
		
SPRITES_UNO:

		call	DISSCR
		ld		hl,sprites												;carga sprites general
		ld		de,#3800
		call	depack_VRAM
		call	ENASCR
		
		ret

SPRITES_DOS:

		ld		hl,sprites2												;cargamos sprites bombero parte 1
		ld		de,#3b20
		ld		bc,256
		call	GRABAVRAM

		ld		hl,sprites3												;cargamos sprites bombero parte 2
		ld		de,#3da0
		ld		bc,192
		call	GRABAVRAM
		
		ld		hl,sprites4												;cargamos sprites bombero parte 3
		ld		de,#3ee0
		ld		bc,256
		call	GRABAVRAM
		ret

SPRITES_BOMBA:

		ld		hl,sprites5				
		ld		de,#3800
		ld		bc,32
		call	GRABAVRAM
		
		ld		hl,sprites6			
		ld		de,#3860
		ld		bc,32
		call	GRABAVRAM
		
		ld		hl,sprites7				
		ld		de,#38C0
		ld		bc,32
		call	GRABAVRAM
		
		ld		hl,sprites8				
		ld		de,#3920
		ld		bc,32
		call	GRABAVRAM
		
		ret
		
SPRITES_CUCHILLO:

		ld		hl,sprites9				;anunciamos sanctuary 1
		ld		de,#3800
		ld		bc,32
		call	GRABAVRAM
		
		ld		hl,sprites10				
		ld		de,#3860
		ld		bc,32
		call	GRABAVRAM
		
		ld		hl,sprites11			
		ld		de,#38C0
		ld		bc,32
		call	GRABAVRAM
		
		ld		hl,sprites12				
		ld		de,#3920
		ld		bc,32
		call	GRABAVRAM
		
		ret

SPRITES_PROTA_NORMAL:

		ld		hl,sprites13				;anunciamos sanctuary 1
		ld		de,#3800
		ld		bc,32
		call	GRABAVRAM
		
		ld		hl,sprites14				
		ld		de,#3860
		ld		bc,32
		call	GRABAVRAM
		
		ld		hl,sprites15			
		ld		de,#38C0
		ld		bc,32
		call	GRABAVRAM
		
		ld		hl,sprites16				
		ld		de,#3920
		ld		bc,32
		call	GRABAVRAM
		
		ret
								
string_de_espera:

		ld		a,(stick_a_usar)
		CALL	ONSTRIG
		cp		0
		jp		z,string_de_espera
		
		ret

activa_mute:
	
		di
		
		ld		hl,MUTE-99													;SILENCIA LA MUSICA
		call	PT3_INIT
		
		ei
		
		jr. musica_con_bucle
		
activa_musica_fases:
		
		call	activa_mute
		
		ld		A,(ESTADO_MUSICA)
		cp		0
		ret		z
	
		di
		
		ld		hl,SAXOLO-99												;SILENCIA LA MUSICA
		call	PT3_INIT
		
		ei
		
		jr.		musica_con_bucle

activa_musica_menu:
			
		di
		
		ld		hl,SAXOLO-99												;SILENCIA LA MUSICA
		call	PT3_INIT
		
		ei
		
		jr.		musica_con_bucle
		
activa_musica_muerto:
	
		di
		
		ld		hl,MUERTO-99											;MUSICA DE MUERTE
		call	PT3_INIT
		
		ei
		
		jr.		musica_sin_bucle

activa_musica_entre_fases:
	
		di
		
		ld		hl,ENTRE_FASES-99										;MUSICA ENTRE FASES
		call	PT3_INIT
		
		ei
		
		jr.		musica_sin_bucle

rutina_de_esperar_un_rato:

		halt
		ld		hl,(clock)
		ld		bc,1		
		sbc		hl,bc
		ld		(clock),hl
		jr		nz,rutina_de_esperar_un_rato
		
		ret

PREPARACION_SCREEN_2:

		ld		a,2
		call	SCREENX
		ld		a,(RG1SAV)
		or		00000010b					;modo sprites a 16x16
		and		11111110b					;modo sprites no ampliados
		ld		b,a
		ld		c,1
		call	WRTVDP						;lo escribe en el registro 1 del VDP
		
		RET
		
gran_rutina:

		halt								;espera a la interrupcion vblank y sincroniza toda la acción
		call	pulsa_una_tecla
		call	atributos_sprites
		call	revisa_escalera
		call	revisa_bombero
		call	grifo_bombero
		call	estado_en_que_se_encuentra
		call	apaga_los_chorros
		call	movimiento_forzado_en_puertas
		call	vigila_si_cierra_puertas
		call	mueve_prota
		call	usa_objeto_o_salta
		call	rutina_cuchillo_volador
		call	coge_algun_objeto
		call	pose_si_esta_parado
		call	comprueba_estado_de_explosion
		call	actualiza_atributos_sprite
		call	colision_bombero_prota
		call	colisiones_serpientes_cuchillos
		call	colisiones_serpientes_prota_1
		call	movimiento_serpientes
		call	actualiza_la_puerta
		call	puntuacion_vidas_fase
		
		ld		a,(pasamos_la_fase)
		cp		0
		jr.		nz,animacion_entre_fases
		
		ld		a,(muerto)
		cp		0
		jr.		z,repite_fase
		
		jp		gran_rutina

vigila_si_cierra_puertas:
		
		ld		a,(puede_cambiar_de_direccion)
		cp		1
		ret		z
		
		call	dieciseis_quince
		call	get_bloque_en_X_Y
		
		cp		117
		jr.		z,recoloca_puerta_amarilla_izquierda
		cp		118
		jr.		z,recoloca_puerta_azul_izquierda
		
		call	menos_uno_quince
		call	get_bloque_en_X_Y
		
		cp		117
		jr.		z,recoloca_puerta_amarilla_derecha
		cp		118
		jr.		z,recoloca_puerta_azul_derecha	
		
		ret
			
movimiento_forzado_en_puertas:

		ld		a,(puede_cambiar_de_direccion)
		cp		1
		ret		z
		
		ld		a,13													;efecto sonoro de abrir grifo
		call	efecto_sonido
			
		ld		a,(dir_prota)
		cp		0														;va a la derecha forzado
		jr.		z,(mueve_derecha_prota)
		cp		1														;va a la izquierda forzado
		jr.		z,(mueve_izquierda_prota)

recoloca_puerta_amarilla_derecha:
				
		ld		a,(dir_prota)
		cp		0
		ret		nz
		
		ld		a,1
		ld		(puede_cambiar_de_direccion),a
		
		call	menos_uno_quince
		call	get_bloque_en_X_Y
		ld		a,113
		ld		[hl],a
								
		call	menos_uno_quince
		call	get_bloque_en_X_Y_paravram
		
		ld		a,113
		call	pinta_en_pantalla
		
		call	menos_uno_dos
		call	get_bloque_en_X_Y
		ld		a,113
		ld		[hl],a
								
		call	menos_uno_dos
		call	get_bloque_en_X_Y_paravram
		
		ld		a,113
		call	pinta_en_pantalla
		
		ret
		
recoloca_puerta_amarilla_izquierda:
		
		ld		a,(dir_prota)
		cp		1
		ret		nz
		
		ld		a,1
		ld		(puede_cambiar_de_direccion),a
		
		call	dieciseis_quince
		call	get_bloque_en_X_Y
		ld		a,114
		ld		[hl],a
								
		call	dieciseis_quince
		call	get_bloque_en_X_Y_paravram
		
		ld		a,114
		call	pinta_en_pantalla
		
		call	dieciseis_dos
		call	get_bloque_en_X_Y
		ld		a,114
		ld		[hl],a
								
		call	dieciseis_dos
		call	get_bloque_en_X_Y_paravram
		
		ld		a,114
		call	pinta_en_pantalla
		
		ret
		
recoloca_puerta_azul_derecha:
		
		
		ld		a,(dir_prota)
		cp		0
		ret		nz
		
		ld		a,1
		ld		(puede_cambiar_de_direccion),a
		
		call	menos_uno_quince
		call	get_bloque_en_X_Y
		ld		a,116
		ld		[hl],a
								
		call	menos_uno_quince
		call	get_bloque_en_X_Y_paravram
		
		ld		a,116
		call	pinta_en_pantalla
		
		call	menos_uno_dos
		call	get_bloque_en_X_Y
		ld		a,116
		ld		[hl],a
								
		call	menos_uno_dos
		call	get_bloque_en_X_Y_paravram
		
		ld		a,116
		call	pinta_en_pantalla
		
		ret
		
recoloca_puerta_azul_izquierda:
		
		ld		a,(dir_prota)
		cp		1
		ret		nz
		
		ld		a,1
		ld		(puede_cambiar_de_direccion),a
		
		call	dieciseis_quince
		call	get_bloque_en_X_Y
		ld		a,115
		ld		[hl],a
								
		call	dieciseis_quince
		call	get_bloque_en_X_Y_paravram
		
		ld		a,115
		call	pinta_en_pantalla
		
		call	dieciseis_dos
		call	get_bloque_en_X_Y
		ld		a,115
		ld		[hl],a
								
		call	dieciseis_dos
		call	get_bloque_en_X_Y_paravram
		
		ld		a,115
		call	pinta_en_pantalla
		
		ret
		
		
grifo_bombero:

		ld		iy,bombero_control
		
		ld		a,(iy)													;comprobamos lo que tiene donde está					
		ld		d,a
		ld		a,(iy+1)
		add		10
		ld		e,a
		call	get_bloque_en_X_Y
		
		cp		119														;si el grifo ya está abierto, sigue la gran rutina
		ret		nz
		
		ld		a,(iy)													;para buffer y vram moviendo 0,10						
		ld		d,a
		ld		a,(iy+1)
		add		10
		ld		e,a
		call	get_bloque_en_X_Y
		ld		a,87
		ld		[hl],a
								
		ld		a,(iy)													;para buffer y vram moviendo 0,10						
		ld		d,a
		ld		a,(iy+1)
		add		10
		ld		e,a
		call	get_bloque_en_X_Y_paravram
		ld		a,87
		ld		[hl],a
		
		
		ld		a,87
		call	pinta_en_pantalla
		
		ld		a,10													;efecto sonoro de abrir grifo
		call	efecto_sonido
		
		ld		a,1														; da valor a la variable para dar por hecho que el grifo está abierto
		ld		(grifo_estado),a
		
		ret
		
revisa_bombero:

		ld		a,(bombero_1)											;si no está activo, vuelve a la gran rutina
		cp		0
		ret		z
						
		ld	    iy,bombero_control										;si no tiene orden de aparecer, reduce el tiempo y vuelve a la gran rutina
		ld		a,(iy+8)
		cp		0
		jr.		z,se_activa_el_bombero
		
		dec		a
		ld		(iy+8),a
		
		ret		
		
se_activa_el_bombero:

		ld		a,(iy+9)												;vuelve a darle un poco de retardo al personaje (esto es uno de los puntos que marca la velocidad del bombero)
		ld		(iy+8),a
		
		ld		a,(iy+11)												;si no está a cero, no puede ni subir ni bajar escaleras.
		cp		0
		jr.		nz,resta_y_camina
		
		ld		a,(iy)													;comprobamos lo que tiene donde está					
		ld		d,a
		ld		a,(iy+1)
		add		2
		ld		e,a
		call	get_bloque_en_X_Y
		
		cp		41														;si es escalera 1, va a decidir si sube o baja
		call	z,estamos_en_escalera

		cp		42														;si es escalera 2, va a decidir si sube o baja
		call	z,estamos_en_escalera
		
		ld		a,(iy+7)												;mira en qué estado está para ir a la rutina adecuada
		cp		0
		jr.		z,revisa_caida_bombero
		
		cp		1
		jr.		z,revisa_subida_bombero
		cp		2
		jr.		z,revisa_bajada_bombero

resta_y_camina:

		dec		a
		ld		(iy+11),a
		jr.		revisa_caida_bombero
		
revisa_subida_bombero:
				
		ld		a,(iy)													;comprobamos lo que tiene encima					
		ld		d,a
		ld		a,(iy+1)
		sub		2
		ld		e,a
		call	get_bloque_en_X_Y

		cp		42
		jr.		z,continua_rvb
		cp		41
		jr.		nz,sigue_andando

continua_rvb:
		
		ld		a,(iy)													;comprobamos si está centrado					
		dec		a
		ld		d,a
		ld		a,(iy+1)
		sub		2
		ld		e,a
		call	get_bloque_en_X_Y
		cp		41
		call	z,corrige_en_escalera_bombero
		cp		42
		call	z,corrige_en_escalera_bombero
		
		ld		a,(iy+1)												;sube por la coordenada y
		sub		2
		ld		(iy+1),a
		
		jr.		decide_paso_en_escalera
	
revisa_bajada_bombero:
				
		ld		a,(iy)													;comprobamos lo que tiene debajo de los pies					
		ld		d,a
		ld		a,(iy+1)
		add		17
		ld		e,a
		call	get_bloque_en_X_Y

		cp		42
		jr.		z,continua_rbb
		cp		73
		jr.		z,continua_rbb
		cp		74
		jr.		z,continua_rbb
		cp		41
		jr.		nz,sigue_andando

continua_rbb:
		
		ld		a,(iy)													;comprobamos si está centrado					
		dec		a
		ld		d,a
		ld		a,(iy+1)
		sub		2
		ld		e,a
		call	get_bloque_en_X_Y
		
		cp		41														;si no está centrado va a centrarse
		call	z,corrige_en_escalera_bombero
		
		cp		42														;si no está centrado va a centrarse
		call	z,corrige_en_escalera_bombero
		
		ld		a,(iy+1)												;baja por la variable y
		add		2
		ld		(iy+1),a
		
		jr.		decide_paso_en_escalera

corrige_en_escalera_bombero:

		ld		a,(iy)													;lo pone hacia la izquierda hasta que se centra
		sub		2
		ld		(iy),a
		
		ret
		
sigue_andando:

		xor		a														;da a la variable adecuada el valor de andando
		ld		(iy+7),a
		ld		a,15
		ld		(iy+11),a		
		jr.		revisa_caida_bombero

decide_paso_en_escalera:

		ld		a,(iy+5)												;decide el paso en el que está si no pasa por avanzar
		
		cp		0
		jr.		z,paso_uno_escaleras
		
		cp		1
		jr.		z,paso_dos_escaleras

paso_uno_escaleras:

		ld		a,1														;cambia el paso para la siguiente									
		ld		(iy+5),a
		
		ld		a,55*4													;define los sprites adecuados
		ld		b,a
		ld		a,49*4
		jr.		ultimas_variables_bombero
		
paso_dos_escaleras:

		xor		a														;cambia el paso para la siguiente
		ld		(iy+5),a
		
		ld		a,58*4													;define los sprites adecuados
		ld		b,a
		ld		a,56*4
		jr.		ultimas_variables_bombero
						
revisa_caida_bombero:
		
		call	hacia_donde_quiero_ir									;decide la variable para seguir al prota en las escaleras
			
		ld		a,(iy)													;comprobamos lo que tiene debajo de los pies	
		add		2											
		ld		d,a
		ld		a,(iy+1)
		add		17
		ld		e,a
		call	get_bloque_en_X_Y

		cp		41														;si es escalera irá a mirar la dirección ppara seguir como si nada
		jr.		z,define_direccion_bombero
		cp		42
		jr.		z,define_direccion_bombero

		cp		32
		jr.		c,define_direccion_bombero								;si hay muro vamos a ver la direccion para seguir como si nada

		ld		a,(iy)
		add		14														;comprobamos lo que tiene debajo de los pies en la parte derecha					
		ld		d,a
		ld		a,(iy+1)
		add		17
		ld		e,a
		call	get_bloque_en_X_Y
		
		cp		41														;si es escalera irá a mirar la dirección ppara seguir como si nada
		jr.		z,define_direccion_bombero
		cp		42
		jr.		z,define_direccion_bombero
		
		cp		32
		jr.		c,define_direccion_bombero								;si hay muro vamos a ver la direccion para seguir como si nada

		ld		a,(iy+1)												;cae dos pixeles
		add		2
		ld		(iy+1),a
		
		ld		ix,atributos_sprite_general
		
		ld		a,(ix+26)												;define los sprites
		ld		b,a
		ld		a,(ix+18)
		
		jr.		ultimas_variables_bombero
		
define_direccion_bombero:
		
		xor		a														;estado andando
		ld		(iy+7),a
		
		ld		a,(iy+6)
		cp		0
		jr.		z,va_hacia_la_derecha

va_hacia_la_izquierda:

		ld		a,(iy)													;comprobamos la que tiene a su izquierda
		add		2											
		ld		d,a
		ld		a,(iy+1)
		add		11
		ld		e,a
		call	get_bloque_en_X_Y
		
		cp		32														;si hay pared cambia la direccion
		jr.		c,cambia_la_direccion_bombero
		cp		113														;si hay muros de pinchos tambien
		jr.		z,cambia_la_direccion_bombero
		cp		115														
		jr.		z,cambia_la_direccion_bombero
		
		ld		a,(iy+2)												;va hacia la izquierda lo adecuado
		ld		b,a
		ld		a,(iy)
		sub		a,b
		
		ld		(iy),a
		
		ld		a,(iy+5)												;decide el paso que le toca
		cp		0
		jr.		z,paso_quieto_izquierda									

paso_movido_izquierda:
		
		xor		a														;cambia el paso para la siguiente
		ld		(iy+5),a
			
		ld		a,45*4													;da los sprites adecuados
		ld		b,a
		ld		a,31*4
		jr.		ultimas_variables_bombero
		
paso_quieto_izquierda:
		
		ld		a,1														;cambia el paso para la siguiente
		ld		(iy+5),a	
	
		ld		a,48*4													;da los sprites adecuados
		ld		b,a
		ld		a,46*4
		jr.		ultimas_variables_bombero

va_hacia_la_derecha:

		ld		a,(iy)													;comprobamos la que tiene a su derecha
		add		13											
		ld		d,a
		ld		a,(iy+1)
		add		11
		ld		e,a
		call	get_bloque_en_X_Y
		
		cp		32														;si hay pared cambia de dirección
		jr.		c,cambia_la_direccion_bombero
		cp		114														;si hay muros de pinchos tambien
		jr.		z,cambia_la_direccion_bombero
		cp		116														
		jr.		z,cambia_la_direccion_bombero
		ld		a,(iy+2)												;suma a x lo adecuado
		ld		b,a
		ld		a,(iy)
		add		a,b
		
		ld		(iy),a
		
		ld		a,(iy+5)												;mira el paso que le toca
		cp		0
		jr.		z,paso_quieto_derecha

paso_movido_derecha:

		xor		a														;cambia el paso para la siguiente
		ld		(iy+5),a
		
		ld		a,30*4													;define los sprites adecuados
		ld		b,a
		ld		a,28*4
		jr.		ultimas_variables_bombero
		
paso_quieto_derecha:

		ld		a,1														;cambia el paso para la siguiente
		ld		(iy+5),a

		ld		a,27*4													;define los sprites adecuados
		ld		b,a
		ld		a,25*4
		jr.		ultimas_variables_bombero

cambia_la_direccion_bombero:		

		ld		a,(iy+6)												;mira cual es la direccion actual para cambiarla
		cp		0
		jr.		z,cambia_a_izquierda

cambia_a_derecha:

		xor		a														;cambia a derecha
		ld		(iy+6),a
		
		ret
		
cambia_a_izquierda:

		ld		a,1														;cambia a izquierda
		ld		(iy+6),a
		
		ret

hacia_donde_quiero_ir:

		ld		a,(py)													;si prota está por encima querrá subir y si está por debajo querrá bajar
		sub		3
		ld		b,a
		ld		a,(iy+1)
		cp		b
		
		jr.		c,damos_valor_bajada_bombero
		
		ld		a,(py)													;si prota está por encima querrá subir y si está por debajo querrá bajar
		add		3
		ld		b,a
		ld		a,(iy+1)
		cp		b
		
		jr.		nc,damos_valor_subida_bombero
		
		xor		a
		ld		(iy+10),a
		ret
		
damos_valor_bajada_bombero:
				
		ld		a,2														; le damos valor a la variable adecuada de bajada
		ld		(iy+10),a
		
		ret

damos_valor_subida_bombero:

		ld		a,1														; le damos valor a la variable adecuada de subida
		ld		(iy+10),a
		
		ret

estamos_en_escalera:

		ld		a,(iy+10)
		ld		(iy+7),a
		
		ret
		
ultimas_variables_bombero:
		
		
		ld		ix,atributos_sprite_general
		
		ld		(ix+18),a												;patrones
		add		4
		ld		(ix+22),a
		ld		(ix+26),b
		
		ld		a,(iy+1)												;y
		ld		(ix+16),a
		sub		a,9
		ld		(ix+20),a
		add		a,16
		ld		(ix+24),a
		
		ld		a,(iy)													;x
		ld		(ix+17),a
		ld		(ix+21),a
		ld		(ix+25),a
				
		ld		a,1														;colores_1
		ld		(ix+19),a
		ld		a,9
		ld		(ix+23),a
		ld		a,14
		ld		(ix+27),a
		
		ret
		
revisa_escalera:

		ld		a,(escalera_activada)
		cp		0
		ret		z
		
		ld		a,(contador_escalera)
		dec		a
		ld		(contador_escalera),a
		ld		a,(contador_escalera)
		cp		0
		ret		nz
		
		ld		a,50
		ld		(contador_escalera),a

		ld		hl,(posicion_escalera)
		ld		de,buffer_colisiones
		add		hl,de													;hl=buffer_colisiones + posicion escalera
		ld		bc,32
		sbc		hl,bc
		ld		a,43
		ld		[hl],a
		inc		hl
		ld		a,44
		ld		[hl],a
		ld		bc,31
		adc		hl,bc		
		ld		a,41
		ld		[hl],a
		inc		hl
		ld		a,42
		ld		[hl],a
		
		ld		hl,(posicion_escalera)
		ld		a,43
		call	pinta_en_pantalla
		
		ld		hl,(posicion_escalera)
		inc		hl
		ld		a,44
		call	pinta_en_pantalla
		
		ld		hl,(posicion_escalera)
		ld		bc,32
		adc		hl,bc
		ld		a,41
		call	pinta_en_pantalla
		
		ld		hl,(posicion_escalera)
		ld		bc,33
		adc		hl,bc
		ld		a,42
		call	pinta_en_pantalla
		
		ld		a,12													;efecto de escalera_activada
		call	efecto_sonido	
		
		ld		a,(posicion_escalera)
		ld		b,a
		ld		a,(limite_escalera)
		cp		b
		jr.		z,(se_acabo_la_escalera)
		
		ld		a,(posicion_escalera)
		sub		32
		ld		(posicion_escalera),a
		
		ret

se_acabo_la_escalera:

		xor		a
		ld		(escalera_activada),a
		ret
		
pulsa_una_tecla:
		
		ld		a,6
		call	SNSMAT
		bit		5,a
		jr.		z,pausa_el_juego
		bit		6,a
		jr.		z,musica_off_on
		bit		7,a														;PARA HACER TRAMPA
		jr.		z,pasa_fase_con_trampa									;PARA HACER TRAMPA
		
		ld		a,7
		call	SNSMAT
		bit		1,a
		jr.		z,una_vida_menos
				
		ret

pasa_fase_con_trampa:													;PARA HACER TRAMPA

		call	activa_mute
		ld		a,1														;PARA HACER TRAMPA
		ld		(pasamos_la_fase),a										;PARA HACER TRAMPA
		ret
		
una_vida_menos:
		
		call	activa_mute
		
		ld		a,8														;efecto muerte
		call	efecto_sonido

		ld		a,(vidas_prota)
		dec		a
		ld		(vidas_prota),a
		
		jr.		repite_fase

musica_off_on:
		
		ld		a,(ESTADO_MUSICA)
		CP		0
		jr.		z,reconectamos_musica
		
		xor		a
		ld		(ESTADO_MUSICA),a
		
		call	activa_mute

rutina_de_espera_tras_la_musica:
		
		ld		a,100
		push	af
		
valor_anadido_2:
		
		ld		a,255
		
retardo_rutina_de_pausa_2:
		
		dec		a
		cp		0
		jr.		nz,retardo_rutina_de_pausa_2
		pop		af
		dec		a
		push	af
		cp		0
		jr.		nz,valor_anadido_2
		pop		af
		ret
		
reconectamos_musica:

		ld		a,1
		ld		(ESTADO_MUSICA),a
		
		call	activa_musica_fases					;inicia el reproductor de PT3
				
		jr.		rutina_de_espera_tras_la_musica
				
pausa_el_juego:

		call	activa_mute

		ld		hl,pause					;anunciamos pausa
		ld		de,#1ae2
		ld		bc,5
		call	GRABAVRAM
		
		ld		a,9						;efecto de pausa
		call	efecto_sonido	
		
		ld		a,100
		push	af
		
valor_anadido:
		
		ld		a,255
		
retardo_rutina_de_pausa:
		
		dec		a
		cp		0
		jr.		nz,retardo_rutina_de_pausa
		pop		af
		dec		a
		push	af
		cp		0
		jr.		nz,valor_anadido
		pop		af
		
rutina_de_pausa:
	
		ld		a,6
		call	SNSMAT
		bit		5,a
		jr.		Z,reconectamos
		jr. 	rutina_de_pausa

reconectamos:
		
		ld		hl,ladrillos			;recupera los ladrillos borrados
		ld		de,#1ae2
		ld		bc,5
		call	GRABAVRAM
		
		ld		a,9														;efecto de pausa
		call	efecto_sonido
		
		ld		a,100
		push	af
		
valor_anadido_1:
		
		ld		a,255
		
retardo_rutina_de_pausa_1:
		
		dec		a
		cp		0
		jr.		nz,retardo_rutina_de_pausa_1
		pop		af
		dec		a
		push	af
		cp		0
		jr.		nz,valor_anadido_1
		pop		af
		
		ld		a,(ESTADO_MUSICA)
		cp		1
		ret		nz
		
		call	activa_musica_fases										;conectamos las interrupciones
		
		ret
		
repite_fase:
		
		ld		ix,atributos_sprite_general
				
		call	limpia_sprites
		
		call	activa_musica_muerto
		call	puntuacion_vidas_fase
		call	SPRITES_UNO
		
		ld		a,(vidas_prota)
		cp		0
		jr.		z,termina_partida_mal
		
		ld		a,(fase_en_la_que_esta)
		cp		1
		jr.		z,bloque_sanctuary_1
		
		cp		2
		jr.		z,bloque_sanctuary_2
		
		cp		3
		jr.		z,bloque_sanctuary_3
		
		cp		4
		jr.		z,bloque_sanctuary_4
		
		cp		5
		jr.		z,bloque_sanctuary_5
		
		cp		6
		jr.		z,bloque_sanctuary_6
		
		cp		7
		jr.		z,bloque_sanctuary_7
		
		cp		8
		jr.		z,bloque_sanctuary_8
		
		cp		9
		jr.		z,bloque_sanctuary_9
		
		cp		10
		jr.		z,bloque_sanctuary_10
				
		cp		11
		jr.		z,FINAL_TEMPLO
		
		jr.		INICIA_MUSICA

termina_partida_mal:

		call	DISSCR	
		ld		hl,blanco												;tiles de base de pantalla
		ld		de,#1820
		call	depack_VRAM
		
		LD		a,(idioma)
		cp		0
		jr.		z,termina_en_castellano

termina_en_ingles:
		
		ld		hl,game_over											;anunciamos final malo
		ld		de,#198b
		ld		bc,10
		call	GRABAVRAM
		jr.		termina_partida_mal_continua
		
termina_en_castellano:
		
		ld		hl,se__acabo											;anunciamos final malo
		ld		de,#198b
		ld		bc,10
		call	GRABAVRAM

termina_partida_mal_continua:
		
		call	ENASCR
		call 	musica_sin_bucle
		
		ld		hl,GAME_OVER-99									;hl ahora vale la direccion donde se encuentra la cancion
		call	PT3_INIT												;inicia el reproductor de PT3
		
		ld		hl,750
		ld		(clock),hl
		
string_para_reiniciar_programa:

		halt
		ld		hl,(clock)
		ld		bc,1		
		sbc		hl,bc
		ld		(clock),hl
		jr.		z,inicio
		
		ld		a,(stick_a_usar)
		CALL	ONSTRIG
		cp		0
		jr.		z,string_para_reiniciar_programa

inicio:
		
		call	activa_musica_menu
		jr.		MENU

musica_sin_bucle:

		ld		a,[PT3_SETUP]											;musica sin bucle
		or		00000001b
		ld		[PT3_SETUP],a
		
		ret

musica_con_bucle:

		ld		a,[PT3_SETUP]											;musica CON bucle
		and		11111110b
		ld		[PT3_SETUP],a
		
		ret
		
colision_bombero_prota:
		
		ld		a,(bombero_1)											;si no está activo, no hay colision
		cp		0
		ret		z
		
		ld	    iy,bombero_control										

		ld		a,(iy+8)												;si no está a vista, no hay colision
		cp		0
		ret		nz

		
		call	coteja_colision_prota_bombero
		ld		a,(colision_bombero_prota_real)
		cp		0
		ret		z
		
		xor		a
		ld		(colision_bombero_prota_real),a		
		
		ld		ix,atributos_sprite_general
					
		ld		a,(iy+1)												;posiciones y
		dec		a
		ld		(ix),a
		ld		(ix+4),a
		inc		a
		ld		(ix+16),a
		sub		9
		ld		(ix+8),a
		add		16
		ld		(ix+20),a
		
		ld		a,(iy)													;patrones x
		sub		8
		ld		(ix+1),a
		ld		(ix+5),a
		add		13
		ld		(ix+17),a
		ld		(ix+9),a
		ld		(ix+21),a
				
		ld		a,59*4													;patrones
		ld		(ix+2),a
		ld		a,60*4
		ld		(ix+6),a
		ld		a,31*4
		ld		(ix+18),a
		ld		a,32*4
		ld		(ix+10),a
		ld		a,45*4
		ld		(ix+22),a
		
		ld		a,9														;colores
		ld		(ix+3),a												;cara prota
		ld		(ix+11),a												;cara bombero
		ld		a,1
		ld		(ix+19),a												;contorno bombero
		ld		a,15
		ld		(ix+7),a												;agua
		ld		a,13
		ld		(ix+23),a												;ropa bombero
				
		jr.		espera_por_muerte
		
colisiones_serpientes_prota_1:

		ld		a,(serp1)												;¿está activa la sepriente 1?
		cp		1
		jr.		nz,colisiones_serpientes_prota_2
		
		ld		iy,variables_serpiente_1
		
		call	coteja_colision_prota_serpiente
		ld		a,(colision_cuchillo_serp_real)
		cp		0
		jr.		z,colisiones_serpientes_prota_2
		
		xor		a
		ld		(colision_cuchillo_serp_real),a		
		
		ld		ix,atributos_sprite_general
					
		ld		a,(iy+1)
		ld		(ix),a
		ld		(ix+4),a
		ld		(ix+8),a
		
		ld		a,(iy)
		ld		(ix+1),a
		ld		(ix+5),a
		ld		(ix+9),a
		
		ld		a,47*4
		ld		(ix+2),a
		ld		a,48*4
		ld		(ix+6),a
		ld		a,49*4
		ld		(ix+18),a
		ld		a,50*4
		ld		(ix+10),a
		ld		a,24*4
		ld		(ix+22),a
				
espera_por_muerte:
		
		call	atributos_sprites
	
		call	activa_mute
	
		ld		a,8						;efecto sonoro de muerte de prota
		call	efecto_sonido		
		
		xor		a
		ld		(muerto),a

on_string_de_muerte:
		
		ld		hl,150
		ld		(clock),hl						
		call	rutina_de_esperar_un_rato
		
		ret		

colisiones_serpientes_prota_2:

		ld		a,(serp2)						;¿está activa la sepriente 2?
		cp		1
		jr.		nz,colisiones_serpientes_prota_3
		
		ld		iy,variables_serpiente_2
		
		call	coteja_colision_prota_serpiente
		ld		a,(colision_cuchillo_serp_real)
		cp		0
		jr.		z,colisiones_serpientes_prota_3
		
		xor		a
		ld		(colision_cuchillo_serp_real),a		
		
		ld		ix,atributos_sprite_general		
				
		ld		a,(iy+1)
		ld		(ix),a
		ld		(ix+4),a
		ld		(ix+8),a
		
		ld		a,(iy)
		ld		(ix+1),a
		ld		(ix+5),a
		ld		(ix+9),a
		
		ld		a,47*4
		ld		(ix+2),a
		ld		a,48*4
		ld		(ix+6),a
		ld		a,49*4
		ld		(ix+26),a
		ld		a,50*4
		ld		(ix+10),a
		ld		a,24*4
		ld		(ix+30),a
						
		jr.		espera_por_muerte

colisiones_serpientes_prota_3:

		ld		a,(serp3)						;¿está activa la sepriente 3?
		cp		1
		jr.		nz,colisiones_serpientes_prota_4

		ld		iy,variables_serpiente_3
	
		call	coteja_colision_prota_serpiente
		ld		a,(colision_cuchillo_serp_real)
		cp		0
		jr.		z,colisiones_serpientes_prota_4
		
		xor		a
		ld		(colision_cuchillo_serp_real),a		
		
		ld		ix,atributos_sprite_general
				
		ld		a,(iy+1)
		ld		(ix),a
		ld		(ix+4),a
		ld		(ix+8),a
		
		ld		a,(iy)
		ld		(ix+1),a
		ld		(ix+5),a
		ld		(ix+9),a
		
		ld		a,47*4
		ld		(ix+2),a
		ld		a,48*4
		ld		(ix+6),a
		ld		a,49*4
		ld		(ix+34),a
		ld		a,50*4
		ld		(ix+10),a
		ld		a,24*4
		ld		(ix+38),a
		
		jr.		espera_por_muerte	
		
colisiones_serpientes_prota_4:

		ld		a,(serp4)						;¿está activa la sepriente 4?
		cp		1
		ret		nz

		ld		iy,variables_serpiente_4
		
		call	coteja_colision_prota_serpiente
		ld		a,(colision_cuchillo_serp_real)
		cp		0
		ret		z
		
		xor		a
		ld		(colision_cuchillo_serp_real),a		
		
		ld		ix,atributos_sprite_general
						
		ld		a,(iy+1)
		ld		(ix),a
		ld		(ix+4),a
		ld		(ix+8),a
		
		ld		a,(iy)
		ld		(ix+1),a
		ld		(ix+5),a
		ld		(ix+9),a
		
		ld		a,47*4
		ld		(ix+2),a
		ld		a,48*4
		ld		(ix+6),a
		ld		a,49*4
		ld		(ix+42),a
		ld		a,50*4
		ld		(ix+10),a
		ld		a,24*4
		ld		(ix+46),a
		
		jr.		espera_por_muerte

coteja_colision_prota_serpiente:

		ld		a,(px)
		sub		a,7					;coordenadas coincidentes
		ld		b,a
		ld		a,(iy)
		cp		b
		ret		c
		
		ld		a,(px)
		add		a,10
		ld		b,a
		ld		a,(iy)
		cp		b
		ret		nc
		
		ld		a,(py)
		sub		a,14
		ld		b,a
		ld		a,(iy+1)
		cp		b
		ret		c
		
		ld		a,(py)
		add		14
		ld		b,a
		ld		a,(iy+1)
		cp		b
		ret		nc
		
		ld		a,(vidas_prota)
		dec		a
		ld		(vidas_prota),a
		
		ld		a,1
		ld		(colision_cuchillo_serp_real),a
		
		ret

coteja_colision_prota_bombero:

		ld		a,(px)
		sub		a,7					;coordenadas coincidentes
		ld		b,a
		ld		a,(iy)
		cp		b
		ret		c
		
		ld		a,(px)
		add		a,10
		ld		b,a
		ld		a,(iy)
		cp		b
		ret		nc
		
		ld		a,(py)
		sub		a,14
		ld		b,a
		ld		a,(iy+1)
		cp		b
		ret		c
		
		ld		a,(py)
		add		14
		ld		b,a
		ld		a,(iy+1)
		cp		b
		ret		nc
		
		ld		a,(vidas_prota)
		dec		a
		ld		(vidas_prota),a
		
		ld		a,1
		ld		(colision_bombero_prota_real),a
		
		ret
				
colisiones_serpientes_cuchillos:

		ld		a,(momento_lanzamiento)			;mira si es posible que el cuchillo este volando
		cp		2
		ret		c
				
		ld		a,(serp1)						;¿está activa la sepriente 1?
		cp		1
		jr.		nz,colision_cuchillo_serp_2
		
colision_cuchillo_serp_1:
		
		ld		iy,variables_serpiente_1
		
		
		call	colision_cuchillo_serpiente
		ld		a,(colision_cuchillo_serp_real)
		cp		0
		jr.		z,colision_cuchillo_serp_2
		
		ld		ix,atributos_sprite_general
					
		xor		a
		ld		(colision_cuchillo_serp_real),a
		ld		(serp1),a
		ld		a,180
		ld		(ix+18),a
		ld		a,184
		ld		(ix+22),a
						
colision_cuchillo_serp_2:

		ld		a,(serp2)						;¿está activa la sepriente 1?
		cp		1
		jr.		nz,colision_cuchillo_serp_3
		
		ld		iy,variables_serpiente_2
		
		call	colision_cuchillo_serpiente
		ld		a,(colision_cuchillo_serp_real)
		cp		0
		jr.		z,colision_cuchillo_serp_3
		
		ld		ix,atributos_sprite_general
				
		xor		a
		ld		(colision_cuchillo_serp_real),a
		ld		(serp2),a
		ld		a,180
		ld		(ix+26),a
		ld		a,184
		ld		(ix+30),a
								
colision_cuchillo_serp_3:

		ld		a,(serp3)						;¿está activa la sepriente 1?
		cp		1
		jr.		nz,colision_cuchillo_serp_4
		
		ld		iy,variables_serpiente_3
		
		call	colision_cuchillo_serpiente
		ld		a,(colision_cuchillo_serp_real)
		cp		0
		jr.		z,colision_cuchillo_serp_4
		
		ld		ix,atributos_sprite_general
			
		xor		a
		ld		(colision_cuchillo_serp_real),a
		ld		(serp3),a
		ld		a,180
		ld		(ix+34),a
		ld		a,184
		ld		(ix+38),a
				
colision_cuchillo_serp_4:

		ld		a,(serp4)						;¿está activa la sepriente 1?
		cp		1
		ret		nz
		
		ld		iy,variables_serpiente_4
		
		call	colision_cuchillo_serpiente
		ld		a,(colision_cuchillo_serp_real)
		cp		0
		ret		z
		
		ld		ix,atributos_sprite_general
		
		xor		a
		ld		(colision_cuchillo_serp_real),a
		ld		(serp4),a
		ld		a,180
		ld		(ix+42),a
		ld		a,184
		ld		(ix+46),a
		
		ret

colision_cuchillo_serpiente:

		ld		a,(cx)							;coordenadas coincidentes
		ld		b,a
		ld		a,(iy)
		cp		b
		ret		nc
		
		add		a,16
		cp		b
		ret		c
	
		ld		a,(cy)
		ld		b,a
		ld		a,(iy+1)
		sub		4
		cp		b
		ret		nc
				
		add		a,20
		cp		b
		ret		c
						
		xor		a
		ld		(momento_lanzamiento),a
				
		ld		a,[cx]						;recupera lo que habia en el tile anteriormente					
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y
		
		ld		a,(recordar_lo_que_habia)
		ld		[hl],a
				
		ld		a,7						;efecto sonoro de muerte
		call	efecto_sonido	
		
		ld		a,[cx]						;recupera tambien en vram
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y_paravram
		
		ld		a,(recordar_lo_que_habia)
		call	pinta_en_pantalla
		
		ld		a,(cuanto_sumamos_a_score)				;puntos ganados por coger mechero
		add		a,25
		ld		(cuanto_sumamos_a_score),a
		ld		a,1
		ld		(cuenta_puntos_o_no),a
		
		ld		a,1
		ld		(colision_cuchillo_serp_real),a
				
		ret
		
atributos_sprites:

		ld		hl,atributos_sprite_general
		ld		de,#1B00
		ld		bc,48
		call	GRABAVRAM		
		ret
		
estado_en_que_se_encuentra:
		call	cero_cero
		call	get_bloque_en_X_Y
		cp		33					;si esta en la salida revisamos si sale
		jr.		z,fase_superada
		
		ld		a,(estado_de_salto)		;no salta? vamos a comprovar si hace algo
		cp		0						
		jr.		z,continua_estado

		cp		3						;diferentes estados de salto
		jr.		c,salta_sube
		cp		19
		jr.		c,salta_sigue
		cp		21
		jr.		c,salta_baja
		cp		33
		jr.		c,salta_sube_izquierda
		cp		49
		jr.		c,salta_sigue_izquierda
		cp		51
		jr.		c,salta_baja_izquierda
		
continua_estado:		
		
		ld		a,(estado_prota)
		cp		4
		ret		z
				
		call	ocho_dieciocho
		call	get_bloque_en_X_Y
		
		cp		41				;no cae si hay escalera
		jr.		z,cambio_estado_a_subiendo_para_la_caida
		cp		42
		jr.		z,cambio_estado_a_subiendo_para_la_caida
		cp		73
		jr.		z,cambio_estado_a_subiendo_para_la_caida
		cp		74
		jr.		z,cambio_estado_a_subiendo_para_la_caida
		
		
		
		ld		a,[px]
		add		10
		ld		d,a
		ld		a,[py]
		add		17
		ld		e,a
		call	get_bloque_en_X_Y
		cp		101
		jr.		z,cambio_estado_a_subiendo_para_la_caida
		
		call	siete_diecisiete
		call	get_bloque_en_X_Y
		
		cp		31					;controla el bloque de ladrillos
		jr.		nc,segunda_comprovacion_caida
		
		jr.		final_rutina_sin_caida

cambio_estado_a_subiendo_para_la_caida:

		ld		a,4
		ld		(estado_prota),a
		ret		
		
segunda_comprovacion_caida:
			
		ld		a,[px]
		add		11
		ld		d,a
		ld		a,[py]
		add		17
		ld		e,a
		call	get_bloque_en_X_Y
		cp		31
		jr.		nc,caigo

final_rutina_sin_caida:
		
		ld		a,0
		ld		(estado_prota),a
			
		ret

caigo:

		ld		a,3
		ld		(estado_prota),a
		
		ld		a,(py)
		add		a,2
		ld		(py),a
		
		ld		a,[px]						;observa si hay que rectificar la caida
		add		15
		ld		d,a
		ld		a,[py]
		add		15
		ld		e,a
		call	get_bloque_en_X_Y
		cp		31
		jr.		c,rectifico_caida_a_izquierda
		
		ld		a,[px]
		ld		d,a
		ld		a,[py]
		add		15
		ld		e,a
		call	get_bloque_en_X_Y
		cp		31
		jr.		c,rectifico_caida_a_derecha
		
		ret

rectifico_caida_a_izquierda:

		ld		a,(px)
		dec		a
		ld		(px),a
		ret

rectifico_caida_a_derecha:

		ld		a,(px)
		inc		a
		ld		(px),a
		ret
				
mueve_prota:

		ld		a,(estado_prota)										;si esta en callendo no se mueve
		cp		3
		ret		z
		ld		a,(estado_de_salto)										;si esta saltando no se mueve
		cp		0
		ret		nz
		ld		a,(momento_lanzamiento) 								;si está lanzando no se mueve
		cp		1
		ret		z
		cp		2
		ret		z
		ld		a,(puede_cambiar_de_direccion)							;si está en una puerta no puede moverse por su cuenta
		cp		0
		ret		z
		
		ld		a,(stick_a_usar)
		call	ONSTICK
		
		cp		0
		jr.		z,pone_estado_prota_a_0
		cp		1
		jr.		z,sube_escaleras
		cp		5
		jr.		z,baja_escaleras	
		cp		3
		jr.		z,mueve_derecha_prota
		cp		7
		jr.		z,mueve_izquierda_prota
				
		ret
		
sube_escaleras:

		push	af
		
		
		ld		a,[px]
		add		6
		ld		d,a
		ld		a,[py]
		add		1
		ld		e,a
		call	get_bloque_en_X_Y
		cp		41
		jr.		z,sube_escaleras_afirmativo
		cp		42
		jr.		z,sube_escaleras_afirmativo
		cp		73
		jr.		z,sube_escaleras_afirmativo
		cp		74
		jr.		z,sube_escaleras_afirmativo
		cp		103
		jr.		z,sube_escaleras_afirmativo
		cp		105
		jr.		z,sube_escaleras_afirmativo
		cp		106
		jr.		z,sube_escaleras_afirmativo
		
		call	seis_diez
		call	get_bloque_en_X_Y
		cp		101
		jr.		z,sube_escaleras_afirmativo
		
		
		ld		a,[px]
		add		10
		ld		d,a
		ld		a,[py]
		add		1
		ld		e,a
		call	get_bloque_en_X_Y
		cp		101
		jr.		z,sube_escaleras_afirmativo
		
		jr.		set_parado
		
sube_escaleras_afirmativo:

		call	cero_cero
		call	get_bloque_en_X_Y
		cp		41
		jr.		z,a_mover_a_la_izquierda
		cp		42
		jr.		z,a_mover_a_la_izquierda
		cp		73
		jr.		z,a_mover_a_la_izquierda
		cp		74
		jr.		z,a_mover_a_la_izquierda
		cp		103
		jr.		z,a_mover_a_la_izquierda
		cp		101
		jr.		z,a_mover_a_la_izquierda
		cp		105
		jr.		z,a_mover_a_la_izquierda
		
		jr.		comprueba_derecha

a_mover_a_la_izquierda:
		
		ld		a,[px]
		dec		a
		ld		[px],a
		jr.		a_subir
		
comprueba_derecha:

		ld		a,[px]
		add		16
		ld		d,a
		ld		a,[py]
		ld		e,a
		call	get_bloque_en_X_Y
		cp		41
		jr.		z,a_mover_a_la_derecha
		cp		42
		jr.		z,a_mover_a_la_derecha
		cp		73
		jr.		z,a_mover_a_la_derecha
		cp		74
		jr.		z,a_mover_a_la_derecha
		cp		101
		jr.		z,a_mover_a_la_derecha
		cp		103
		jr.		z,a_mover_a_la_derecha
		cp		105
		jr.		z,a_mover_a_la_derecha
		jr.		a_subir

a_mover_a_la_derecha:
		
		ld		a,[px]
		inc		a
		ld		[px],a
				
a_subir:

		ld		a,4					;le da el valor 4 a la variable estado prota
		ld		(estado_prota),a
		
		ld		a,(py)
		dec		a
		ld		(py),a
		jr.		actualiza_el_paso_subiendo

baja_escaleras:

		push	af
		
		
		ld		a,[px]
		add		6
		ld		d,a
		ld		a,[py]
		add		16
		ld		e,a
		call	get_bloque_en_X_Y
		cp		41
		jr.		z,baja_escaleras_afirmativo
		cp		42
		jr.		z,baja_escaleras_afirmativo
		cp		43
		jr.		z,baja_escaleras_afirmativo
		cp		44
		jr.		z,baja_escaleras_afirmativo
		cp		73
		jr.		z,baja_escaleras_afirmativo
		cp		74
		jr.		z,baja_escaleras_afirmativo
		cp		103
		jr.		z,baja_escaleras_afirmativo
		cp		106
		jr.		z,baja_escaleras_afirmativo
		cp		105
		jr.		z,baja_escaleras_afirmativo
		ld		a,[px]
		add		10
		ld		d,a
		ld		a,[py]
		add		16
		ld		e,a
		call	get_bloque_en_X_Y
		cp		101
		jr.		z,baja_escaleras_afirmativo
		
		jr.		set_parado
		
baja_escaleras_afirmativo:

		call	menos_uno_dieciseis
		call	get_bloque_en_X_Y
		cp		41
		jr.		z,a_mover_a_la_izquierda_bajando
		cp		42
		jr.		z,a_mover_a_la_izquierda_bajando
		cp		73
		jr.		z,a_mover_a_la_izquierda_bajando
		cp		74
		jr.		z,a_mover_a_la_izquierda_bajando
		cp		103
		jr.		z,a_mover_a_la_izquierda_bajando
		cp		106
		jr.		z,a_mover_a_la_izquierda_bajando
		cp		105
		jr.		z,a_mover_a_la_izquierda_bajando
		
		jr.		comprueba_derecha_bajando

a_mover_a_la_izquierda_bajando:
		
		ld		a,[px]
		dec		a
		ld		[px],a
		jr.		a_bajar
		
comprueba_derecha_bajando:

		call	dieciseis_dieciseis
		call	get_bloque_en_X_Y
		cp		41
		jr.		z,a_mover_a_la_derecha_bajando
		cp		42
		jr.		z,a_mover_a_la_derecha_bajando
		cp		73
		jr.		z,a_mover_a_la_derecha_bajando
		cp		74
		jr.		z,a_mover_a_la_derecha_bajando
		cp		101
		jr.		z,a_mover_a_la_derecha_bajando
		cp		103
		jr.		z,a_mover_a_la_derecha_bajando
		cp		106
		jr.		z,a_mover_a_la_derecha_bajando
		cp		105
		jr.		z,a_mover_a_la_derecha_bajando
		
		jr.		a_bajar

a_mover_a_la_derecha_bajando:
		
		ld		a,[px]
		inc		a
		ld		[px],a
				
a_bajar:

		ld		a,4														;le da el valor 4 a la variable estado prota
		ld		(estado_prota),a
		
		ld		a,(py)
		inc		a
		ld		(py),a
		jr.		actualiza_el_paso_subiendo
				
mueve_izquierda_prota:

		push	af
		
		;colision lateral con solido
				
		ld		a,[px]
		add		5
		ld		d,a
		ld		a,[py]
		add		15
		ld		e,a
		call	get_bloque_en_X_Y
		cp		32														;hasta el 31 son solidos
		jr.		c,set_parado											;si es inferior, no hay acarreo 
		cp		113														;se para ante las puertas de pinchos
		jr.		z,set_parado
		cp		115
		jr.		z,set_parado
		
		call	tres_quince
		call	get_bloque_en_X_Y
		cp		114														;gira las puertas
		jr.		z,gira_puerta_izquierda_amarilla
		cp		116
		jr.		z,gira_puerta_izquierda_azul
		
		ld		a,1														;le da el valor 1 a la variable de estado prota
		ld		(estado_prota),a
				
		ld		a,(px)
		dec		a
		ld		(px),a
		ld		a,1
		ld		(dir_prota),a
		jr.		actualiza_el_paso

actualiza_el_paso_subiendo:

		ld		a,(retard_anim)
		inc		a
		cp		8
		jr		z,reset_retardo_y_cambia_paso_subiendo
		ld		(retard_anim),a
		jr.		end

reset_retardo_y_cambia_paso_subiendo:

		xor		a
		ld		(retard_anim),a
		ld		a,(paso)
		cpl								;le da la vuelta a todos los bits
		and		00000011b				;pone 1 en los dos primero, con lo que lo convierte en un 3 (01=1 10=2 11=3)
		ld		(paso),a
		jr.		end
		
gira_puerta_derecha_amarilla:
		
		xor		a
		ld		(puede_cambiar_de_direccion),a
		
		call	catorce_dos
		call	get_bloque_en_X_Y
		ld		a,117
		ld		[hl],a
								
		call	catorce_dos
		call	get_bloque_en_X_Y_paravram
		
		ld		a,117
		call	pinta_en_pantalla
		
		call	catorce_diez
		call	get_bloque_en_X_Y
		ld		a,117
		ld		[hl],a
								
		call	catorce_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,117
		call	pinta_en_pantalla
		
		
		pop		af
		
		ret
		
gira_puerta_izquierda_amarilla:

		xor		a
		ld		(puede_cambiar_de_direccion),a
		
		call	tres_dos
		call	get_bloque_en_X_Y
		
		ld		a,117
		ld		[hl],a
								
		call	tres_dos
		call	get_bloque_en_X_Y_paravram
		
		ld		a,117
		call	pinta_en_pantalla
		
		call	tres_quince
		call	get_bloque_en_X_Y
		
		ld		a,117
		ld		[hl],a
								
		call	tres_quince
		call	get_bloque_en_X_Y_paravram
		
		ld		a,117
		call	pinta_en_pantalla
		
		pop		af
		
		ret
		
gira_puerta_derecha_azul:

		xor		a
		ld		(puede_cambiar_de_direccion),a
		
		call	catorce_dos
		call	get_bloque_en_X_Y
		
		ld		a,118
		ld		[hl],a
								
		call	catorce_dos
		call	get_bloque_en_X_Y_paravram
		
		ld		a,118
		call	pinta_en_pantalla
		
		call	catorce_diez
		call	get_bloque_en_X_Y
				
		ld		a,118
		ld		[hl],a
								
		call	catorce_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,118
		call	pinta_en_pantalla
		
		
		pop		af
		
		ret
		
gira_puerta_izquierda_azul:	

		xor		a
		ld		(puede_cambiar_de_direccion),a
		
		call	tres_dos
		call	get_bloque_en_X_Y
		
		ld		a,118
		ld		[hl],a
								
		call	tres_dos
		call	get_bloque_en_X_Y_paravram
		
		ld		a,118
		call	pinta_en_pantalla
		
		call	tres_quince
		call	get_bloque_en_X_Y
		
		ld		a,118
		ld		[hl],a
								
		call	tres_quince
		call	get_bloque_en_X_Y_paravram
		
		ld		a,118
		call	pinta_en_pantalla
			
		pop		af
		
		ret
		
mueve_derecha_prota:

		push	af
		
		;colision lateral con solido
						
		ld		a,[px]
		add		12
		ld		d,a
		ld		a,[py]
		add		15
		ld		e,a
		call	get_bloque_en_X_Y
		cp		32														;hasta el 31 son solidos
		jr.		c,set_parado											;si es inferior, no hay acarreo 
		cp		114														;se para ante las puertas de pinchos
		jr.		z,set_parado
		cp		116
		jr.		z,set_parado
				
		call	catorce_diez
		call	get_bloque_en_X_Y
		cp		113														;gira las puertas
		jr.		z,gira_puerta_derecha_amarilla
		cp		115
		jr.		z,gira_puerta_derecha_azul
		
		ld		a,1														;le da el valor 1 a la variable de estado prota
		ld		(estado_prota),a
				
		ld		a,(px)
		inc		a
		ld		(px),a
		ld		a,0
		ld		(dir_prota),a

actualiza_el_paso:

		ld		a,(retard_anim)
		inc		a
		cp		8
		jr		z,reset_retardo_y_cambia_paso
		ld		(retard_anim),a
		jr.		end

reset_retardo_y_cambia_paso:

		xor		a
		ld		(retard_anim),a
		ld		a,(paso)
		cpl																;le da la vuelta a todos los bits
		and		00000011b												;pone 1 en los dos primero, con lo que lo convierte en un 3 (01=1 10=2 11=3)
		ld		(paso),a
		jr.		end
		


actualiza_atributos_sprite:
		
		ld		ix,atributos_sprite_general
		
		ld		a,(py)													;valor y**
		ld		(ix),a
		add		a,7
		ld		(ix+4),a
		sub		a,16
		ld		(ix+8),a
		
		ld		a,(px)													;valor x**
		ld		(ix+1),a
		ld		(ix+5),a
		ld		(ix+9),a
			
		ld		a,(estado_prota)
		cp		4
		jr.		z,esta_subiendo_o_bajando_para_el_patron
		
		call	ocho_uno
		call	get_bloque_en_X_Y
		cp		41
		jr.		z,esta_subiendo_o_bajando_para_el_patron
		
		cp		3
		jr.		z,esta_cayendo_para_el_patron
		
		ld		a,(dir_prota)											;valor de la direccion
		cp		0
		jr		nz,mirando_izquierda
		
		ld		a,(momento_lanzamiento)									;mira si está lanzando
		cp		1
		jr.		z,lanza_derecha_1
		cp		2
		jr.		z,lanza_derecha_2
		
		ld		b,0*4													;mirando derecha
		jr		mirar_paso

lanza_derecha_1:
		
		ld		a,33*4													;mirando derecha pose 1 de lanzamiento
		jr.		ultimos_valores
		
lanza_derecha_2:
		
		ld		a,36*4													;mirando derecha pose 2 de lanzamiento
		jr.		ultimos_valores
		
mirando_izquierda:

		ld		a,(momento_lanzamiento)
		cp		1
		jr.		z,lanza_izquierda_1
		cp		2
		jr.		z,lanza_izquierda_2
		
		ld		b,6*4													;mirando izquierda
		jr.		mirar_paso
		
lanza_izquierda_1:

		ld		a,39*4													;mirando izquierda pose 1 de lanzamiento
		jr.		ultimos_valores
		
lanza_izquierda_2:

		ld		a,42*4													;mirando izquierda pose 2 de lanzamiento
		jr.		ultimos_valores
		
mirar_paso:
		
		ld		a,(estado_de_salto)										;paso abierto si esta saltando
		cp		0
		jr.		z,todo_va_bien
		
		ld		a,3
[2]		sla		a
		add		a,b
		
		jr.		ultimos_valores
		
todo_va_bien:		
		ld		a,(paso)
[2]		sla		a				;multiplica x2 2 veces
		add		a,b				;le damos el patron definitivo

ultimos_valores:
		
		ld		ix,atributos_sprite_general
		
		ld		(ix+2),a		;valor patron**
		ld		a,(ix+2)
		add		a,4
		ld		(ix+6),a
		ld		a,(ix+2)
		add		a,8
		ld		(ix+10),a
		
		ld		a,(color_lineas_prota)				;valor color**
		ld		(ix+3),a
		ld		a,(color_prota)
		ld		(ix+7),a
		ld		a,9
		ld		(ix+11),a
		
		ret

esta_cayendo_para_el_patron:

		ld		b,18*4
		ld		a,b
		jr.		ultimos_valores
		
esta_subiendo_o_bajando_para_el_patron:	

		ld		b,12*4
		jr.		mirar_paso
		
end:

		xor		a
		ld		[prev_dir_prota],a
		
		pop		af
		ret
		
set_parado:

		xor		a
		ld		[estado_prota],a
		jr.		end

get_bloque_en_X_Y:

		;(y/8)*32+(x/8)
		ld		a,e				;a=y
[3]		srl		a				;a=y/8
		ld		h,0
		ld		l,a				;hl=y/8
[5]		add		hl,hl			;*32			a=(y/8)*32
		
		ld		a,d				;a=x
[3]		srl		a				;a=x/8
		ld		d,0
		ld		e,a				;de=x/8
		add		hl,de			;hl=(y/8)*32+(x/8)
		
		ld		de,buffer_colisiones
		add		hl,de			;hl=buffer_colisiones + (y/8)*32+(x/8)
		ld		bc,32
		sbc		hl,bc		
		ld		a,[hl]
		ret

get_bloque_en_X_Y_paravram:

		ld		a,e				;a=y
[3]		srl		a				;a=y/8
		ld		h,0
		ld		l,a				;hl=y/8
[5]		add		hl,hl			;*32			a=(y/8)*32
		
		ld		a,d				;a=x
[3]		srl		a				;a=x/8
		ld		d,0
		ld		e,a				;de=x/8
		add		hl,de			;hl=(y/8)*32+(x/8)
		
		ret
		
pone_estado_prota_a_0:

		xor		a
		ld		(estado_prota),a
		
pose_si_esta_parado:
		call	cero_cero
		call	get_bloque_en_X_Y
		cp		41
		jr.		z,esta_en_escalera
		
		ld		a,(estado_prota)
		cp		0
		ret		nz
		
		xor		a
		ld		(paso),a

		ret
esta_en_escalera:
		
		ld		a,4
		ld		(estado_prota),a
		ret
			
usa_objeto_o_salta:
		
		ld		a,(cont_no_salta_dos_seguidas)							;evita que se pulse el salto durante el salto
		cp		0
		jr.		nz,(reduce_el_contador_de_salto)
		
		ld		a,(puede_cambiar_de_direccion)							;evita que salte si está en una puerta
		cp		0
		ret		z
		
		ld		a,(estado_de_salto)										;evita el string si ya está saltando
		cp		0
		ret		nz
		
		ld		a,(estado_de_explosion)									;evita el string si hay una explosion
		cp		0
		ret		nz
		
		ld		a,(momento_lanzamiento)									;evita el string si está lanzando
		cp		1
		ret		z
		cp		2
		ret		z
		
		
		ld		a,(estado_prota)										;Evita string si está en escaleras
		cp		4
		ret		z
		
		call	dos_diez
		call	get_bloque_en_X_Y
		cp		41
		ret		z
		cp		42
		ret		z
		cp		41
		ret		z
		cp		105
		ret		z
		cp		106
		ret		z
		cp		101
		ret		z
		cp		103
		ret		z
				
		ld		a,(stick_a_usar)
		call	ONSTRIG
		cp		#FF
		jr.		z,decide_si_usa_o_salta
				
		ret

reduce_el_contador_de_salto:

		dec		a
		ld		(cont_no_salta_dos_seguidas),a
		ret
		
decide_si_usa_o_salta:

		ld		a,(tiene_objeto)
		cp		1
		jr.		z,usa_bomba
		cp		2
		jr.		z,usa_cuchillo
		
		ld		a,[px]				;no salta si tiene techo (para evitar volar)
		ld		d,a
		ld		a,[py]
		sub		a,2
		ld		e,a
		call	get_bloque_en_X_Y
		cp		31
		ret		c
		
		call	cero_cero
		call	get_bloque_en_X_Y
		cp		33					;si esta en la salida revisamos si sale
		jr.		z,fase_superada
		
		ld		a,(estado_prota)		;si esta callendo, no salta
		cp		3
		ret		z
		
		ld		a,4						;efecto de saltar
		call	efecto_sonido
		
		jr.		ha_saltado
		
		ret

fase_superada:

		ld		a,(mechero)
		cp		0
		ret		z
		
		ld		a,(gasolina)
		cp		0
		ret		z
		
		ld		a,(color_prota)
		cp		7
		ret		z
		
		ld		a,1
		ld		(pasamos_la_fase),a
		ret

apaga_los_chorros:
	
		call 	menos_dos_diez
		call	get_bloque_en_X_Y
		
		cp		89
		jr.		z,quita_a_tu_izquierda
		cp		121
		jr.		z,quita_a_tu_izquierda
		
		call	menos_dos_dieciocho
		call	get_bloque_en_X_Y	
		
		cp		89
		jr.		z,quita_a_tu_izquierda_2
		cp		121
		jr.		z,quita_a_tu_izquierda_2
			
		call	catorce_diez
		call	get_bloque_en_X_Y
		
		cp		89
		jr.		z,quita_a_tu_derecha
		cp		121
		jr.		z,quita_a_tu_derecha
		
		call	catorce_dieciocho
		call	get_bloque_en_X_Y
		
		cp		89
		jr.		z,quita_a_tu_derecha_2
		cp		121
		jr.		z,quita_a_tu_derecha_2
		
		ret
			
quita_a_tu_derecha:

		call	seis_diez
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
		
		call	catorce_diez
		call	get_bloque_en_X_Y
		ld		a,86
		ld		[hl],a
		
		call	veintidos_diez
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
								
		call	seis_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		
		call	catorce_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,86
		call	pinta_en_pantalla
		
		call	veintidos_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		
		ret

quita_a_tu_izquierda:
		
		call	seis_diez
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
		
		call	menos_dos_diez
		call	get_bloque_en_X_Y
		ld		a,86
		ld		[hl],a
		
		call	menos_diez_diez
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
								
		call	seis_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		
		call	menos_dos_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,86
		call	pinta_en_pantalla
		
		call	menos_diez_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		
		ret


quita_a_tu_derecha_2:

		call	seis_dieciocho
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
		
		call	catorce_dieciocho
		call	get_bloque_en_X_Y
		ld		a,86
		ld		[hl],a
		
		ld		a,[px]					;borra en buffer_colisiones el chorro						
		add		20
		ld		d,a
		ld		a,[py]
		add		18
		ld		e,a
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
								
		call	seis_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		
		call	catorce_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,86
		call	pinta_en_pantalla
		
		ld		a,[px]
		add		22
		ld		d,a
		ld		a,[py]
		add		18
		ld		e,a
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		
		ret

quita_a_tu_izquierda_2:
		
		call	seis_dieciocho
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
		
		call	menos_dos_dieciocho
		call	get_bloque_en_X_Y
		ld		a,86
		ld		[hl],a
		
		call	menos_diez_dieciocho
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
								
		call	seis_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		
		call	menos_dos_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,86
		call	pinta_en_pantalla
		
		call	menos_diez_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		
		ret
		
coge_algun_objeto:
		
		call	seis_dos
		call	get_bloque_en_X_Y
		
		cp		93
		jr.		z,damos_la_luz
		
		ld		a,(vision_estado)
		cp		0
		ret		z
		
		call	seis_diez
		call	get_bloque_en_X_Y
		
		cp		98
		jr.		z,coge_mechero
		
		cp		97
		jr.		z,coge_gasolina

		cp		87
		jr.		z,cierra_grifo
		
		cp		107
		jr.		z,coge_toalla
						
		cp		86
		jr.		z,activa_chorro_1
		
		cp		121	
		jr.		z,activa_chorro_1
		
		cp		89
		jr.		z,activa_chorro_2
		
		cp		80
		jr.		z,activa_escalera_extra
					
		call	seis_dieciocho
		call	get_bloque_en_X_Y
		
		cp		86
		jr.		z,activa_chorro_3
				
		ld		a,(tiene_objeto)
		cp		0
		ret		nz
		
		call	seis_diez
		call	get_bloque_en_X_Y
		
		cp		99
		jp.		z,coge_la_bomba
		
		cp		96
		jp.		z,coge_cuchillo
		
		ret
	
activa_escalera_extra:

		ld		a,1
		ld		(escalera_activada),a
		
		call	seis_diez
		call	get_bloque_en_X_Y
		ld		a,112
		ld		[hl],a
		call	seis_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,112
		call	pinta_en_pantalla
		
		ld		a,10						;efecto sonoro de activar
		call	efecto_sonido
		
		ret
		
activa_chorro_1:

		ld		a,(grifo_estado)
		cp		0
		ret		z
		
		call	menos_dos_diez
		call	get_bloque_en_X_Y
		
		ld		a,88
		ld		[hl],a
								
		call	menos_dos_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,88
		call	pinta_en_pantalla
		
		call	seis_diez
		call	get_bloque_en_X_Y
		ld		a,89
		ld		[hl],a
								
		call	seis_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,89
		call	pinta_en_pantalla
		
		call	catorce_diez
		call	get_bloque_en_X_Y
		ld		a,90
		ld		[hl],a
								
		call	catorce_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,90
		call	pinta_en_pantalla
		
		ld		a,11						;efecto sonoro agua (arreglar)
		call	efecto_sonido

		jr.		moja_prota
		
activa_chorro_3:

		ld		a,(grifo_estado)
		cp		0
		ret		z
		
		call	menos_dos_dieciocho
		call	get_bloque_en_X_Y
		
		ld		a,88
		ld		[hl],a
								
		call	menos_dos_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,88
		call	pinta_en_pantalla
		
		call	seis_dieciocho
		call	get_bloque_en_X_Y
		ld		a,89
		ld		[hl],a
								
		call	seis_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,89
		call	pinta_en_pantalla
		
		call	catorce_dieciocho
		call	get_bloque_en_X_Y
		ld		a,90
		ld		[hl],a
								
		call	catorce_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,90
		call	pinta_en_pantalla
		
		ld		a,11						;efecto sonoro agua (arreglar)
		call	efecto_sonido
						
moja_prota:

		ld		a,7
		ld		(color_prota),a
		ld		a,14
		ld		(color_lineas_prota),a
		
		ret

activa_chorro_2:

		ld		a,(grifo_estado)
		cp		0
		ret		z
		
		call	menos_dos_diez
		call	get_bloque_en_X_Y
		ld		a,120
		ld		[hl],a
								
		call	menos_dos_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,120
		call	pinta_en_pantalla
		
		call	seis_diez
		call	get_bloque_en_X_Y
		ld		a,121
		ld		[hl],a
								
		call	seis_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,121
		call	pinta_en_pantalla
		
		call	catorce_diez
		call	get_bloque_en_X_Y
		ld		a,122
		ld		[hl],a
								
		call	catorce_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,122
		call	pinta_en_pantalla
		
		ret
				
coge_toalla:

		ld		a,(cuanto_sumamos_a_score)				;puntos ganados por coger toalla
		add		a,6
		ld		(cuanto_sumamos_a_score),a
		ld		a,1
		ld		(cuenta_puntos_o_no),a
		
		call	seis_diez
		call	get_bloque_en_X_Y
		ld		a,108
		ld		[hl],a
								
		call	seis_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,108
		call	pinta_en_pantalla
		
		ld		a,2						;efecto sonoro de toalla cogida
		call	efecto_sonido
		
		ld		a,8						; da valor a la variable para secar al prota
		ld		(color_prota),a
		ld		a,1
		ld		(color_lineas_prota),a
		
		ret

cierra_grifo:

		ld		a,(cuanto_sumamos_a_score)								;puntos ganados por coger mechero
		add		a,10
		ld		(cuanto_sumamos_a_score),a
		ld		a,1
		ld		(cuenta_puntos_o_no),a
		
		call	seis_diez
		call	get_bloque_en_X_Y
		ld		a,119
		ld		[hl],a
								
		call	seis_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,119
		call	pinta_en_pantalla
		
		ld		a,10													;efecto sonoro de cerrar grifo
		call	efecto_sonido
		
		xor		a														; da valor a la variable para dar por hecho que el grifo está cerrado
		ld		(grifo_estado),a
		
		ret
		
coge_mechero:
		
		ld		a,(cuanto_sumamos_a_score)								;puntos ganados por coger mechero
		add		a,50
		ld		(cuanto_sumamos_a_score),a
		ld		a,1
		ld		(cuenta_puntos_o_no),a
		
		call	seis_diez
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
								
		call	seis_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		
		ld		a,203
		ld		[#eeee],a
		ld		hl,#eeee												;pinta el mechero  a color
		ld		de,#181c
		ld		bc,1
		call	GRABAVRAM
		
		ld		a,2						;efecto sonoro de coger
		call	efecto_sonido
		
		ld		a,1						; da valor a la variable para adeptar que la tienes
		ld		(mechero),a
		
		ret

damos_la_luz:
		
		ld		a,(cuanto_sumamos_a_score)								;puntos ganados por dar la luz
		add		a,75
		ld		(cuanto_sumamos_a_score),a
		ld		a,1
		ld		(cuenta_puntos_o_no),a
		
		call	seis_dos
		call	get_bloque_en_X_Y
		ld		a,125
		ld		[hl],a
								
		call	copiamos_en_pantalla_lo_de_memoria
		
		ld		a,2														;efecto sonoro de coger
		call	efecto_sonido
		
		ld		a,1
		ld		(vision_estado),a										;damos acceso a los objetos que ya se ven
				
		ret

coge_gasolina:
		
		ld		a,(cuanto_sumamos_a_score)				;puntos ganados por coger gasolina
		add		a,50
		ld		(cuanto_sumamos_a_score),a
		ld		a,1
		ld		(cuenta_puntos_o_no),a
		
		call	seis_diez
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
				
		call	seis_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		
		ld		a,202
		ld		[#eeee],a
		ld		hl,#eeee				;pinta la gasolina  a color
		ld		de,#181a
		ld		bc,1
		call	GRABAVRAM
		
		ld		a,2						;efecto sonoro de coger
		call	efecto_sonido
		
		ld		a,1						;da valor a la variable para adeptar que la tienes
		ld		(gasolina),a			
		
		ret
					
coge_la_bomba:
		
		ld		a,(cuanto_sumamos_a_score)				;puntos ganados por coger la bomba
		add		a,5
		ld		(cuanto_sumamos_a_score),a
		ld		a,1
		ld		(cuenta_puntos_o_no),a
		
		call	SPRITES_BOMBA
		
		call	seis_diez
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
		
		ld		a,[hl]					;borra de pantalla la bomba cogida												
		call	seis_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		
		ld		a,204
		ld		[#eeee],a
		ld		hl,#eeee				;pinta la bomba a color
		ld		de,#181e
		ld		bc,1
		call	GRABAVRAM
		
		xor		a						;efecto sonoro de coger
		call	efecto_sonido
		
		ld		a,1						; da el valor interno a tiene_objeto
		ld		(tiene_objeto),a
		
		ret

coge_cuchillo:
		
		ld		a,(cuanto_sumamos_a_score)				;puntos ganados por coger cuchillo
		add		a,1
		ld		(cuanto_sumamos_a_score),a
		ld		a,1
		ld		(cuenta_puntos_o_no),a
		
		call	SPRITES_CUCHILLO
		
		call	seis_diez
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
		
		call	seis_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		
		ld		a,209
		ld		[#eeee],a
		ld		hl,#eeee				;pinta la espada a color
		ld		de,#1818
		ld		bc,1
		call	GRABAVRAM
		
		xor		a						;efecto sonoro de coger
		call	efecto_sonido
		
		ld		a,2						; da el valor interno a tiene_objeto
		ld		(tiene_objeto),a
		
		ret
		
usa_bomba:
		
		call	cero_dieciocho
		call	get_bloque_en_X_Y
		cp		20
		jr.		c,continuamos
		cp		21
		jr.		z,continuamos
		cp		22
		jr.		z,continuamos
		cp		23
		jr.		z,continuamos		
		cp		24
		jr.		z,continuamos

		ret
		
continuamos:

		call	SPRITES_PROTA_NORMAL		
		
		ld		a,(px)					;situamos la explosion
		sub		a,4
		ld		(x_explosion),a
		ld		a,(py)
		add		a,10
		ld		(y_explosion),a
		
		ld		a,207
		ld		[#eeee],a
		ld		hl,#eeee				;pinta la bomba a blanco y negro
		ld		de,#181e
		ld		bc,1
		call	GRABAVRAM
	
		ld		a,0						;le quitamos el objeto
		ld		(tiene_objeto),a
		
		ld		a,1
		ld		(estado_de_explosion),a	;activamos los sprites de explosion
		
		ld		a,3						;efecto sonoro de bomba
		call	efecto_sonido	
		
		call	cero_dieciocho
		call	get_bloque_en_X_Y
		cp		20
		jr.		c,hace_agujero_1
		cp		21
		jr.		z,hace_agujero_2
		cp		22
		jr.		z,hace_agujero_2
		cp		23
		jr.		z,hace_agujero_3		
		cp		24
		jr.		z,hace_agujero_3
		ret

segunda_comprovacion_de_agujeros:

		call	ocho_dieciocho
		call	get_bloque_en_X_Y
		cp		20
		jr.		c,hace_agujero_1_2
		cp		21
		jr.		z,hace_agujero_2_2
		cp		22
		jr.		z,hace_agujero_2_2
		cp		23
		jr.		z,hace_agujero_3_2		
		cp		24
		jr.		z,hace_agujero_3_2
		ret
hace_agujero_1:
		
		ld		a,(cuanto_sumamos_a_score)				;puntos ganados por perforar suelo
		add		a,5
		ld		(cuanto_sumamos_a_score),a
		ld		a,1
		ld		(cuenta_puntos_o_no),a
		
													
		call	cero_dieciocho
		call	get_bloque_en_X_Y
		ld		a,21
		ld		[hl],a
				
		call	cero_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,21
		call	pinta_en_pantalla		
		
		jr.		segunda_comprovacion_de_agujeros

hace_agujero_1_2:

		call	ocho_dieciocho
		call	get_bloque_en_X_Y
		ld		a,22
		ld		[hl],a
		
		call	ocho_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,22
		call	pinta_en_pantalla
		
		ret
hace_agujero_2:

		ld		a,(cuanto_sumamos_a_score)				;puntos ganados por perforar suelo
		add		a,10
		ld		(cuanto_sumamos_a_score),a
		ld		a,1
		ld		(cuenta_puntos_o_no),a
		
		ld		a,[hl]					;pone en buffer_colisiones el suelo 3										
		call	cero_dieciocho
		call	get_bloque_en_X_Y
		ld		a,23
		ld		[hl],a
				
		call	cero_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,23
		call	pinta_en_pantalla
		
		jr. 	segunda_comprovacion_de_agujeros
		
hace_agujero_2_2:
		
		call	ocho_dieciocho
		call	get_bloque_en_X_Y
		ld		a,24
		ld		[hl],a
		
		call	ocho_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,24
		call	pinta_en_pantalla
		
		ret

hace_agujero_3:
		
		ld		a,(cuanto_sumamos_a_score)				;puntos ganados por perforar suelo
		add		a,15
		ld		(cuanto_sumamos_a_score),a
		ld		a,1
		ld		(cuenta_puntos_o_no),a
		
		call	cero_dieciocho
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
		
		call	cero_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		
		call	ocho_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		
		jr.		segunda_comprovacion_de_agujeros
		
hace_agujero_3_2:

		call	ocho_dieciocho
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a

		call	ocho_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		ret
			
usa_cuchillo:

		ld		a,(momento_lanzamiento)
		cp		0
		ret		nz
		
		ld		a,208
		ld		[#eeee],a
		ld		hl,#eeee												;pinta el cuchillo a blanco y negro
		ld		de,#1818
		ld		bc,1
		call	GRABAVRAM
	
		xor		a														;le quita el cuchillo
		ld		(tiene_objeto),a
		
		call	SPRITES_PROTA_NORMAL	
				
		ld		a,1														;activa las poses de lanzamiento
		ld		(momento_lanzamiento),a
		
		ret
		
rutina_cuchillo_volador:
		
		ld		a,(momento_lanzamiento)
		cp		0						
		ret		z
		cp		3						
		jr.		z,comprueba_lugar_cuchillo
		jr.		nc,avanza_cuchillo
		ld		b,a
		ld		a,(contador_poses_lanzar)
		dec		a
		ld		(contador_poses_lanzar),a
		cp		0
		ret		nz
		ld		a,5
		ld		(contador_poses_lanzar),a
		ld		a,b
		
		inc		a
		ld		(momento_lanzamiento),a
		
		ret

comprueba_lugar_cuchillo:

		ld		a,6						;efecto sonoro de lanzar
		call	efecto_sonido	
		
		ld		a,(dir_prota)				;vemos direccion en la que lanza
		cp		1
		jr.		z,lanzamos_a_la_izquierda

lanzamos_a_la_derecha:

		ld		(dir_cuchillo),a		;guardamos la dirección para poder seguirla con el cuchillo

		ld		a,[px]					
		add		8
		ld		d,a
		ld		a,[py]
		inc		a
		ld		e,a
		call	get_bloque_en_X_Y
		ld		a,[hl]
		cp		32
		jr.		c,intento_fallido
		
		ld		(recordar_lo_que_habia),a
		ld		a,100
		ld		[hl],a
				
		ld		a,[px]					;a vram
		add		8
		ld		[cx],a
		ld		d,a
		ld		a,[py]
		inc		a
		ld		[cy],a
		ld		e,a
		call	get_bloque_en_X_Y_paravram
		
		ld		a,100
		call	pinta_en_pantalla
		
		ld		a,4						;pasamos el estado a movimiento
		ld		(momento_lanzamiento),a
		
		ret

lanzamos_a_la_izquierda:

		ld		(dir_cuchillo),a		;guardamos la dirección para poder seguirla con el cuchillo

		ld		a,[px]					
		inc		a
		ld		d,a
		ld		a,[py]
		inc		a
		ld		e,a
		call	get_bloque_en_X_Y
		ld		a,[hl]
		cp		32
		jr.		c,intento_fallido
		
		ld		(recordar_lo_que_habia),a
		ld		a,102
		ld		[hl],a
				
		ld		a,[px]					;a vram
		inc		a
		ld		[cx],a
		ld		d,a
		ld		a,[py]
		inc		a
		ld		[cy],a
		ld		e,a
		call	get_bloque_en_X_Y_paravram
		
		ld		a,102
		call	pinta_en_pantalla
		
		ld		a,4						;pasamos el estado a movimiento
		ld		(momento_lanzamiento),a
		
		ret

intento_fallido:

		ld		a,3						;efecto sonoro de fallo
		call	efecto_sonido	
		
		xor		a
		ld		(momento_lanzamiento),a
		
		ret
		
avanza_cuchillo:
		ld		a,(dir_cuchillo)
		cp		1
		jr.		z,avanza_hacia_la_izquierda

avanza_hacia_la_derecha:

		ld		a,[cx]						;si en el siguiente tile hay ladrillo, va a clavar
		add		4
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y
		ld		a,[hl]
		cp		32
		jr.		c,(clava_a_la_derecha)
	
		ld		a,[cx]						;recupera lo que habia en el tile anteriormente					
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y
		
		ld		a,(recordar_lo_que_habia)
		ld		[hl],a
	
		ld		a,[cx]						;recupera tambien en vram
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y_paravram
		
		ld		a,(recordar_lo_que_habia)
		call	pinta_en_pantalla
		
		ld		a,[cx]						;salva lo que hay en el tile destino
		add		4
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y
		ld		a,[hl]
		ld		(recordar_lo_que_habia),a
		
		ld		[hl],100					;pone el cuchillo en el nuevo tile
		
		ld		a,[cx]
		add		4							;tambien en vram
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y_paravram
		
		ld		a,100
		call	pinta_en_pantalla
							
		ld		a,[cx]						;nuevo valor para las coordenadas x e y
		add		4
		ld		[cx],a
		
		ret		

clava_a_la_derecha:

		ld		a,(recordar_lo_que_habia)		;si está en escalera, tile especial
		cp		42
		jr.		nz,(continua_clava_derecha_normal)
		
		ld		a,5						;efecto sonoro de clavar
		call	efecto_sonido	
		
		ld		a,[cx]						;graba el cuchillo clavado					
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y
		ld		[hl],106
		
		ld		a,[cx]						;tambien en vram
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y_paravram
				
		ld		a,106
		call	pinta_en_pantalla
		
		xor		a
		ld		(momento_lanzamiento),a
		
		ret
		
continua_clava_derecha_normal:

		ld		a,5						;efecto sonoro de clavar
		call	efecto_sonido	
		
		ld		a,[cx]						;graba el cuchillo clavado					
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y
		ld		[hl],101
		
		ld		a,[cx]						;tambien en vram
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y_paravram
		
		ld		a,101
		call	pinta_en_pantalla
		
		xor		a
		ld		(momento_lanzamiento),a
		
		ret

avanza_hacia_la_izquierda:

		ld		a,[cx]						;si en el siguiente tile hay ladrillo, va a clavar
		sub		a,4
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y
		ld		a,[hl]
		cp		32
		jr.		c,(clava_a_la_izquierda)
	
		ld		a,[cx]						;recupera lo que habia en el tile anteriormente					
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y
		
		ld		a,(recordar_lo_que_habia)
		ld		[hl],a
	
		ld		a,[cx]						;recupera tambien en vram
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y_paravram
		
		ld		a,(recordar_lo_que_habia)
		call	pinta_en_pantalla
		
		ld		a,[cx]						;salva lo que hay en el tile destino
		sub		a,4
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y
		ld		a,[hl]
		ld		(recordar_lo_que_habia),a
		
		ld		[hl],102					;pone el cuchillo en el nuevo tile
		
		ld		a,[cx]
		sub		a,4							;tambien en vram
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y_paravram
		
		ld		a,102
		call	pinta_en_pantalla
							
		ld		a,[cx]						;nuevo valor para las coordenadas x e y
		sub		a,4
		ld		[cx],a
		
		ret
		
clava_a_la_izquierda:
		
		ld		a,(recordar_lo_que_habia)		;si está en escalera, tile especial
		cp		41
		jr.		nz,(continua_clava_izquierda_normal)
		
		ld		a,5						;efecto sonoro de clavar
		call	efecto_sonido	
		
		ld		a,[cx]						;graba el cuchillo clavado					
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y
		ld		[hl],106
		
		ld		a,[cx]						;tambien en vram
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y_paravram
				
		ld		a,105
		call	pinta_en_pantalla
		
		xor		a
		ld		(momento_lanzamiento),a
		
		ret
		
continua_clava_izquierda_normal:

		ld		a,5						;efecto sonoro de clavar
		call	efecto_sonido
		
		ld		a,[cx]						;graba el cuchillo clavado					
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y
		ld		[hl],103
		
		ld		a,[cx]						;tambien en vram
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y_paravram
		
		ld		a,103
		call	pinta_en_pantalla
		
		xor		a
		ld		(momento_lanzamiento),a
		
		ret
		
actualiza_la_puerta:
		
		ld		a,(ya_ha_cambiado_puerta)
		cp		0
		ret		nz
		
		ld		a,(mechero)
		cp		0
		ret		z
		ld		a,(gasolina)
		cp		0
		ret		z
		
							
		ld		hl,(posicion_puerta)
		ld		a,45
		call	pinta_en_pantalla
		
		ld		a,(posicion_puerta)
		add		1
		ld		(posicion_puerta),a
		ld		hl,(posicion_puerta)
		
		ld		a,46
		call	pinta_en_pantalla
		
		ld		a,(posicion_puerta)
		add		31
		ld		(posicion_puerta),a
		ld		hl,(posicion_puerta)
		
		ld		a,48
		call	pinta_en_pantalla
		
		ld		a,(posicion_puerta)
		add		1
		ld		(posicion_puerta),a
		ld		hl,(posicion_puerta)
		
		ld		a,47
		call	pinta_en_pantalla
		
		ld		a,255
		
alegria_de_color:

		push	af
				
		ld		a,0
		ld		[COLLETRA],a											;aunque sólo quieras cambiar uno de los colores, tienes que volver a definir los otros dos para que te acepte un cambio
		ld		a,0
		ld		[COLFONDO],a
		ld		a,4
		ld		[COLBORDE],a
		call	COLOR
		ld		a,7
		ld		[COLBORDE],a
		call	COLOR
		ld		a,15
		ld		[COLBORDE],a
		call	COLOR
		ld		a,9
		ld		[COLBORDE],a
		call	COLOR
		
		pop		af
		dec		a
		cp		0
		jr.		nz,alegria_de_color
		
		ld		a,1
		ld		[COLBORDE],a
		call	COLOR
		
		ld		a,1
		ld		(ya_ha_cambiado_puerta),a
		
		ret

comprueba_estado_de_explosion:

		ld		a,(estado_de_explosion)
		cp		0
		ret		z
				
		ld		ix,atributos_sprite_general
		
		ld		a,(y_explosion)			;valor y**
		ld		(ix+12),a
			
		ld		a,(x_explosion)			;valor x**
		ld		(ix+13),a
		
		ld		a,(estado_de_explosion)	;SPRITE
		add		a,20
[2]		add		a,a
		ld		(ix+14),a
		
		ld		a,15					;COLOR EXPLOSION
		ld		(ix+15),a
		
		ld		a,(contador_retardo_explosion)
		inc		a
		ld		(contador_retardo_explosion),a
		cp		5
		ret		nz
		xor		a
		ld		(contador_retardo_explosion),a
		ld		a,(estado_de_explosion)
		inc		a
		ld		(estado_de_explosion),a
		cp		4
		jr.		z,finalizamos_la_explosion
		
		ret
		
finalizamos_la_explosion:
		
		ld		ix,atributos_sprite_general
		
		xor		a
		ld		(estado_de_explosion),a
		ld		(ix+12),a
		ld		(ix+13),a
		ld		(ix+15),a
		ld		a,24*4
		ld		(ix+14),a

		ret

puntuacion_vidas_fase:
		
		ld		a,(vidas_prota)						;pinta vidas
		
		add		a,192
		ld		[#eeee],a
		ld		hl,#eeee
		ld		de,#1803
		ld		bc,1
		call	GRABAVRAM
		
		ld		a,(fase_en_la_que_esta)				;pinta fase
		cp		10
		call	nc,fase_superior_a_diez
		
		add		a,192
		ld		[#eeee],a
		ld		hl,#eeee
		ld		de,#1816
		ld		bc,1
		call	GRABAVRAM
								
		ld		a,(cuenta_puntos_o_no)				;decide si pasa a poner puntos
		cp		0
		ret		z
				
		ld		a,(cuanto_sumamos_a_score)
		ld		b,a
		ld		a,(score)
		add		a,b
		ld		(score),a
		xor		a
		ld		(cuanto_sumamos_a_score),a
		ld		a,(score)
		ld		b,a
		ld		a,(contador_para_puntuacion)
		cp		b
		jr.		nz,rutina_de_puntos
		xor		a
		ld		(cuenta_puntos_o_no),a
		ret

fase_superior_a_diez:

		sub		10
		
		push	af
		
		ld		a,193
		ld		[#eeee],a
		ld		hl,#eeee
		ld		de,#1815
		ld		bc,1
		call	GRABAVRAM
		
		pop		af
		
		ret
		
rutina_de_puntos:

		ld		a,(contador_para_puntuacion)
		inc		a
		ld		(contador_para_puntuacion),a
				
		ld		a,(posicion_del_punto_unidades)
		inc		a
		ld		(posicion_del_punto_unidades),a
		cp		202
		call	z,resetea_los_numeros
			
		jr.		termina_de_contar_puntuacion
		
resetea_los_numeros:
		
		ld		a,192								;limpia unidades
		ld		(posicion_del_punto_unidades),a
		
		ld		a,(posicion_del_punto_decenas)		;aumenta decenas
		inc		a
		ld		(posicion_del_punto_decenas),a		
		cp		202									;comprueba decenas
		ret		nz

		ld		a,192								;limpia decenas
		ld		(posicion_del_punto_decenas),a
		
		ld		a,(posicion_del_punto_centenas)		;aumenta centenas
		inc		a
		ld		(posicion_del_punto_centenas),a
		cp		202									;comprueba centenas
		ret		nz

		ld		a,192								;limpia centenas
		ld		(posicion_del_punto_centenas),a
		
		ld		a,(posicion_del_punto_millares)		;aumenta millares
		inc		a
		ld		(posicion_del_punto_millares),a
		cp		202									;comprueba millares
		ret		nz			
		
		ld		a,192								;limpia millares
		ld		(posicion_del_punto_millares),a
		
		ret
		
termina_de_contar_puntuacion:

		ld		a,(posicion_del_punto_millares)
		ld		[#eeee],a
		ld		hl,#eeee
		ld		de,#180b
		ld		bc,1
		call	GRABAVRAM
		
		ld		a,(posicion_del_punto_centenas)
		ld		[#eeee],a
		ld		hl,#eeee
		ld		de,#180c
		ld		bc,1
		call	GRABAVRAM
		
		ld		a,(posicion_del_punto_decenas)
		ld		[#eeee],a
		ld		hl,#eeee
		ld		de,#180d
		ld		bc,1
		call	GRABAVRAM
		
		ld		a,(posicion_del_punto_unidades)
		ld		[#eeee],a
		ld		hl,#eeee
		ld		de,#180e
		ld		bc,1
		call	GRABAVRAM
				
		ret

ha_saltado:

		ld		a,(dir_prota)
		cp		0
		jr.		z,salta_hacia_la_derecha
		cp		1
		jr.		z,salta_hacia_la_izquierda
		
salta_hacia_la_derecha:

		ld		a,1
		ld		(estado_de_salto),a
		ret

salta_hacia_la_izquierda:

		ld		a,31
		ld		(estado_de_salto),a
		ret

salta_sube:
		
		call	dieciseis_quince
		call	get_bloque_en_X_Y
		
		cp		31
		jr.		c,la_y_a_la_derecha
		
		
		call	uno_menos_cuatro
		call	get_bloque_en_X_Y
		
		cp		31
		jr.		c,resetea_el_salto
		
		ld		a,[px]
		add		1
		ld		[px],a

la_y_a_la_derecha:

		ld		a,[py]
		sub		a,4
		ld		[py],a
		
salta_resolucion:

		ld		a,(estado_de_salto)
		inc		a
		ld		(estado_de_salto),a
		cp		21
		jr.		z,resetea_el_salto
		cp		51
		jr.		z,resetea_el_salto
		ret

resetea_el_salto:

		xor		a
		ld		(estado_de_salto),a
		ld		a,5
		ld		(cont_no_salta_dos_seguidas),a
		ret
		
salta_sube_izquierda:		
		
		call	menos_uno_quince
		call	get_bloque_en_X_Y
		
		cp		31
		jr.		c,la_y_a_la_izquierda
		
		ld		a,[px]					;mira si tiene techo
		dec		a														
		ld		d,a
		ld		a,[py]
		sub		4
		ld		e,a
		call	get_bloque_en_X_Y
		
		cp		31
		jr.		c,resetea_el_salto
		
		ld		a,[px]
		dec		a
		ld		[px],a

la_y_a_la_izquierda:
		
		ld		a,[py]
		sub		a,4
		ld		[py],a
		
salta_sigue:
		
		call	dieciseis_quince
		call	get_bloque_en_X_Y
		
		cp		31
		jr.		c,resetea_el_salto
		
		ld		a,[px]
		add		1
		ld		[px],a
		
		jr.		salta_resolucion

salta_sigue_izquierda:

		call	menos_uno_quince
		call	get_bloque_en_X_Y
		
		cp		31
		jr.		c,resetea_el_salto
		
		ld		a,[px]
		dec		a
		ld		[px],a
		
		jr.		salta_resolucion

salta_baja:

		call	dieciseis_dieciseis
		call	get_bloque_en_X_Y
		
		cp		31
		jr.		c,resetea_el_salto
				
		ld		a,[px]					;mira si tiene suelo
		add		16														
		ld		d,a
		ld		a,[py]
		add		19
		ld		e,a
		call	get_bloque_en_X_Y
		
		cp		31
		jr.		c,resetea_el_salto
		
		ld		a,[px]
		add		1
		ld		[px],a
		
		ld		a,[py]
		add		4
		ld		[py],a
		
		jr.		salta_resolucion
		
salta_baja_izquierda:

		call	menos_uno_dieciseis
		call	get_bloque_en_X_Y
		
		cp		31
		jr.		c,resetea_el_salto
		
		ld		a,[px]					;mira si tiene suelo
		dec		a														
		ld		d,a
		ld		a,[py]
		add		19
		ld		e,a
		call	get_bloque_en_X_Y
		
		cp		31
		jr.		c,resetea_el_salto
		
		ld		a,[px]
		dec		a
		ld		[px],a
		
		ld		a,[py]
		add		4
		ld		[py],a
		
		jr.		salta_resolucion

animacion_entre_fases:

		call limpia_sprites
		
		ld		a,255
					
quemando_al_prota:
		
		ld		ix,atributos_sprite_general
		
		push	af
		ld		a,(py)
		ld		(ix),a
		ld		(ix+4),a
		ld		a,51*4
		ld		(ix+2),a
		ld		a,52*4
		ld		(ix+6),a
				
		call	atributos_sprites
		ld		a,255
		
rutina_espera_quemando_1:
				
		dec		a
		cp		0
		jr.		nz,rutina_espera_quemando_1	
		
		ld		a,11													;efecto sonoro de quemar
		call	efecto_sonido
		
		ld		ix,atributos_sprite_general
		
		ld		a,53*4
		ld		(ix+2),a
		ld		a,54*4
		ld		(ix+6),a
				
		call	atributos_sprites		
		ld		a,255
		
rutina_espera_quemando_2:
			
		dec		a
		cp		0
		jr.		nz,rutina_espera_quemando_2	
		
		pop		af
		dec		a
		cp		0
		jr.		nz,quemando_al_prota
		
		call	limpia_sprites
		
		ld		a,(fase_en_la_que_esta)
		inc		a
		ld		(fase_en_la_que_esta),a
		
		call	puntuacion_vidas_fase
		
		ld		a,128
		ld		(py),a
		ld		a,24
		ld		(px),a
		
		call	DISSCR		
		ld		hl,entre_fases											;las dos puertas entre fases
		ld		de,#1820
		call	depack_VRAM
		
		ld		a,(idioma)
		cp		0
		jr.		nz,rutina_pone_consejo
		
		ld		hl,camino_a
		ld		de,#18e2
		ld		bc,28
		call	GRABAVRAM
		
rutina_pone_consejo:		
		
		ld		a,(fase_en_la_que_esta)
		cp		2
		jr.		z,consejos_fase_2
		cp		3
		jr.		z,consejos_fase_3
		cp		5
		jr.		z,consejos_fase_5
		cp		7
		jr.		z,consejos_fase_7
		cp		10
		jr.		z,consejos_fase_10
		
		jr.		rutina_espera_quemando_2_cont

consejos_fase_2:
		
		ld		a,(idioma)
		cp		0
		jr.		z,consejo_esp_fase_2

consejo_ing_fase_2:

		ld		hl,advice_2
		ld		de,#1aa7
		ld		bc,18
		call	GRABAVRAM
		
		jr.		rutina_espera_quemando_2_cont

consejo_esp_fase_2:
				
		ld		hl,consejo_2
		ld		de,#1aa7
		ld		bc,18
		call	GRABAVRAM
		
		jr.		rutina_espera_quemando_2_cont

consejos_fase_3:
		
		ld		a,(idioma)
		cp		0
		jr.		z,consejo_esp_fase_3

consejo_ing_fase_3:

		ld		hl,advice_3
		ld		de,#1aa1
		ld		bc,95
		call	GRABAVRAM
		
		jr.		rutina_espera_quemando_2_cont

consejo_esp_fase_3:
				
		ld		hl,consejo_3
		ld		de,#1aa1
		ld		bc,95
		call	GRABAVRAM
		
		jr.		rutina_espera_quemando_2_cont
		
consejos_fase_5:
		
		ld		a,(idioma)
		cp		0
		jr.		z,consejo_esp_fase_5

consejo_ing_fase_5:

		ld		hl,advice_5
		ld		de,#1aa1
		ld		bc,30
		call	GRABAVRAM
		
		jr.		rutina_espera_quemando_2_cont

consejo_esp_fase_5:
				
		ld		hl,consejo_5
		ld		de,#1aa1
		ld		bc,30
		call	GRABAVRAM
		
		jr.		rutina_espera_quemando_2_cont
						
consejos_fase_7:
		
		ld		a,(idioma)
		cp		0
		jr.		z,consejo_esp_fase_7

consejo_ing_fase_7:

		ld		hl,advice_7
		ld		de,#1aa1
		ld		bc,30
		call	GRABAVRAM
		
		jr.		rutina_espera_quemando_2_cont

consejo_esp_fase_7:
				
		ld		hl,consejo_7
		ld		de,#1aa1
		ld		bc,30
		call	GRABAVRAM
		
		jr.		rutina_espera_quemando_2_cont

consejos_fase_10:
		
		ld		a,(idioma)
		cp		0
		jr.		z,consejo_esp_fase_10

consejo_ing_fase_10:

		ld		hl,advice_10
		ld		de,#1aa1
		ld		bc,30
		call	GRABAVRAM
		
		jr.		rutina_espera_quemando_2_cont

consejo_esp_fase_10:
				
		ld		hl,consejo_10
		ld		de,#1aa1
		ld		bc,30
		call	GRABAVRAM
		
		jr.		rutina_espera_quemando_2_cont
								
rutina_espera_quemando_2_cont:

		call	ENASCR
		
		call	activa_musica_entre_fases
				
		ld		ix,atributos_sprite_general
				
paseito_entre_fases:		
		
[2]		halt
		
		ld		a,8
		ld		(ix+7),a
		ld		a,1
		ld		(ix+3),a
		ld		a,9
		ld		(ix+11),a
		
		ld		a,(py)
		ld		(ix),a
		add		a,7
		ld		(ix+4),a
		sub		a,16
		ld		(ix+8),a
		xor		a
		ld		(ix+2),a
		add		a,4
		ld		(ix+6),a
		add		a,4
		ld		(ix+10),a
		ld		a,(px)
		add		a,2
		ld		(ix+1),a
		ld		(ix+5),a
		ld		(ix+9),a
		ld		(px),a
		
		call	atributos_sprites
		
[2]		halt
		
		ld		a,12
		ld		(ix+2),a
		add		a,4
		ld		(ix+6),a
		add		a,4
		ld		(ix+10),a
		ld		a,(px)
		add		a,2
		ld		(px),a
		ld		(ix+1),a
		ld		(ix+5),a
		ld		(ix+9),a
		
		call	atributos_sprites
		
		ld		a,(px)
		cp		222
		jr.		c,paseito_entre_fases
				
		call	limpia_sprites
				
		ret	

movimiento_serpientes:
		
		ld		ix,atributos_sprite_general
		
analiza_serpiente_1:
		
		ld		a,(serp1)
		cp		0
		jp.		z,analiza_serpiente_2
		
		ld		iy,variables_serpiente_1
		
		call	rutina_de_movimiento_serpientes
			
detalla_atributos_serp_1:

		ld		ix,atributos_sprite_general

		ld		(ix+18),a
		ld		(ix+22),b
		ld		a,(iy)
		ld		(ix+17),a
		ld		(ix+21),a
		ld		a,(iy+1)
		ld		(ix+16),a
		ld		(ix+20),a
		ld		a,(iy+4)
		ld		(ix+19),a
		ld		a,1
		ld		(ix+23),a
		
analiza_serpiente_2:

		
		ld		a,(serp2)
		cp		0
		jp.		z,analiza_serpiente_3
		
		ld		iy,variables_serpiente_2

		call	rutina_de_movimiento_serpientes
			
detalla_atributos_serp_2:

		ld		ix,atributos_sprite_general
		
		ld		(ix+26),a
		ld		(ix+30),b
		ld		a,(iy)
		ld		(ix+25),a
		ld		(ix+29),a
		ld		a,(iy+1)
		ld		(ix+24),a
		ld		(ix+28),a
		ld		a,(iy+4)
		ld		(ix+27),a
		ld		a,1
		ld		(ix+31),a
		
analiza_serpiente_3:		
		
		ld		a,(serp3)
		cp		0
		jp.		z,analiza_serpiente_4
		
		ld		iy,variables_serpiente_3
		
		call	rutina_de_movimiento_serpientes
			
detalla_atributos_serp_3:

		ld		ix,atributos_sprite_general
		
		ld		(ix+34),a
		ld		(ix+38),b
		ld		a,(iy)
		ld		(ix+33),a
		ld		(ix+37),a
		ld		a,(iy+1)
		ld		(ix+32),a
		ld		(ix+36),a
		ld		a,(iy+4)
		ld		(ix+35),a
		ld		a,1
		ld		(ix+39),a
		
analiza_serpiente_4:
	
		ld		a,(serp4)
		cp		0
		ret		z
		
		ld		iy,variables_serpiente_4
		
		call	rutina_de_movimiento_serpientes
			
detalla_atributos_serp_4:

		ld		ix,atributos_sprite_general
		
		ld		(ix+42),a
		ld		(ix+46),b
		ld		a,(iy)
		ld		(ix+41),a
		ld		(ix+45),a
		ld		a,(iy+1)
		ld		(ix+40),a
		ld		(ix+44),a
		ld		a,(iy+4)
		ld		(ix+43),a
		ld		a,1
		ld		(ix+47),a
		
		ret
		
rutina_de_movimiento_serpientes:
		
		ld		a,(iy+2)
		cp		0
		jr.		nz,suma_x_serpiente

resta_x_serpiente:

		ld		a,(iy+8)
		dec		a
		ld		(iy+8),a
		cp		0
		jr.		nz,pose_serp
		
		ld		a,(iy+7)
		ld		(iy+8),a
		
		ld		a,[iy]
		dec		a														
		ld		d,a
		ld		a,[iy+1]
		add		15
		ld		e,a
		call	get_bloque_en_X_Y
		
		cp		31
		jr.		c,serp_cambia_paso_a_derecha
		
		ld		a,(iy)
		dec		a
		ld		(iy),a
		jr.		pose_serp
		
suma_x_serpiente:

		ld		a,(iy+8)
		dec		a
		ld		(iy+8),a
		cp		0
		jr.		nz,pose_serp
		
		ld		a,(iy+7)
		ld		(iy+8),a
		
		ld		a,[iy]
		add		16														
		ld		d,a
		ld		a,[iy+1]
		add		15
		ld		e,a
		call	get_bloque_en_X_Y
		
		cp		31
		jr.		c,serp_cambia_paso_a_izquierda
		
		ld		a,(iy)
		inc		a
		ld		(iy),a
		jr.		pose_serp
		
serp_cambia_paso_a_derecha:

		ld		a,1
		ld		(iy+2),a
		jr.		pose_serp
		
serp_cambia_paso_a_izquierda:

		xor		a
		ld		(iy+2),a
		jr.		pose_serp

pose_serp:

		ld		a,(iy+6)
		dec		a
		ld		(iy+6),a
		cp		0
		jr.		nz,elegir_sprite_serp

		ld		a,(iy+5)
		ld		(iy+6),a
		
		ld		a,(iy+3)
		cp		0
		jr.		nz,paso_2_serp
		
paso_1_serp:

		ld		a,1
		ld		(iy+3),a
		
		jr.		elegir_sprite_serp
		
paso_2_serp:

		xor		a
		ld		(iy+3),a
		
elegir_sprite_serp:

		ld		a,(iy+2)
		cp		0
		jr.		nz,suma_direccion_1_serp
		
suma_direccion_0_serp:

		ld		a,(iy+3)
		cp		0
		jr.		nz,suma_paso_01_serp
		
suma_paso_00_serp:

		ld		a,25*4
		ld		b,29*4
		ret

suma_paso_01_serp:
		
		ld		a,26*4
		ld		b,30*4
		ret
		
suma_direccion_1_serp:

		ld		a,(iy+3)
		cp		0
		jr.		nz,suma_paso_11_serp

suma_paso_10_serp:

		ld		a,27*4
		ld		b,31*4
		ret

suma_paso_11_serp:

		ld		a,28*4
		ld		b,32*4
		ret	

seis_diez:

		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		add		6
		ld		d,a
		ld		a,[py]
		add		10
		ld		e,a
		
		ret	
		
dos_diez:

		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		add		2
		ld		d,a
		ld		a,[py]
		add		10
		ld		e,a
		
		ret		

menos_dos_diez:

		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		sub		2
		ld		d,a
		ld		a,[py]
		add		10
		ld		e,a
		
		ret		

seis_dos:

		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		add		6
		ld		d,a
		ld		a,[py]
		add		2
		ld		e,a
		
		ret

cero_cero:
		
		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		ld		d,a
		ld		a,[py]
		ld		e,a
		
		ret

siete_diecisiete:
		
		ld		a,[px]
		add		7					;para buffer y vram moviendo 6 y 10						
		ld		d,a
		ld		a,[py]
		add		17
		ld		e,a
		
		ret
menos_uno_dieciseis:
		
		ld		a,[px]
		dec		a					;para buffer y vram moviendo 6 y 10						
		ld		d,a
		ld		a,[py]
		add		16
		ld		e,a
		
		ret
		
dieciseis_dieciseis:
		
		ld		a,[px]
		add		16					;para buffer y vram moviendo 6 y 10						
		ld		d,a
		ld		a,[py]
		add		16
		ld		e,a
		
		ret
		
menos_dos_dieciocho:
		
		ld		a,[px]
		sub		2					;para buffer y vram moviendo -2 y 18						
		ld		d,a
		ld		a,[py]
		add		18
		ld		e,a
		
		ret
				
catorce_diez:
		
		ld		a,[px]
		add		14					;para buffer y vram moviendo 14 y 10						
		ld		d,a
		ld		a,[py]
		add		10
		ld		e,a
		
		ret

catorce_dos:
		
		ld		a,[px]
		add		14					;para buffer y vram moviendo 14 y 22						
		ld		d,a
		ld		a,[py]
		add		2
		ld		e,a
		
		ret
				
catorce_dieciocho:
		
		ld		a,[px]
		add		14					;para buffer y vram moviendo 14 y 18						
		ld		d,a
		ld		a,[py]
		add		18
		ld		e,a
		
		ret
		
veinte_diez:
		
		ld		a,[px]
		add		20					;para buffer y vram moviendo 6 y 10						
		ld		d,a
		ld		a,[py]
		add		10
		ld		e,a
		
		ret

veintidos_diez:
		
		ld		a,[px]
		add		22					;para buffer y vram moviendo 6 y 10						
		ld		d,a
		ld		a,[py]
		add		10
		ld		e,a
		
		ret
				
menos_diez_diez:
		
		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		sub		10
		ld		d,a
		ld		a,[py]
		add		10
		ld		e,a
		
		ret
		
seis_dieciocho:
		
		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		add		6
		ld		d,a
		ld		a,[py]
		add		18
		ld		e,a
		
		ret

menos_diez_dieciocho:
		
		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		sub		10
		ld		d,a
		ld		a,[py]
		add		18
		ld		e,a
		
		ret

tres_quince:
		
		ld		a,[px]					;para buffer y vram moviendo 3 y 15	
		add		3
		ld		d,a
		ld		a,[py]
		add		15
		ld		e,a
		
		ret

tres_dos:
		ld		a,[px]					;para buffer y vram moviendo 3 y 2
		add		3
		ld		d,a
		ld		a,[py]
		add		2
		ld		e,a
		
		ret
				
cero_dieciocho:
		
		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		ld		d,a
		ld		a,[py]
		add		18
		ld		e,a
		
		ret
		
ocho_dieciocho:
		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		add		8
		ld		d,a
		ld		a,[py]
		add		18
		ld		e,a
		
		ret
		
ocho_uno:

		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		add		8
		ld		d,a
		ld		a,[py]
		inc		a
		ld		e,a
		
		ret
				
dieciseis_quince:

		ld		a,[px]					;para buffer y vram moviendo 16 y 15						
		add		16
		ld		d,a
		ld		a,[py]
		add		15
		ld		e,a
		
		ret

dieciseis_dos:

		ld		a,[px]					;para buffer y vram moviendo 16 y 2						
		add		16
		ld		d,a
		ld		a,[py]
		add		2
		ld		e,a
		
		ret
				
uno_menos_cuatro:

		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		inc		a
		ld		d,a
		ld		a,[py]
		sub		4
		ld		e,a
		
		ret
		
menos_uno_quince:

		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		dec		a
		ld		d,a
		ld		a,[py]
		add		15
		ld		e,a
		
		ret

menos_uno_dos:

		ld		a,[px]					;para buffer y vram moviendo -1 y 2						
		dec		a
		ld		d,a
		ld		a,[py]
		add		2
		ld		e,a
		
		ret

pinta_en_pantalla:

		ld		de,#1800				;borra de pantalla el cuchillo cogido
		add		hl,de
		push	hl
		ld		[#eeee],a
		ld		hl,#eeee
		pop		de
		ld		bc,1
		call	GRABAVRAM
		
		ret
				
efecto_sonido:
		
		ld		c,a
		call	ayFX_INIT
		ret
		
		;DESCOMPRESORES

depack_VRAM:		

		include "PL_VRAM_Depack_SJASM.asm"						; hl=ram/rom fuente de=vram destino

depack:

		include	"unpack.asm"									; hl=ram/rom fuente de=ram destino

		;la instrucción que dejaremos en lugar del gancho
		
nuestra_isr:

		call	PT3_ROUT												;envia los datos a los registros del PSG
		call	PT3_PLAY												;calcula el siguiente trozo de música que será enviado la próxima vez
		call	ayFX_PLAY												;calcula el siguiente trozo de efecto que será enviado la próxima vez
		jp		VIEJA_INTERR											;ahora se va a ejecutar la original que había en el gancho
		
		;gancho area salvada
		
		;MUSICA Y EFECTOS
		
		include 	"PT3-ROM_sjasm.asm"									;incluye el codigo del reproductor de PT3 (musica)
		include		"ayFX-ROM_sjasm.asm"								;incluye el codigo del reproductor AY (efectos)

CANCION:

	incbin		"SAXSOLOPLETTER.99"										;incluye la cancion de apertura desde el modo binario

SILENCIO:
	
	incbin		"MUTEPLETTER.99"										;para crear un mute a la música
	
MUSICA_GAMEOVER:

	incbin		"GAMEOVERPLETTER.99"									;música de game over
	
;MUSICA_FASES:

;	incbin		"FASESPLETTER.99"										;música de fases
	
EFECTOS_BANCO:

	incbin		"efectos.afb"											;incluye el banco de efectos

MUSICA_MUERTO:

	incbin		"MUERTOPLETTER.99"										;musica de muere
	
MUSICA_ENTRE_FASES:

	incbin		"ENTRE_FASESPLETTER.99"										;musica de muere
		
	;Variables del replayer... las coloco desde aqui.
	;mirar que hace la directiva MAP del SJASM
	map		#f000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;PT3 REPLAYER

PT3_SETUP:			#1	;set bit0 to 1, if you want to play without looping
					;bit7 is set each time, when loop point is passed
PT3_MODADDR:		#2
PT3_CrPsPtr:		#2
PT3_SAMPTRS:		#2
PT3_OrnPtrs:		#2
PT3_PDSP:			#2
PT3_CSP:			#2
PT3_PSP:			#2
PT3_PrNote:			#1
PT3_PrSlide:		#2
PT3_AdInPtA:		#2
PT3_AdInPtB:		#2
PT3_AdInPtC:		#2
PT3_LPosPtr:		#2
PT3_PatsPtr:		#2
PT3_Delay:			#1
PT3_AddToEn:		#1
PT3_Env_Del:		#1
PT3_ESldAdd:		#2
PT3_NTL3:			#2	; AND A / NOP (note table creator)

VARS:				#0

ChanA:				#29			;CHNPRM_Size
ChanB:				#29			;CHNPRM_Size
ChanC:				#29			;CHNPRM_Size

;GlobalVars
DelyCnt:			#1
CurESld:			#2
CurEDel:			#1
Ns_Base_AddToNs:	#0
Ns_Base:			#1
AddToNs:			#1

NT_:				#192	; Puntero a/tabla de frecuencias

AYREGS:				#0
VT_:				#14
EnvBase:			#2
VAR0END:			#0

T1_:				#0		
T_NEW_1:			#0
T_OLD_1:			#24
T_OLD_2:			#24
T_NEW_3:			#0
T_OLD_3:			#2
T_OLD_0:			#0
T_NEW_0:			#24
T_NEW_2:			#166
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;PT3 REPLAYER END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ayFX REPLAYER 
ayFX_MODE:			#1			; ayFX mode
ayFX_BANK:			#2			; Current ayFX Bank
ayFX_PRIORITY:		#1			; Current ayFX stream priotity
ayFX_POINTER:		#2			; Pointer to the current ayFX stream
ayFX_TONE:			#2			; Current tone of the ayFX stream
ayFX_NOISE:			#1			; Current noise of the ayFX stream
ayFX_VOLUME:		#1			; Current volume of the ayFX stream
ayFX_CHANNEL:		#1			; PSG channel to play the ayFX stream

	;IF (AYFXRELATIVE == 1 ) 
;ayFX_VT:	ds	2			; ayFX relative volume table pointer
	;ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ayFX REPLAYER END
																
;CONSTANTES

instru_caste:	incbin	"INSTRUCCIONES.DAT"
instru_ingle:	incbin	"INSTRUCTIONS.DAT"
pant_carga_til:	incbin	"PANTALLA_DE_CARGA_TILES.til"
pant_carga_col:	incbin	"PANTALLA_DE_CARGA_TILES.col"
pant_carga:		incbin	"PANTALLA_DE_CARGA.DAT"		
tiles_1:		incbin	"TILESFpletter.til"
colores_1:		incbin	"TILESFpletter.col"
fase_1:			incbin	"FASE_1_pletter.dat"
fase_2:			incbin	"FASE_2_pletter.dat"
fase_3:			incbin	"FASE_3_pletter.dat"
fase_4:			incbin	"FASE_4_pletter.dat"
fase_5:			incbin	"FASE_5_pletter.dat"
fase_6:			incbin	"FASE_6_pletter.dat"
fase_7:			incbin	"FASE_7_pletter.dat"
fase_8:			incbin	"FASE_8_pletter.dat"
fase_9:			incbin	"FASE_9_pletter.dat"
fase_10:		incbin	"FASE_10_pletter.dat"
FINAL:			incbin	"FINAL_TEMPLO.dat"

sanctuary_1:	db	242,224,237,226,243,244,224,241,248,255,192,193
sanctuary_2:	db	242,224,237,226,243,244,224,241,248,255,192,194
sanctuary_3:	db	242,224,237,226,243,244,224,241,248,255,192,195
sanctuary_4:	db	242,224,237,226,243,244,224,241,248,255,192,196
sanctuary_5:	db	242,224,237,226,243,244,224,241,248,255,192,197
sanctuary_6:	db	242,224,237,226,243,244,224,241,248,255,192,198
sanctuary_7:	db	242,224,237,226,243,244,224,241,248,255,192,199
sanctuary_8:	db	242,224,237,226,243,244,224,241,248,255,192,200
sanctuary_9:	db	242,224,237,226,243,244,224,241,248,255,192,201
sanctuary_10:	db	242,224,237,226,243,244,224,241,248,255,193,192

sanctuario_1:	db	242,224,237,243,244,224,241,232,238,255,192,193
sanctuario_2:	db	242,224,237,243,244,224,241,232,238,255,192,194
sanctuario_3:	db	242,224,237,243,244,224,241,232,238,255,192,195
sanctuario_4:	db	242,224,237,243,244,224,241,232,238,255,192,196
sanctuario_5:	db	242,224,237,243,244,224,241,232,238,255,192,197
sanctuario_6:	db	242,224,237,243,244,224,241,232,238,255,192,198
sanctuario_7:	db	242,224,237,243,244,224,241,232,238,255,192,199
sanctuario_8:	db	242,224,237,243,244,224,241,232,238,255,192,200
sanctuario_9:	db	242,224,237,243,244,224,241,232,238,255,192,201
sanctuario_10:	db	242,224,237,243,244,224,241,232,238,255,193,192

consejo_2:		db	195,253,225,238,236,225,224,242,253,210,253,193,253,242,244,228,235,238
consejo_3:		db	226, 238, 237, 3, 228, 235, 253, 209, 253, 241, 228, 239, 224, 241, 224, 253, 235, 224, 253, 228, 242, 226, 224, 235, 228, 241, 224, 253, 41, 42, 3
				db 	253, 253, 236, 238, 233, 224, 227, 238, 253, 237, 238, 253, 224, 241, 227, 228, 241, 224, 242, 251, 253, 253, 242, 228, 226, 224, 243, 228, 253, 213, 253, 253
				db 	253, 237, 238, 253, 243, 238, 227, 238, 242, 253, 235, 238, 242, 253, 236, 244, 241, 238, 242, 253, 242, 238, 237, 253, 232, 230, 244, 224, 235, 228, 242, 253
consejo_5:		db	224, 226, 243, 232, 245, 224, 253, 235, 224, 242, 253, 228, 242, 226, 224, 235, 228, 241, 224, 242, 253, 253, 242, 228, 226, 241, 228, 243, 224, 242, 224, 227,238
consejo_7:		db	228, 235, 253, 225, 238, 236, 225, 228, 241, 238, 253, 243, 228, 253, 236, 238, 233, 224, 241, 224, 253, 227, 228, 236, 224, 242, 232, 224, 227, 238
consejo_10:		db	228, 237, 226, 232, 228, 237, 227, 228, 253, 235, 224, 253, 235, 244, 249, 253, 239, 224, 241, 224, 253, 239, 238, 227, 228, 241, 253, 245, 228, 241
advice_2:		db	195,253,225,238,236,225,242,253,253,210,253,193,253,229,235,238,238,241
advice_3:		db	246, 232, 243, 231, 253, 209, 253, 253, 241, 228, 239, 224, 232, 241, 253, 253, 243, 231, 228, 253, 253, 235, 224, 227, 227, 228, 241, 253, 41, 42
				db 	253, 253, 246, 228, 243, 253, 248, 238, 244, 253, 226, 224, 237, 214, 243, 253, 225, 244, 241, 237, 251, 253, 225, 228, 253, 227, 241, 248, 253, 213, 253, 253
				db 	253, 237, 238, 243, 253, 224, 235, 235, 253, 253, 246, 224, 235, 235, 242, 253, 253, 224, 241, 228, 253, 253, 243, 231, 228, 253, 253, 242, 224, 236, 228, 253
advice_5:		db	224, 226, 243, 232, 245, 224, 243, 228, 253, 253, 243, 231, 228, 253, 253, 242, 228, 226, 241, 228, 243, 253, 253, 235, 224, 227, 227, 228, 241, 242
advice_7:		db	229, 232, 241, 228, 236, 224, 237, 253, 246, 232, 235, 235, 253, 246, 228, 243, 253, 248, 238, 244, 253, 243, 238, 238, 253, 253, 236, 244, 226, 231
advice_10:		db	243, 244, 241, 237, 253, 253, 238, 237, 253, 253, 243, 231, 228, 253, 253, 235, 232, 230, 231, 243, 253, 253, 243, 238, 253, 253, 253, 242, 228, 228

lo_has_logrado:	db	235,238,253,231,224,242,253,235,238,230,241,224,227,238,251,253,228,242,243,224,242,253,236,244,241,232,228,237,227,238,252
felicidades:	db	212,253,212,253,229,253,228,253,235,253,232,253,226,253,232,253,227,253,224,253,227,253,228,253,242,253,252,253,252,253
camino_a:		db	226,224,236,232,237,238,253,224,253,244,237,253,237,244,228,245,238,253,253,242,224,237,243,244,224,241,232,238
blanco:			incbin	"BLANCO_pletter.DAT"
entre_fases:	incbin	"ENTRESAN.DAT"
marcador:		incbin	"marcador_pletter.dat"
trofeos:		incbin	"trofeos_pletter.dat"
sprites:		incbin	"sprites_pletter.dat"

sprites2:		; --- BOMBERO DERECHA QUIETO
				; color 1
				DB $00,$03,$07,$1F,$04,$05,$06,$0D
				DB $08,$18,$1B,$0C,$0F,$07,$06,$03
				DB $00,$00,$90,$E0,$80,$00,$00,$00
				DB $80,$F0,$C0,$80,$80,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$03,$02,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 13
				DB $02,$07,$07,$04,$03,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; 
				; --- BOMBERO DERECHA ANDANDO
				; color 1
				DB $00,$00,$03,$07,$1F,$04,$05,$06
				DB $0D,$08,$18,$1B,$0C,$2F,$51,$00
				DB $00,$00,$00,$90,$E0,$80,$00,$00
				DB $00,$80,$F0,$C0,$80,$80,$40,$80
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$03,$02
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 13
				DB $00,$02,$07,$07,$04,$03,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; 
				; --- BOMBERO IZQUIERDA QUIETO
				; color 1
				DB $00,$00,$09,$07,$01,$00,$00,$00
				DB $01,$0F,$03,$01,$01,$00,$00,$00
				DB $00,$C0,$E0,$F8,$20,$A0,$60,$B0
				DB $10,$18,$D8,$30,$F0,$E0,$60,$C0
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$c0,$40,$00
				; color 13
sprites3:		DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $40,$e0,$e0,$20,$c0,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; 
				; --- BOMBERO IZQUIERDA ANDANDO
				; color 1
				DB $00,$00,$00,$09,$07,$01,$00,$00
				DB $00,$01,$0F,$03,$01,$01,$02,$01
				DB $00,$00,$C0,$E0,$F8,$20,$A0,$60
				DB $B0,$10,$18,$D8,$30,$F4,$8A,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$c0,$40
				; color 13
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$40,$e0,$e0,$20,$c0,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; 
				; --- BOMBERO SUBIENDO 1
				; color 1
				DB $00,$03,$0F,$03,$03,$31,$2A,$2C
				DB $20,$38,$17,$A0,$7E,$21,$00,$00
				DB $00,$C0,$F0,$C0,$C3,$85,$5A,$34
				DB $48,$90,$20,$10,$08,$E5,$16,$0C
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$04,$30,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$23,$00,$00,$00
				
				; color 13
sprites4:		DB $13,$1f,$07,$08,$1f,$01,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $c8,$b0,$60,$e0,$e0,$f0,$18,$08
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; 
				; --- BOMBERO SUBIENDO 2
				; color 1
				DB $00,$03,$0F,$03,$C3,$A1,$5A,$2C
				DB $12,$09,$04,$08,$10,$A7,$68,$30
				DB $00,$C0,$F0,$C0,$C0,$8C,$54,$34
				DB $04,$1C,$E8,$05,$7E,$84,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$c4,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$20,$0c,$00,$00
				; color 13
				DB $13,$0d,$06,$03,$07,$0f,$18,$10
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $c8,$f8,$e0,$10,$f8,$80,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				
				; --- CHORRO IZQUIERDA
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$10,$11,$02,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$40,$20,$00,$18,$00
				; color 15
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$01,$07,$0E,$0C,$1F,$7F,$FF
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$FC,$FF,$BC,$90,$F0,$E0,$F8
				; 
				; --- CHORRO DERECHA
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$02,$04,$00,$18,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$08,$88,$40,$00,$00,$00
				; color 15
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$3F,$FF,$3D,$09,$0F,$07,$1F
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$80,$E0,$70,$30,$F8,$FE,$FF

				; --- prota quieto derecha bomba
				; color 1
sprites5:		DB $07,$0F,$0D,$0C,$04,$05,$06,$09
				DB $08,$0C,$07,$09,$09,$05,$06,$03
				DB $00,$80,$40,$80,$80,$00,$00,$40
				DB $E0,$E0,$C0,$00,$00,$00,$00,$00
				; 
				; --- prota quieto derecha cuchillo
				; color 1
sprites9:		DB $07,$0F,$0D,$0C,$04,$05,$06,$09
				DB $08,$0C,$07,$09,$09,$05,$06,$03
				DB $00,$80,$40,$80,$80,$00,$00,$00
				DB $90,$A0,$C0,$00,$00,$00,$00,$00
				; 
				; --- prota andando derecha bomba
				; color 1
sprites6:		DB $00,$07,$0F,$0D,$0C,$04,$05,$06
				DB $09,$08,$08,$0B,$09,$2F,$54,$08
				DB $00,$00,$80,$40,$80,$80,$00,$00
				DB $40,$E0,$E0,$C0,$40,$20,$E8,$10
				; 
				; --- prota andando derecha cuchillo
				; color 1
sprites10:		DB $00,$07,$0F,$0D,$0C,$04,$05,$06
				DB $09,$08,$08,$0B,$09,$2F,$54,$08
				DB $00,$00,$80,$40,$80,$80,$00,$00
				DB $00,$90,$E0,$C0,$40,$20,$E8,$10
				; 
				; --- prota quieto izquierda bomba
				; color 1
sprites7:		DB $00,$01,$02,$01,$01,$00,$00,$02
				DB $07,$07,$03,$00,$00,$00,$00,$00
				DB $E0,$F0,$B0,$30,$20,$A0,$60,$90
				DB $10,$30,$E0,$90,$90,$A0,$60,$C0
				; 
				; --- prota quieto izquierda cuchillo
				; color 1
sprites11:		DB $00,$01,$02,$01,$01,$00,$00,$00
				DB $09,$05,$03,$00,$00,$00,$00,$00
				DB $E0,$F0,$B0,$30,$20,$A0,$60,$90
				DB $10,$30,$E0,$90,$90,$A0,$60,$C0
				; 
				; --- prota andando izquierda bomba
				; color 1
sprites8:		DB $00,$00,$01,$02,$01,$01,$00,$00
				DB $02,$07,$07,$03,$02,$04,$17,$08
				DB $00,$E0,$F0,$B0,$30,$20,$A0,$60
				DB $90,$10,$10,$D0,$90,$F4,$2A,$10
				; 
				; --- prota andando izquierda cuchillo
				; color 1
sprites12:		DB $00,$00,$01,$02,$01,$01,$00,$00
				DB $00,$09,$07,$03,$02,$04,$17,$08
				DB $00,$E0,$F0,$B0,$30,$20,$A0,$60
				DB $90,$10,$10,$D0,$90,$F4,$2A,$10

				; --- prota derecha quieto
				; color 1
sprites13:		DB $07,$0F,$0D,$0C,$04,$05,$06,$09
				DB $08,$08,$05,$09,$09,$05,$06,$03
				DB $00,$80,$40,$80,$80,$00,$00,$00
				DB $80,$80,$00,$00,$00,$00,$00,$00
				; 
				; --- prota derecha andando
				; color 1
sprites14		DB $00,$07,$0F,$0D,$0C,$04,$05,$06
				DB $09,$08,$08,$0A,$09,$2F,$54,$08
				DB $00,$00,$80,$40,$80,$80,$00,$00
				DB $00,$80,$80,$80,$40,$20,$E8,$10
				; 
				; --- prota izquierda quieto
				; color 1
sprites15:		DB $00,$01,$02,$01,$01,$00,$00,$00
				DB $01,$01,$00,$00,$00,$00,$00,$00
				DB $E0,$F0,$B0,$30,$20,$A0,$60,$90
				DB $10,$10,$A0,$90,$90,$A0,$60,$C0
				; 
				; --- prota izquierda andando
				; color 1
sprites16:		DB $00,$00,$01,$02,$01,$01,$00,$00
				DB $00,$01,$01,$01,$02,$04,$17,$08
				DB $00,$E0,$F0,$B0,$30,$20,$A0,$60
				DB $90,$10,$10,$50,$90,$F4,$2A,$10
				
				; --- petiso quieto
				; color 1
sprites_pet:	DB $01,$02,$04,$04,$0F,$10,$10,$0F
				DB $08,$10,$10,$10,$14,$0C,$13,$0C
				DB $C0,$30,$08,$08,$08,$90,$B0,$18
				DB $08,$44,$2C,$14,$04,$38,$E4,$38
				; color 4
				DB $00,$00,$00,$02,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$80,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 10
				DB $00,$00,$03,$01,$00,$00,$0E,$00
				DB $07,$0F,$0F,$0F,$0B,$03,$08,$00
				DB $00,$00,$C0,$60,$E0,$60,$40,$C0
				DB $E0,$B0,$C0,$E0,$E0,$00,$10,$00
				; color 11
				DB $00,$01,$00,$00,$00,$0F,$01,$00
				DB $00,$00,$00,$00,$00,$00,$04,$00
				DB $00,$C0,$30,$10,$10,$00,$00,$20
				DB $10,$08,$10,$08,$18,$C0,$08,$00
				; 
				; --- petiso salto
				; color 1
				DB $01,$02,$04,$04,$0F,$10,$10,$0F
				DB $08,$10,$10,$30,$48,$3C,$07,$00
				DB $C0,$30,$08,$08,$08,$96,$B9,$02
				DB $04,$1C,$04,$0C,$12,$3C,$C0,$00
				; color 4
				DB $00,$00,$00,$02,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$80,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 10
				DB $00,$00,$03,$01,$00,$08,$0E,$00
				DB $07,$0F,$0F,$0F,$27,$03,$00,$00
				DB $00,$00,$C0,$60,$E0,$60,$44,$F8
				DB $F0,$E0,$F0,$E0,$C8,$00,$00,$00
				; color 11
				DB $00,$01,$00,$00,$00,$07,$01,$00
				DB $00,$00,$00,$00,$10,$00,$00,$00
				DB $00,$C0,$30,$10,$10,$00,$02,$04
				DB $08,$00,$08,$10,$24,$C0,$00,$00

game_over:		db	230,224,236,228,253,253,238,245,228,241
se__acabo:		db	242,228,253,253,253,224,226,224,225,238
pause:			db	239,224,244,242,228
ladrillos:		db	20,20,20,20,20			;ladrillos en la zona donde se escribe el pause


										
empresa:		db	28,"CARAMBALAN STUDIOS  PRESENTS"			;PANTALLA DE MENU
empresa_e:		db	28,"CARAMBALAN STUDIOS  PRESENTA"
titulo_1:		db	224,"bkc  f  f bklc bc  f   f  f  baca a  l  a k  a kdc l   a  a be jkbe  a  k alme l k m   m  k dc  ldkc k  l lmkc m m a   l  a  dc m  l l  m m  a a dcm   k  l   dca  m dale g  g g  de   dale    alhme                           l"    
titulo_8:		db	32,"daalmakaklkamakamkakakamlakaalae"
mensaje:		db	4,"MENU"
teclado:		db	10,"- KEYBOARD"
mando:			db	10,"- JOYSTICK"
instrucciones:	db	10,"- LANGUAGE"
teclado_e:		db	9,"- TECLADO"
mando_e:		db	7,"- MANDO"
instruccion_e:	db	8,"- IDIOMA"
salir:			db	12,"- COVER PAGE"
salir_e:		db	9,"- PORTADA"
copyright:		db	27,"(C) CARAMBALAN STUDIOS 2018"

serp_1:			db	1,"n"
serp_2:			db	1,"o"
nada:			db	1," "

programacion:	db	12,"PROGRAMMING:"
musica:			db	6,"SONGS:"
agradec:		db	7,"THANKS:"
programacion_e:	db	13,"PROGRAMACION"
musica_e:		db	7,"MUSICA:"
agradec_e:		db	16,"AGRADECIMIENTOS:"
benja:			db	15,"BENJAMIN MIGUEL"
manu:			db	14,"MANUEL BARROSO"
ramon:			db	32,"IMANOK            RAMON CASTILLO"
fernando1:		db	32,"JORGE ROMERO     FERNANDO GARCIA"
fernando2:		db	32,"VICTOR MARTINEZ   FERNANDO LOPEZ"
felix:			db	32,"FELIX ESPINA          JORDI ORTE"
tromax:			db	22,"DAVID F.GISBERT TROMAX"
royal:			db	5,"ROYAL"
mano_derecha:	db	13,"MANO DERECHA:"
mano_derecha_e:	db	11,"RIGHT HAND:"

letras_A:		db	#7C,#82,#82,#FE,#82,#82,#44,#00				;DEFINICION DE LETRAS
letras_B:		db	#78,#84,#84,#F8,#84,#82,#7C,#00
letras_C:		db	#7C,#82,#80,#80,#80,#82,#7C,#00
letras_D:		db	#78,#84,#82,#82,#82,#84,#78,#00
letras_E:		db	#7C,#82,#80,#FC,#80,#82,#7C,#00
letras_F:		db	#7C,#82,#80,#FC,#80,#80,#40,#00
letras_G:		db	#7C,#82,#80,#80,#8C,#82,#7C,#00
letras_H:		db	#44,#82,#82,#FE,#82,#82,#44,#00
letras_I:		db	#7C,#92,#10,#10,#10,#92,#7C,#00
letras_J:		db	#7C,#92,#10,#0C,#02,#82,#7C,#00
letras_K:		db	#44,#82,#84,#F8,#84,#82,#44,#00
letras_L:		db	#40,#80,#80,#80,#80,#82,#7C,#00
letras_M:		db	#44,#BA,#92,#82,#82,#82,#44,#00
letras_N:		db	#44,#A2,#A2,#92,#8A,#8A,#44,#00
letras_O:		db	#7C,#82,#82,#82,#82,#82,#7C,#00
letras_P:		db	#7C,#82,#82,#FC,#80,#80,#40,#00
letras_Q:		db	#7C,#82,#82,#82,#9A,#8C,#7C,#00
letras_R:		db	#7C,#82,#82,#FC,#82,#82,#44,#00
letras_S:		db	#7C,#82,#80,#7C,#02,#82,#7C,#00
letras_T:		db	#7C,#92,#10,#10,#10,#10,#10,#00
letras_U:		db	#44,#82,#82,#82,#82,#82,#7C,#00
letras_V:		db	#44,#82,#82,#44,#44,#28,#10,#00
letras_W:		db	#44,#82,#82,#82,#92,#AA,#44,#00
letras_X:		db	#44,#82,#6C,#10,#6C,#82,#44,#00
letras_Y:		db	#44,#82,#82,#7C,#10,#10,#10,#00
letras_Z:		db	#7C,#82,#04,#38,#40,#82,#7C,#00

titulo_centro1:	db	#DF,#9A,#FF,#6D,#ED,#FF,#D9,#DF				;DEFINICION DE TITULO
titulo_no:		db	#07,#1A,#3F,#6D,#6D,#FF,#D9,#DF
titulo_ne:		db	#E0,#98,#FE,#6C,#EC,#FF,#D9,#FF
titulo_so:		db	#DF,#9A,#FF,#ED,#ED,#3F,#19,#07
titulo_se:		db	#DF,#9A,#FF,#6E,#EC,#FC,#D8,#E0
titulo_ru:		db	#18,#1A,#7E,#6C,#6C,#FF,#D9,#DF
titulo_rd:		db	#DF,#9A,#FF,#6C,#6C,#7E,#58,#18
titulo_rr:		db	#07,#1A,#7F,#6D,#ED,#7F,#59,#07
titulo_el:		db	#E0,#98,#FE,#6D,#ED,#FE,#D8,#E0
cabeza_serp:	db	#FF,#BD,#DB,#7E,#7E,#5A,#24,#18
titulo_centro2:	db	#9A,#6D,#D9,#ED,#FF,#DF,#9A,#DF
titulo_centro3:	db	#DF,#D9,#9A,#ED,#DF,#FF,#6D,#D9
titulo_centro4:	db	#ED,#FF,#6D,#9A,#6D,#FF,#D9,#DF
serpiente_1:	db	#0C,#1E,#38,#64,#60,#3C,#1E,#01
serpiente_2:	db	#18,#3C,#70,#68,#60,#3C,#1E,#01

parentesis_a:	db	#02,#04,#04,#08,#04,#04,#02,#00				;DEFINICION DE PARENTESIS, GUION Y PUNTO
parentesis_c:	db	#80,#40,#40,#20,#40,#40,#80,#00
guion:			db	#00,#00,#00,#82,#7C,#00,#00,#00
punto:			db	#00,#00,#00,#00,#00,#60,#60,#00

numero0:		db	#7C,#82,#A2,#92,#8A,#82,#7C,#00				;DEFINICION DE NÚMEROS Y DOS PUNTOS
numero1:		db	#00,#02,#02,#00,#02,#02,#00,#00
numero2:		db	#7C,#02,#02,#7C,#80,#80,#7C,#00
numero3:		db	#7C,#02,#02,#7C,#02,#02,#7C,#00
numero4:		db	#00,#82,#82,#7C,#02,#02,#00,#00
numero5:		db	#7C,#80,#80,#7C,#02,#02,#7C,#00
numero6:		db	#7C,#80,#80,#7C,#82,#82,#7C,#00
numero7:		db	#7C,#02,#02,#00,#02,#02,#00,#00
numero8:		db	#7C,#82,#82,#7C,#82,#82,#7C,#00
numero9:		db	#7C,#82,#82,#7C,#02,#02,#7C,#00
dospuntos:		db	#00,#00,#60,#60,#00,#60,#60,#00		
		
		ds		#C000-$								;FIN DE LA APLICACION
		
		
		;VARIABLES
idioma:							db	0							;0 ingles 1 castellano 2 catalán

petiso_que_toca:				db	0							;0 quieto 1 saltando
petisox:						db	0
petisoy:						db	0
espera_petiso:					db	0
espera_petiso_resta:			db	0
espera_petiso_resta_2:			db	0

VIEJA_INTERR:					ds	5							;le damos 5 bytes

estado_serp:					db	2							;ESTADO Y POSICION DE LA SERPIENTE DE SELECCION
y_serp:							db	16

stick_a_usar:					db	0							;valor de on stick y on strig para el juego

clock:							ds	2,3000						;variables de tiempo para intercalar menu y creditos

px:								db	0							;x prota
py:								db	0							;y prota
puede_cambiar_de_direccion:		db	0							;0 - no 1 - si
vidas_prota:					db	3
color_prota:					db	8							;7 - mojado		8 - seco
color_lineas_prota:				db	1							;1 - seco		14 - moojado
muerto:							db	1							;0 muerto - 1 vivo
fase_en_la_que_esta:			db	0							;fase en la que jugamos
estado_prota:					db	0							;0=quieto 1=andando 2=saltando 3=cayendo 4=subiendo/bajando
prev_dir_prota:					db	0							;hacia qué lado miraba antes el prota
salto_pulsado:					db	0							;para que no se pueda saltar mientras se cae o ya se está saltando
pasos_de_salto:					db	0							;si está saltando indica cuánto le queda para dejar de saltar
dir_prota:						db	0							;0 derecha 1 izquierda
paso:							db	0							;0 recto 1 andando 2 subiendo A 3 subiendo B
retard_anim:					db	0							;entre 0 y 9
atributos_sprite_general:		ds	48,0						;4 bytes y,x,patron,color PARA 4 SPRITES
tiene_objeto:					db	0							;0=no 1=bomba 2=cuchillo
px_salida:						db	0							;para recordar el punto de la puerta
py_salida:						db	0

x_explosion:					db	0
y_explosion:					db	0
estado_de_explosion:			db	0							;0=no 1,2,3 sprites 22,23,24
contador_retardo_explosion:		db	0

buffer_colisiones:				ds	736							;para leer las colisiones en RAM ya que es mucho más ràpido

estado_de_salto:				db	0							;1a8-9a20-21a28 salto derecha - 31a38-39a50-51a58 salto izquierda
mechero:						db	0							;0 no lo tienes 1 lo tienes
gasolina:						db	0							;0 no lo tienes 1 lo tienes
posicion_puerta:				ds	2							;posicion de la puerta
ya_ha_cambiado_puerta:			db	0							;0 está cerrada 1 está abierta
increm:							db	0							;para borrado concreto de vram

score:							ds	2							;puntos
contador_para_puntuacion:		ds	2							;compara con score para controlar los tiles a pintar en puntuacion
posicion_del_punto_unidades:	db	192							;control tile unidades
posicion_del_punto_decenas:		db	192							;control tile decenas
posicion_del_punto_centenas:	db	192							;control tile centenas
posicion_del_punto_millares:	db	192							;control tile unidades de millar
cuenta_puntos_o_no:				db	0							;0 no cuenta 1 si cuenta
cuanto_sumamos_a_score:			db	0							;para el contador evolutivo

variables_serpiente_1:			ds	9							;	0	-	serp_x_1
																;	1	-	serp_y_1
																;	2	-	serp_direcion_1
																;	3	-	serp_paso_1
																;	4	-	color_serp_1
																;	5	-	cont_retardo_serp_1
																;	6	-	cont_retardo_serp_1_mobil
																;	7	-	retardo_veloc_serp_1
																;	8	-	retardo_veloc_serp_1_mobil
variables_serpiente_2:			ds	9							;	0	-	serp_x_2
																;	1	-	serp_y_2
																;	2	-	serp_direcion_2
																;	3	-	serp_paso_2
																;	4	-	color_serp_2
																;	5	-	cont_retardo_serp_2
																;	6	-	cont_retardo_serp_2_mobil
																;	7	-	retardo_veloc_serp_2
																;	8	-	retardo_veloc_serp_2_mobil
variables_serpiente_3:			ds	9							;	0	-	serp_x_3
																;	1	-	serp_y_3
																;	2	-	serp_direcion_3
																;	3	-	serp_paso_3
																;	4	-	color_serp_3
																;	5	-	cont_retardo_serp_3
																;	6	-	cont_retardo_serp_3_mobil
																;	7	-	retardo_veloc_serp_3
																;	8	-	retardo_veloc_serp_3_mobil
variables_serpiente_4:			ds	9							;	0	-	serp_x_4
																;	1	-	serp_y_4
																;	2	-	serp_direcion_4
																;	3	-	serp_paso_4
																;	4	-	color_serp_4
																;	5	-	cont_retardo_serp_4
																;	6	-	cont_retardo_serp_4_mobil
																;	7	-	retardo_veloc_serp_4
																;	8	-	retardo_veloc_serp_4_mobil
colision_cuchillo_serp_real:	db	0							;	0	-	no hay colision, 1	-	si la hay															
serp1:							db	0							;serpiente 1 1-presente 0-ausente
serp2:							db	0							;serpiente 2 1-presente 0-ausente
serp3:							db	0							;serpiente 3 1-presente 0-ausente
serp4:							db	0							;serpiente 4 1-presente 0-ausente

cont_no_salta_dos_seguidas:		db	5							;para evitar el doble salto

pasamos_la_fase:				db	0							;0 estamos jugando 1 pasamos la fase

momento_lanzamiento:			db	0							;0 no lanza - 1 movm 1 - 2 mov 2 - 3 en órbita
contador_poses_lanzar:			db	5							;para retrasar las poses de lanzar
recordar_lo_que_habia:			ds	2							;guarda el valor de lo que borra si hay que pintar circunstancialmente una cosa
dir_cuchillo:					db	0							;la dirección hacia la que ba el cuchillo
cx:								db	0							;x cuchillo
cy:								db	0							;y cuchillo

escalera_activada:				db	0							;0 no - 1 si
posicion_escalera:				ds	2							;numero de tile que tiene que pintar de la escalera alternativa
contador_escalera:				db	50							;retardo para la construccion de la escalaera
limite_escalera					ds	2							;numero de tile en el que tiene que parar de construir


grifo_estado:					db	1							;0 - cerrado	1 - abierto


ESTADO_MUSICA:					db	1							;0 - apagada y 1 - encendida

vision_estado:					db	1							;0 - no ve nada y 1 - lo ve todo

colision_bombero_prota_real:		db	0							;	0	-	no hay colision,	1	-	si la hay			
bombero_1:						db	1							;0 - existe		1 - no existe
bombero_control:				ds	12							;	0	-	x					(0 - 255)
																;	1	-	y					(0 - 255)
																;	2	.	velocidad			(1 - 3)
																;	3	-	cada cuanto para	(0 - 255)
																;	4	-	tiempo que para		(0 - 255)
																;	5	-	paso				(0 - quieto	1 - andando)
																;	6	-	direccion			(0 - derecha)	1 - izquierda)
																;	7	-	en escalera			(0 - no	1 - si)
																;	8	-	tiempo para aparecer(0-255)
																;	9	-	retardo de velocidad(0-10)
																;	10	-	0 - decide subir 1 - decide bajar 2- decide no utilizar
																;	11	-	contador de reten para evitar que suba  y baje escaleras de forma seguida
																
SAXOLO:							ds	1841						;MUSICA INICIO
GAME_OVER:						ds	758							;MUSICA FIN PARTIDA
;FASES:							ds	2465						;MUSICA FASES
MUTE:							ds	117							;silencio musical								
MUERTO:							ds	292							;MUSICA MUERTO
ENTRE_FASES:					ds	615							;MUSICA ENTRE FASES
