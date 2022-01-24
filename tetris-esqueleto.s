#-------------------------------------
# -- Proyecto de Tetris Ensamblador -- 
#-------------------------------------

# ------------ Autores ---------------
# - Badar Tagmouti Abdoune (@badi_21)-
# - Pablo Manresa Soler    -
#-------------------------------------
        
	.data	

pantalla:
	.word	0
	.word	0
	.space	1024

campo:
	.word	0
	.word	0
	.space	1024

pieza_actual:
	.word	0
	.word	0
	.space	1024

pieza_actual_x:
	.word 0

pieza_actual_y:
	.word 0

imagen_auxiliar:
	.word	0
	.word	0
	.space	1024

pieza_jota:
	.word	2
	.word	3
	.ascii	"\0#\0###\0\0"
	.space	1016

pieza_ele:
	.word	2
	.word	3
	.ascii	"#\0#\0##\0\0"
	.space	1016

pieza_barra:
	.word	1
	.word	4
	.ascii	"####\0\0\0\0"
	.space	1016

pieza_zeta:
	.word	3
	.word	2
	.ascii	"##\0\0##\0\0"
	.space	1016

pieza_ese:
	.word	3
	.word	2
	.ascii	"\0####\0\0\0"
	.space	1016

pieza_cuadro:
	.word	2
	.word	2
	.ascii	"####\0\0\0\0"
	.space	1016

pieza_te:
	.word	3
	.word	2
	.ascii	"\0#\0###\0\0"
	.space	1016

piezas:
	.word	pieza_jota
	.word	pieza_ele
	.word	pieza_zeta
	.word	pieza_ese
	.word	pieza_barra
	.word	pieza_cuadro
	.word	pieza_te

acabar_partida:
	.byte	0

	.align	2
	
acabar_partida_completo:
	.byte 0
	
	.align 4
	
procesar_entrada.opciones:
	.byte	'x'
	.space	3
	.word	tecla_salir
	.byte	'j'
	.space	3
	.word	tecla_izquierda
	.byte	'l'
	.space	3
	.word	tecla_derecha
	.byte	'k'
	.space	3
	.word	tecla_abajo
	.byte	'i'
	.space	3
	.word	tecla_rotar
	.byte	't'
	.space	3
	.word	tecla_truco

str000:
	.asciiz		"Tetris\n\n 1 - Jugar\n 2 - Salir\n\nElige una opción:\n"
str001:
	.asciiz		"\n¡Adiós!\n"
str002:
	.asciiz		"\nOpción incorrecta. Pulse cualquier tecla para seguir.\n"
str003:
	.asciiz		"Puntuación:\0"
marcador:
	.word	0
marcador_string:
	.space 1024	# para imprimirlo
	
texto_fin:
	.word 19
	.word 4
	.ascii 		"+--------------+   "
	.ascii 		"|FIN DE PARTIDA|   "
	.ascii 		"|Toca una tecla|   "
	.ascii		"+--------------+   "
pieza_next:
	.word   0
	.word   0
	.space  1024
	
texto_next:
	.word 10
	.word 8
	.ascii 		"+--------+"
	.ascii 		"|  NEXT  |"
	.ascii 		"+--------+"
	.ascii		"|        |"
	.ascii		"|        |"
	.ascii		"|        |"
	.ascii		"|        |"
	.ascii 		"+--------+"
	
	.text	

imagen_pixel_addr:			# ($a0, $a1, $a2) = (imagen, x, y)
					# pixel_addr = &data + y*ancho + x
    	lw	$t1, 0($a0)		# $a0 = dirección de la imagen 
					# $t1 ← ancho
    	mul	$t1, $t1, $a2		# $a2 * ancho
    	addu	$t1, $t1, $a1		# $a2 * ancho + $a1
    	addiu	$a0, $a0, 8		# $a0 ← dirección del array data
    	addu	$v0, $a0, $t1		# $v0 = $a0 + $a2 * ancho + $a1
    	jr	$ra

imagen_get_pixel:			# ($a0, $a1, $a2) = (img, x, y)
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)		# guardamos $ra porque haremos un jal
	jal	imagen_pixel_addr	# (img, x, y) ya en ($a0, $a1, $a2)
	lbu	$v0, 0($v0)		# lee el pixel a devolver
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

imagen_set_pixel:
	#{modificacion
	addiu	$sp,$sp,-8
	sw	$s0,4($sp)
	sw	$ra,0($sp)
	
	move	$s0,$a3
	
	jal	imagen_pixel_addr
	
	sb	$s0,0($v0)
	
	lw	$ra,0($sp)
	lw	$s0,4($sp)
	addiu	$sp,$sp, 8
	
	jr	$ra
	
	
	#--]

imagen_clean:
	#[modificacion
	
	# apilamos
	addiu	$sp,$sp, -28
	sw	$s5,24($sp)
	sw	$s4,20($sp)
	sw	$s3,16($sp)
	sw	$s2,12($sp)
	sw	$s1,8($sp)
	sw	$s0,4($sp)
	sw	$ra,0($sp)
	
	move	$s4,$a0		# movemos img a $s4
	move 	$s5,$a1		# movemos el fondo a $a3
	
	# lee lo que tenemos en img.
	lw	$s2, 0($s4)	#imagen.ancho
	lw	$s3, 4($s4)	#imagen.alto
	
	li	$s0,0	# aqui y = 0
	
for1_imgClean:	
	bge	$s0,$s3,finfor1_imgClean	# y < img->alto
	li	$s1,0	# aqui x = 0
	
for2_imgClean:
	bge	$s1,$s2,finfor2_imgClean	# x < img->ancho
	
	move	$a0,$s4			# movemos img a $a0
	move	$a1,$s1			# movemos x a $a1
	move	$a2,$s0			# movemos y a $a2
	move	$a3,$s5			# movemos fondo a $a3
	jal	imagen_set_pixel
	
	addi	$s1,$s1,1	# x++
	j	for2_imgClean
finfor2_imgClean:

	addi	$s0,$s0,1	# y++
	j	for1_imgClean
finfor1_imgClean:	
	
	# desapilamos
	lw	$ra,0($sp)
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	lw	$s2,12($sp)
	lw	$s3,16($sp)
	lw	$s4,20($sp)
	lw	$s5,24($sp)
	addiu	$sp,$sp, 28
	
	jr	$ra
	#--]
        
imagen_init:
	#[modificacion
	
	# apilamos
	addiu	$sp,$sp, -12
	sw	$s1,8($sp)
	sw	$s0,4($sp)
	sw	$ra,0($sp)
	
	
	sw	$a1,0($a0)	# img->ancho = ancho;
	sw	$a2,4($a0)	# img->alto = alto;
	
	#lw	$s0, 0($a0)	#imagen.ancho
	#lw	$s1, 4($a0)	#imagen.alto
	
	#move	$s0,$a1		# img->ancho = ancho;
	#move	$s1,$a2		# img->alto = alto;
	
	
	
	move	$a1,$a3		# movemos el fondo a $a1 para poder llamar a la siguiente instruccion
	jal	imagen_clean
	
	# desapilamos
	lw	$ra,0($sp)
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	addiu	$sp,$sp, 12
	
	jr	$ra
	#--]

imagen_copy:
	#[modificacion
	
	# apilamos
	addiu	$sp,$sp, -36
	sw	$s7,32($sp)
	sw	$s6,28($sp)
	sw	$s5,24($sp)
	sw	$s4,20($sp)
	sw	$s3,16($sp)
	sw	$s2,12($sp)
	sw	$s1,8($sp)
	sw	$s0,4($sp)
	sw	$ra,0($sp)
	
	move	$s6,$a0		# en $s6 guardamos dst
	move	$s7,$a1		# en $s7 guardamos src
	
	lw	$s2,0($s7)	#src -> ancho en $s2
	lw	$s3,4($s7)	#src -> alto en $s3
	
	sw	$s2,0($s6)	#dst->ancho = src->ancho
	sw	$s3,4($s6)	#dst->alto = src->alto;
	
	li	$s4,0		# y = 0
for1_imgcopy:
	bge	$s4,$s3,finfor1_imgcopy
	
	
	li	$s5,0		# x = 0
for2_imgcopy:
	bge	$s5,$s2,finfor2_imgcopy
	
	move	$a0,$s7		# src en $a0
	move	$a1,$s5		# x en $a1
	move	$a2,$s4		# y en $a2
	
	jal 	imagen_get_pixel
	
	move	$a3,$v0		# v0 devuelve el valor de p
	move	$a2,$s4
	move	$a1,$s5
	move	$a0,$s6
	
	jal	imagen_set_pixel
	
	addi	$s5,$s5,1	# x++
	j	for2_imgcopy
finfor2_imgcopy:
	
	addi	$s4,$s4,1	# y++
	j	for1_imgcopy
finfor1_imgcopy:
	
	# desapilamos
	lw	$ra,0($sp)
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	lw	$s2,12($sp)
	lw	$s3,16($sp)
	lw	$s4,20($sp)
	lw	$s5,24($sp)
	lw	$s6,28($sp)
	lw	$s7,32($sp)
	addiu	$sp,$sp, 36
	
	jr	$ra
	#--]

imagen_print:				# $a0 = img
	addiu	$sp, $sp, -24
	sw	$ra, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	move	$s0, $a0
	lw	$s3, 4($s0)		# img->alto
	lw	$s4, 0($s0)		# img->ancho
        #  for (int y = 0; y < img->alto; ++y)
	li	$s1, 0			# y = 0
B6_2:	bgeu	$s1, $s3, B6_5		# acaba si y ≥ img->alto
	#    for (int x = 0; x < img->ancho; ++x)
	li	$s2, 0			# x = 0
B6_3:	bgeu	$s2, $s4, B6_4		# acaba si x ≥ img->ancho
	move	$a0, $s0		# Pixel p = imagen_get_pixel(img, x, y)
	move	$a1, $s2
	move	$a2, $s1
	jal	imagen_get_pixel
	move	$a0, $v0		# print_character(p)
	jal	print_character
	addiu	$s2, $s2, 1		# ++x
	j	B6_3
	#    } // for x
B6_4:	li	$a0, 10			# print_character('\n')
	jal	print_character
	addiu	$s1, $s1, 1		# ++y
	j	B6_2
	#  } // for y
B6_5:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$ra, 20($sp)
	addiu	$sp, $sp, 24
	jr	$ra

imagen_dibuja_imagen:
	#[modificacion
	
	# apilamos
	addiu	$sp,$sp, -36
	sw	$s7,32($sp)
	sw	$s6,28($sp)
	sw	$s5,24($sp)
	sw	$s4,20($sp)
	sw	$s3,16($sp)
	sw	$s2,12($sp)
	sw	$s1,8($sp)
	sw	$s0,4($sp)
	sw	$ra,0($sp)
	
	move	$s6,$a0		# en $s6 guardamos dst
	move	$s7,$a1		# en $s7 guardamos src
	
	move	$s0,$a2		#dst_x en $s0
	move	$s1,$a3		#dst_y en $s1
	
	lw	$s2,0($s7)	#src -> ancho en $s2
	lw	$s3,4($s7)	#src -> alto en $s3

	li	$s4,0		# y = 0
for1_imgdibuja:
	bge	$s4,$s3,finfor1_imgdibuja
	
	li	$s5,0		# x = 0
for2_imgdibuja:
	bge	$s5,$s2,finfor2_imgdibuja
	
	move	$a0,$s7		# src en $a0
	move	$a1,$s5		# x en $a1
	move	$a2,$s4		# y en $a2
	
	jal 	imagen_get_pixel
	
	move	$a3,$v0		# v0 devuelve el valor de p
if_imgdibuja:
	beqz	$a3,finif_imgdibuja
	
	move	$a2,$s1		#dst_y
	add	$a2,$a2,$s4	# dst_y + y
	move	$a1,$s0		#dst_x
	add	$a1,$a1,$s5	# dst_x + x
	move	$a0,$s6		#dst
	
	jal	imagen_set_pixel

finif_imgdibuja:	
	
	addi	$s5,$s5,1	# x++
	j	for2_imgdibuja
finfor2_imgdibuja:
	
	addi	$s4,$s4,1	# y++
	j	for1_imgdibuja
finfor1_imgdibuja:
	
	# desapilamos
	lw	$ra,0($sp)
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	lw	$s2,12($sp)
	lw	$s3,16($sp)
	lw	$s4,20($sp)
	lw	$s5,24($sp)
	lw	$s6,28($sp)
	lw	$s7,32($sp)
	addiu	$sp,$sp, 36
	
	jr	$ra
	#--]

imagen_dibuja_imagen_rotada:
	#[modificacion
	
	# apilamos
	addiu	$sp,$sp, -36
	sw	$s7,32($sp)
	sw	$s6,28($sp)
	sw	$s5,24($sp)
	sw	$s4,20($sp)
	sw	$s3,16($sp)
	sw	$s2,12($sp)
	sw	$s1,8($sp)
	sw	$s0,4($sp)
	sw	$ra,0($sp)
	
	move	$s6,$a0		# en $s6 guardamos dst
	move	$s7,$a1		# en $s7 guardamos src
	
	move	$s0,$a2		#dst_x en $s0
	move	$s1,$a3		#dst_y en $s1
	
	lw	$s2,0($s7)	#src -> ancho en $s2
	lw	$s3,4($s7)	#src -> alto en $s3

	li	$s4,0		# y = 0
for1_imgdibujrota:
	bge	$s4,$s3,finfor1_imgdibujrota
	
	li	$s5,0		# x = 0
for2_imgdibujrota:
	bge	$s5,$s2,finfor2_imgdibujrota
	
	move	$a0,$s7		# src en $a0
	move	$a1,$s5		# x en $a1
	move	$a2,$s4		# y en $a2
	
	jal 	imagen_get_pixel
	
	move	$t0,$v0		# el valor de imagen_get_pixel en $a3 -> p
if_imgdibujrota:
	beqz	$t0,finif_imgdibujrota
	
	add	$a1,$s0,$s3	# dst_x + src->alto
	addi	$a1,$a1,-1	# (dst_x + src->alto) - 1
	sub	$a1,$a1,$s4	# ((dst_x + src->alto) - 1) - y
	
	add	$a2,$s1,$s5	# dst_y + x
	move	$a0,$s6		# dst lo movemos a $a0
	move	$a3,$t0		# p
	
	jal	imagen_set_pixel		

finif_imgdibujrota:	
	
	add	$s5,$s5,1	# x++
	j	for2_imgdibujrota
finfor2_imgdibujrota:

	add	$s4,$s4,1	# y++
	j	for1_imgdibujrota
finfor1_imgdibujrota:
	
	# desapilamos
	lw	$ra,0($sp)
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	lw	$s2,12($sp)
	lw	$s3,16($sp)
	lw	$s4,20($sp)
	lw	$s5,24($sp)
	lw	$s6,28($sp)
	lw	$s7,32($sp)
	addiu	$sp,$sp, 36
	
	jr	$ra
	#--}

integer_to_string:
        move    $t0, $a1
       	beqz	$a0, B9_6
        abs     $t1, $a0
        li      $t3, 10
B9_3:   blez	$t1, B9_4
	div	$t1, $t3
	mflo	$t1	
	mfhi	$t2	
	addiu	$t2, $t2, '0'
        sb	$t2, 0($t0)
	addiu	$t0, $t0, 1
	j	B9_3
B9_4:	bgez	$a0, B9_7
	li	$t2, '-'
	sb	$t2, 0($t0)
	addiu	$t0, $t0, 1
	j	B9_7
B9_6:	li	$t2, '0'
	sb	$t2, 0($t0)
	addiu	$t0, $t0, 1
B9_7:	sb	$zero, 0($t0)
	addiu	$t0, $t0, -1
B9_9:   ble     $t0, $a1, B9_10
        lbu	$t2, 0($a1)
	lbu	$t3, 0($t0)
	sb	$t3, 0($a1)
	sb	$t2, 0($t0)
	addiu	$t0, $t0, -1
	addiu	$a1, $a1, 1
	j       B9_9
B9_10:	jr	$ra

pieza_aleatoria:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	li	$a0, 0
	li	$a1, 7
	jal	random_int_range	# $v0 ← random_int_range(0, 7)
	sll	$t1, $v0, 2
	la	$v0, piezas
	addu	$t1, $v0, $t1		# $t1 = piezas + $v0*4
	lw	$v0, 0($t1)		# $v0 ← piezas[$v0]
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

actualizar_pantalla:
	addiu	$sp, $sp, -12
	sw	$ra, 8($sp)
	sw	$s2, 4($sp)
	sw	$s1, 0($sp)
	
	la	$s2, campo
	la	$a0, pantalla
	li	$a1, ' '
	jal	imagen_clean		# imagen_clean(pantalla, ' ')
        # for (int y = 0; y < campo->alto; ++y) {
	li	$s1, 0			# y = 0
	jal	imprimir_marcador
B10_2:	lw	$t1, 4($s2)		# campo->alto
	bge	$s1, $t1, B10_3		# sigue si y < campo->alto
	la	$a0, pantalla
	li	$a1, 0                  # pos_campo_x - 1
	addi	$a2, $s1, 2             # y + pos_campo_y
	li	$a3, '|'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, 0, y, '|')
	la	$a0, pantalla
	lw	$t1, 0($s2)		# campo->ancho
	addiu	$a1, $t1, 1		# campo->ancho + 1
	addiu	$a2, $s1, 2             # y + pos_campo_y
	li	$a3, '|'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, campo->ancho + 1, y, '|')
        addiu	$s1, $s1, 1		# ++y
        j       B10_2
        # } // for y
	# for (int x = 0; x < campo->ancho + 2; ++x) { 
B10_3:	li	$s1, 0			# x = 0
B10_5:  lw	$t1, 0($s2)		# campo->ancho
        addiu   $t1, $t1, 2             # campo->ancho + 2
        bge	$s1, $t1, B10_6		# sigue si x < campo->ancho + 2
	la	$a0, pantalla
	move	$a1, $s1                # pos_campo_x - 1 + x
        lw	$t1, 4($s2)		# campo->alto
	addiu	$a2, $t1, 2		# campo->alto + pos_campo_y
	li	$a3, '-'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, x, campo->alto + 1, '-')
	addiu	$s1, $s1, 1		# ++x
	j       B10_5
        # } // for x
B10_6:	la	$a0, pantalla
	move	$a1, $s2
	li	$a2, 1                  # pos_campo_x
	li	$a3, 2                  # pos_campo_y
	jal	imagen_dibuja_imagen	# imagen_dibuja_imagen(pantalla, campo, 1, 2)
	la	$a0, pantalla
	la	$a1, pieza_actual
	lw	$t1, pieza_actual_x
	addiu	$a2, $t1, 1		# pieza_actual_x + pos_campo_x
	lw	$t1, pieza_actual_y
	addiu	$a3, $t1, 2		# pieza_actual_y + pos_campo_y
	jal	imagen_dibuja_imagen	# imagen_dibuja_imagen(pantalla, pieza_actual, pieza_actual_x + pos_campo_x, pieza_actual_y + pos_campo_y)
	jal	clear_screen		# clear_screen()
	
	la	$a0, pantalla
	la	$a1, texto_next	
	li	$a2, 16			# eje x
	li	$a3, 3			# eje y
	jal	imagen_dibuja_imagen	# imagenDibujaImagen(*img, cadena, x, y)
	
	la	$a0, pantalla
	la	$a1, pieza_next
	li	$a2, 19
	li	$a3, 6
	jal	imagen_dibuja_imagen
	
	la	$a0, pantalla
	jal	imagen_print		# imagen_print(pantalla)
	
	lw	$s1, 0($sp)
	lw	$s2, 4($sp)
	lw	$ra, 8($sp)
	addiu	$sp, $sp, 12
	jr	$ra

nueva_pieza_actual:
	#[modificiacion
	
	#apilamos
	addiu	$sp,$sp, -8
	sw	$s0,4($sp)
	sw	$ra,0($sp)
	
	la	$a0, pieza_actual	# Cargamos la dirección de pieza_actual en $a0 para llamar a imagen_copy
	la	$a1, pieza_next		# Cargamos la pieza generada en la iteración anterior en $a1 para llamar a imagen_copy
	jal	imagen_copy
	
	la	$s0, pieza_actual	
					
	jal	pieza_aleatoria
	move	$a1,$v0
	la	$a0, pieza_next		#cargamos la dirección de pieza_next en $a0
					#cargamos la pieza generada por la funcion pieza_aleatoria para llamar a imagen_copy
	jal	imagen_copy
	
	
	move 	$a0,$s0
		# por donde salen las piezas
	li	$a1,8		#eje x
	li	$a2,0		#eje y
	jal	probar_pieza
	
	li 	$t0, 1
	beq	$v0,$t0,nueva_pieza_actual_normal
	#bnez	$v0,nueva_pieza_actual_normal	
	li 	$t0, 1
	sb 	$t0, acabar_partida
	sb	$t0, acabar_partida_completo
	j	nueva_pieza_actual_final
	
nueva_pieza_actual_normal:	
	
	li	$t0,8			# pieza_actual_x = 8;
	sw	$t0,pieza_actual_x
	
	li	$t1,0			# pieza_actual_y = 0;
	sw	$t1,pieza_actual_y	
	
nueva_pieza_actual_final:

	#desapilamos
	lw	$ra,0($sp)
	lw	$s0,4($sp)
	addiu	$sp,$sp, 8
	
	jr	$ra
	#--]

probar_pieza:				# ($a0, $a1, $a2) = (pieza, x, y)
	addiu	$sp, $sp, -32
	sw	$ra, 28($sp)
	sw	$s7, 24($sp)
	sw	$s6, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	move	$s0, $a2		# y
	move	$s1, $a1		# x
	move	$s2, $a0		# pieza
	li	$v0, 0
	bltz	$s1, B12_13		# if (x < 0) return false
	lw	$t1, 0($s2)		# pieza->ancho
	addu	$t1, $s1, $t1		# x + pieza->ancho
	la	$s4, campo
	lw	$v1, 0($s4)		# campo->ancho
	bltu	$v1, $t1, B12_13	# if (x + pieza->ancho > campo->ancho) return false
	bltz	$s0, B12_13		# if (y < 0) return false
	lw	$t1, 4($s2)		# pieza->alto
	addu	$t1, $s0, $t1		# y + pieza->alto
	lw	$v1, 4($s4)		# campo->alto
	bltu	$v1, $t1, B12_13	# if (campo->alto < y + pieza->alto) return false
	# for (int i = 0; i < pieza->ancho; ++i) {
	lw	$t1, 0($s2)		# pieza->ancho
	beqz	$t1, B12_12
	li	$s3, 0			# i = 0
	#   for (int j = 0; j < pieza->alto; ++j) {
	lw	$s7, 4($s2)		# pieza->alto
B12_6:	beqz	$s7, B12_11
	li	$s6, 0			# j = 0
B12_8:	move	$a0, $s2
	move	$a1, $s3
	move	$a2, $s6
	jal	imagen_get_pixel	# imagen_get_pixel(pieza, i, j)
	beqz	$v0, B12_10		# if (imagen_get_pixel(pieza, i, j) == PIXEL_VACIO) sigue
	move	$a0, $s4
	addu	$a1, $s1, $s3		# x + i
	addu	$a2, $s0, $s6		# y + j
	jal	imagen_get_pixel
	move	$t1, $v0		# imagen_get_pixel(campo, x + i, y + j)
	li	$v0, 0
	bnez	$t1, B12_13		# if (imagen_get_pixel(campo, x + i, y + j) != PIXEL_VACIO) return false
B12_10:	addiu	$s6, $s6, 1		# ++j
	bltu	$s6, $s7, B12_8		# sigue si j < pieza->alto
        #   } // for j
B12_11:	lw	$t1, 0($s2)		# pieza->ancho
	addiu	$s3, $s3, 1		# ++i
	bltu	$s3, $t1, B12_6 	# sigue si i < pieza->ancho
        # } // for i
B12_12:	li	$v0, 1			# return true
B12_13:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s6, 20($sp)
	lw	$s7, 24($sp)
	lw	$ra, 28($sp)
	addiu	$sp, $sp, 32
	jr	$ra

intentar_movimiento:
	#[modificacion
	
	#apilamos
	addiu	$sp,$sp,-12
	sw	$s1,8($sp)
	sw	$s0,4($sp)
	sw	$ra,0($sp)
	
	move	$s0,$a0		# x en $s0
	move	$s1,$a1		# y en $s1
	
	la	$a0,pieza_actual
	move	$a1,$s0		# x en $a1
	move	$a2,$s1		# y en $a2
		
	jal	probar_pieza
	move	$t0,$v0		# guardamos el resultado de probar pieza en $t0
	
if1_intenmov:
	bne	$t0,1,finif1_intenmov
	
	sw	$s0,pieza_actual_x	
	sw	$s1,pieza_actual_y
	
	li	$v0,1		# aqui es un true
	
	j	desapilar	# lo utilizamos para que salte a desapilar
	
finif1_intenmov:
	li	$v0,0		# aqui es un false
		
desapilar:
	lw	$ra,0($sp)
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	addiu	$sp,$sp, 12
	
	jr	$ra
	
	#--]

bajar_pieza_actual:
	#{modificacion
	
	#apilamos
	addiu	$sp,$sp,-4
	sw	$ra,0($sp)
	
	lw	$a0,pieza_actual_x
	lw	$a1,pieza_actual_y
	add	$a1,$a1,1		# pieza_actual_y + 1
	
	jal	intentar_movimiento
	
	move	$t0,$v0
	
if1_bjpiezac:
	bnez	$t0,finif1_bjpiezac	# !intentar_movimiento(pieza_actual_x, pieza_actual_y + 1)
	
	la	$a0,marcador
	li	$a1,1
	jal	sumar_marcador
	
	la	$a0,campo
	la	$a1,pieza_actual
	lw	$a2,pieza_actual_x
	lw	$a3,pieza_actual_y
	
	jal	imagen_dibuja_imagen
	
	jal	completado_lineas
	
	jal	nueva_pieza_actual
	
finif1_bjpiezac:
	
	#desapilamos
	lw	$ra,0($sp)
	addiu	$sp,$sp, 4
	
	jr	$ra
	#--]

intentar_rotar_pieza_actual:
	#[modificacion
	
	#apilamos
	addiu	$sp,$sp, -4
	sw	$ra,0($sp)
	
		
	la	$a0,imagen_auxiliar	# *pieza_rotada = &imagen_auxiliar;
	
	la	$t0,pieza_actual
	lw	$a1,4($t0)	# pieza_actual.alto
	lw	$a2,0($t0)	# pieza_actual.ancho
	li	$a3,0		# pixel_vacio = 0
	
	jal	imagen_init
	
	la	$a0,imagen_auxiliar	# *pieza_rotada = &imagen_auxiliar;
	la	$a1,pieza_actual
	li	$a2,0
	li	$a3,0
	
	jal	imagen_dibuja_imagen_rotada
	
	la	$a0,imagen_auxiliar	# *pieza_rotada = &imagen_auxiliar;
	lw	$a1,pieza_actual_x
	lw	$a2,pieza_actual_y
	
	jal	probar_pieza
	move	$t0,$v0
if1_introtapiezact:
	beqz	$t0,finif1_introtapiezact
	
	la	$a0,pieza_actual
	la	$a1,imagen_auxiliar
	
	jal 	imagen_copy

finif1_introtapiezact:
		
	#desapilamos
	lw	$ra,0($sp)
	addiu	$sp,$sp, 4
	
	jr	$ra
	#--]

tecla_salir:
	li	$v0, 1
	sb	$v0, acabar_partida	# acabar_partida = true
	jr	$ra

tecla_izquierda:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	lw	$a1, pieza_actual_y
	lw	$t1, pieza_actual_x
	addiu	$a0, $t1, -1
	jal	intentar_movimiento	# intentar_movimiento(pieza_actual_x - 1, pieza_actual_y)
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_derecha:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	lw	$a1, pieza_actual_y
	lw	$t1, pieza_actual_x
	addiu	$a0, $t1, 1
	jal	intentar_movimiento	# intentar_movimiento(pieza_actual_x + 1, pieza_actual_y)
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_abajo:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	bajar_pieza_actual	# bajar_pieza_actual()
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_rotar:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	intentar_rotar_pieza_actual	# intentar_rotar_pieza_actual()
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_truco:
	addiu	$sp, $sp, -20
	sw	$ra, 16($sp)
	sw	$s4, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
       	li	$s4, 18
	#  for (int y = 13; y < 18; ++y) {         
	li	$s0, 13
	#  for (int x = 0; x < campo->ancho - 1; ++x) {
B21_1:	li	$s1, 0
B21_2:	lw	$t1, campo
	addiu	$t1, $t1, -1
	bge	$s1, $t1, B21_3
	la	$a0, campo
	move	$a1, $s1
	move	$a2, $s0
	li	$a3, '#'
	jal	imagen_set_pixel	# imagen_set_pixel(campo, x, y, '#'); 
	addiu	$s1, $s1, 1	# 245   for (int x = 0; x < campo->ancho - 1; ++x) { 
	j	B21_2
B21_3:	addiu	$s0, $s0, 1
	bne	$s0, $s4, B21_1
	la	$a0, campo
	li	$a1, 10
	li	$a2, 16
	li	$a3, 0
	jal	imagen_set_pixel	# imagen_set_pixel(campo, 10, 16, PIXEL_VACIO); 
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s4, 12($sp)
	lw	$ra, 16($sp)
	addiu	$sp, $sp, 20
	jr	$ra

procesar_entrada:
	addiu	$sp, $sp, -20
	sw	$ra, 16($sp)
	sw	$s4, 12($sp)
	sw	$s3, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	jal	keyio_poll_key
	move	$s0, $v0		# int c = keyio_poll_key()
        # for (int i = 0; i < sizeof(opciones) / sizeof(opciones[0]); ++i) { 
	li	$s1, 0			# i = 0, $s1 = i * sizeof(opciones[0]) // = i * 8
	la	$s3, procesar_entrada.opciones	
	li	$s4, 48			# sizeof(opciones) // == 5 * sizeof(opciones[0]) == 5 * 8
B22_1:	addu	$t1, $s3, $s1		# procesar_entrada.opciones + i*8
	lb	$t2, 0($t1)		# opciones[i].tecla
	bne	$t2, $s0, B22_3		# if (opciones[i].tecla != c) siguiente iteración
	lw	$t2, 4($t1)		# opciones[i].accion
	jalr	$t2			# opciones[i].accion()
	jal	actualizar_pantalla	# actualizar_pantalla()
B22_3:	addiu	$s1, $s1, 8		# ++i, $s1 += 8
	bne	$s1, $s4, B22_1		# sigue si i*8 < sizeof(opciones)
        # } // for i
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s3, 8($sp)
	lw	$s4, 12($sp)
	lw	$ra, 16($sp)
	addiu	$sp, $sp, 20
	jr	$ra

#[modificiacion
imagen_dibuja_cadena:
	# apilamos
	addiu	$sp,$sp, -28
	sw	$s5,24($sp)
	sw	$s4,20($sp)
	sw	$s3,16($sp)
	sw	$s2,12($sp)
	sw	$s1,8($sp)
	sw	$s0,4($sp)
	sw	$ra,0($sp)
	
	move	$s0,$a0		# $s0 <- dst
	move	$s1,$a1		# $s1 <- x
	move	$s2,$a2		# $s2 <- y
	move	$s3,$a3		# $s3 <- la cadena a escribir
	
	move	$s4,$0		# esto es el contador del bucle
	
bucle1_imgdibcad:
	lb	$s5,0($s3)	# El caracter
	beqz	$s5,finbucle1_imgdibcad
	
	move 	$a0,$s0		# a0 <- imagen_destino
	add	$a1,$s2,$s4	# a1 <- y + contador
	move	$a2,$s1		# a2 <- x
	move	$a3,$s5		# a3 <- caracter
	
	jal	imagen_set_pixel
	
	addi	$s4,$s4,1	# contador++
	addi	$s3,$s3,1	# para que coja el siguiente caracter
	j	bucle1_imgdibcad
	
finbucle1_imgdibcad:

	move	$v0,$s4
	

	#desapilamos
	lw	$ra,0($sp)
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	lw	$s2,12($sp)
	lw	$s3,16($sp)
	lw	$s4,20($sp)
	lw	$s5,24($sp)
	addiu	$sp,$sp, 28
	
	jr	$ra
	
sumar_marcador:
	# apilamos
	addiu	$sp,$sp, -4
	sw	$ra,0($sp)
	
	lw	$t0,0($a0)		# direccion de marcador
	move 	$t1,$a1			# lo que queramos sumarle
	
	add	$t1,$t1,$t0
	
	sw	$t1,0($a0)		# guardamos en memoria
	
	#desapilamos
	lw	$ra,0($sp)
	addiu	$sp,$sp, 4
	
	jr	$ra
	
imprimir_marcador:
	# apilamos
	addiu	$sp,$sp, -4
	sw	$ra,0($sp)
	
	la	$t0,marcador
	lw	$a0,0($t0)
	la	$a1,marcador_string
	
	jal	integer_to_string
	
	la	$a0,pantalla
	li	$a1,0		# y
	li	$a2,0		# x
	la	$a3,str003
	
	jal	imagen_dibuja_cadena
	
	
	la	$a0,pantalla
	li	$a1,0		# y
	move	$a2,$v0		# x
	la	$a3,marcador_string
	
	jal	imagen_dibuja_cadena
	
	#desapilamos
	lw	$ra,0($sp)
	addiu	$sp,$sp, 4
	
	jr	$ra
#--]

#[modificacion
completado_lineas:
	#apilamos
	addiu	$sp, $sp, -24
	sw	$ra, 20($sp)
	sw	$s0, 16($sp)		
	sw	$s1, 12($sp)		
	sw	$s2, 8($sp)		 
	sw	$s3, 4($sp)		
	sw	$s4, 0($sp)
	
	la	$s0, campo		# $s0 = campo
	lw	$s1, 0($s0)  		# $s1 = campo->ancho
	lw	$s2, 4($s0)  		# $s2 = campo->alto
	
	
        li	$s3, 0			# y = 0
for1_complin:
	bge	$s3, $s2, finfor1_complin		# si no se cumple el bucle, salta a finfor1_complin
        
        
        li	$s4, 0			# x = 0
        
for2_complin:   
	bge	$s4, $s1, finfor2_complin		# si no se cumple el bucle, salta a finfor2_complin
	
	move 	$a0, $s0
	move	$a1, $s4
	move	$a2, $s3
	jal	imagen_get_pixel		  # imagen_get_pixel($a0, $a1, $a2) = (img, x, y)
	beqz 	$v0, salida_complin		# si el pixel es '0' salta a salida_complin
	
	addi	$s4, $s4, 1		# x++
	j 	for2_complin
	
finfor2_complin:	
	
	la	$a0,marcador
	li	$a1,10			# sumamos 10 cuando la linea se complete
	jal 	sumar_marcador
	
	move	$a0, $s3
	jal eliminar_linea
		
salida_complin:
	addi	$s3, $s3, 1		# y++
	j	for1_complin
        # }    

finfor1_complin:		
	#desapilamos
	lw	$s4, 0($sp)
	lw	$s3, 4($sp)
	lw	$s2, 8($sp)
	lw 	$s1, 12($sp)
	lw	$s0, 16($sp)
	lw	$ra, 20($sp)
	addiu	$sp, $sp, 24	
     	jr 	$ra 		
#--]
#[modificacion
eliminar_linea:

	#apilamos
	addiu	$sp, $sp, -24
	sw	$ra, 20($sp)
	sw	$s0, 16($sp)		
	sw	$s1, 12($sp)	
	sw	$s2, 8($sp)	
	sw	$s3, 4($sp)	
	sw	$s4, 0($sp)
	
	
	move 	$s0, $a0		# $s0 = y
	la	$s4, campo		# $s4 = campo
	lw	$s3, 0($s4)	 	# $s3 = campo->ancho
	
for1_elimlin:
	
	bltz 	$s0, finfor1_elimlin 	 	# si no se cumple la condición sale del bucle
	subi	$s1, $s0, 1			# n = y - 1
	
	bgez	$s1, if1_elimlin	 	# si n >= 0 salta a if1_elimin			 	 	 	 	 	 	
     	
     	li 	$s2, 0				# x = 0
     	
for2_elimlin:
  
	bge 	$s2, $s3, finfor2_elimlin
     	move 	$a0, $s4
     	move	$a1, $s2
     	move	$a2, $s0
     	li	$a3, 0
     	jal 	imagen_set_pixel
     	addi	$s2, $s2, 1		 	
   	j	for2_elimlin
finfor2_elimlin:

	j	restar_elimlin
if1_elimlin:
	
	li 	$s2, 0			# x = 0
for3_elimlin:

	bge 	$s2, $s3, restar_elimlin	
     	move 	$a0, $s4
     	move	$a1, $s2
     	move	$a2, $s1
     	jal 	imagen_get_pixel
     	
   	move 	$a0, $s4
   	move	$a1, $s2
   	move	$a2, $s0
   	move 	$a3, $v0
   	jal 	imagen_set_pixel
   	addi	$s2, $s2, 1
   	j	for3_elimlin
     	
restar_elimlin:
  	
	subi	$s0, $s0, 1
	j	for1_elimlin

finfor1_elimlin:
	
	lw	$s4, 0($sp)
	lw	$s3, 4($sp)
	lw	$s2, 8($sp)
	lw 	$s1, 12($sp)
	lw	$s0, 16($sp)
	lw	$ra, 20($sp)
	addiu	$sp, $sp, 24	
     	jr 	$ra
#--]

jugar_partida:
	addiu	$sp, $sp, -12	
	sw	$ra, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	la	$a0, pantalla
	li	$a1, 28			# eje x de la pantall
	li	$a2, 22			# eje y de la pantalla
	li	$a3, 32
	jal	imagen_init		# imagen_init(pantalla, 20, 22, ' ')
	la	$a0, campo
	li	$a1, 14			# eje x del campo espacio que ocupa
	li	$a2, 18			# eje y del campo espacio que ocupa
	li	$a3, 0
	jal	imagen_init		# imagen_init(campo, 14, 18, PIXEL_VACIO)
	
	#[modificiacion
	jal	pieza_aleatoria
	move	$s1, $v0
	la	$a0, pieza_next
	move	$a1, $s1
	jal	imagen_copy
	#--]
	
	jal	nueva_pieza_actual	# nueva_pieza_actual()
	sb	$zero, acabar_partida	# acabar_partida = false
	jal	get_time		# get_time()
	move	$s0, $v0		# Hora antes = get_time()
	jal	actualizar_pantalla	# actualizar_pantalla()
	j	B23_2
	
        # while (!acabar_partida) { 
B23_2:	lbu	$t1, acabar_partida
	bnez	$t1, B23_5		# if (acabar_partida != 0) sale del bucle
	jal	procesar_entrada	# procesar_entrada()
	jal	get_time		# get_time()
	move	$s1, $v0		# Hora ahora = get_time()
	subu	$t1, $s1, $s0		# int transcurrido = ahora - antes
	ble	$t1, 1000, B23_2	# if (transcurrido < pausa) siguiente iteración
B23_1:	jal	bajar_pieza_actual	# bajar_pieza_actual()
	jal	actualizar_pantalla	# actualizar_pantalla()
	move	$s0, $s1		# antes = ahora
	#[modificacion
	la 	$t1, acabar_partida_completo
	lb 	$t2, 0($t1)
	beqz 	$t2, continuar	
	
	#llamamos a imagen_clean
	la	$a0,pantalla
	li	$a1,' '
	jal 	imagen_clean
	
	la 	$a0, pantalla
	la 	$a1, texto_fin
	li 	$a2, 0
	li 	$a3, 10
	jal 	imagen_dibuja_imagen	
	jal 	clear_screen
	la 	$a0, pantalla
	jal 	imagen_print	
	jal 	read_character			#hacer que se espere una tecla	
	
	#--]
continuar:
        j	B23_2			# siguiente iteración
       	# } 
B23_5:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$ra, 8($sp)
	addiu	$sp, $sp, 12
	jr	$ra

	.globl	main

main:					
						# ($a0, $a1) = (argc, argv) 
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
B24_2:	jal	clear_screen		# clear_screen()
	la	$a0, str000
	jal	print_string		# print_string("Tetris\n\n 1 - Jugar\n 2 - Salir\n\nElige una opción:\n")
	jal	read_character		# char opc = read_character()
	beq	$v0, '2', B24_1		# if (opc == '2') salir
	bne	$v0, '1', B24_5		# if (opc != '1') mostrar error
	jal	jugar_partida		# jugar_partida()
	#[modificacion
	la	$t0,marcador		# poner a 0 el marcador
	sw	$0,0($t0)
	la	$t0,acabar_partida_completo	# poner a 0 el acabar_partida
	sw	$0,0($t0)
	#--]
	j	B24_2
B24_1:	la	$a0, str001
	jal	print_string		# print_string("\n¡Adiós!\n")
	li	$a0, 0
	jal	mips_exit		# mips_exit(0)
	j	B24_2
B24_5:	la	$a0, str002
	jal	print_string		# print_string("\nOpción incorrecta. Pulse cualquier tecla para seguir.\n")
	jal	read_character		# read_character()
	j	B24_2
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

#
# Funciones de la librería del sistema
#

print_character:
	li	$v0, 11
	syscall	
	jr	$ra

print_string:
	li	$v0, 4
	syscall	
	jr	$ra

get_time:
	li	$v0, 30
	syscall	
	move	$v0, $a0
	move	$v1, $a1
	jr	$ra

read_character:
	li	$v0, 12
	syscall	
	jr	$ra

clear_screen:
	li	$v0, 39
	syscall	
	jr	$ra

mips_exit:
	li	$v0, 17
	syscall	
	jr	$ra

random_int_range:
	li	$v0, 42
	syscall	
	move	$v0, $a0
	jr	$ra

keyio_poll_key:
	li	$v0, 0
	lb	$t0, 0xffff0000
	andi	$t0, $t0, 1
	beqz	$t0, keyio_poll_key_return
	lb	$v0, 0xffff0004
keyio_poll_key_return:
	jr	$ra
