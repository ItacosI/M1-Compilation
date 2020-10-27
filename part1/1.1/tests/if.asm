.text
	beqz $a0, init_end
	lw $a0, 0($a1)
	jal atoi
	la $t0, arg
	sw $v0, 0($t0)
init_end:
	li $t0, -1
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	addi $sp, $sp, 4
	lw $t0, 0($sp)
	beqz $t0, __label_4
	li $t0, 0
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	addi $sp, $sp, 4
	lw $t0, 0($sp)
	beqz $t0, __label_6
	li $t0, 75
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	li $v0, 11
	addi $sp, $sp, 4
	lw $a0, 0($sp)
	syscall
	b __label_7
__label_6:
	li $t0, 79
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	li $v0, 11
	addi $sp, $sp, 4
	lw $a0, 0($sp)
	syscall
__label_7:
	b __label_5
__label_4:
	li $t0, 75
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	li $v0, 11
	addi $sp, $sp, 4
	lw $a0, 0($sp)
	syscall
__label_5:
	li $t0, 0
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	addi $sp, $sp, 4
	lw $t0, 0($sp)
	beqz $t0, __label_0
	li $t0, 111
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	li $v0, 11
	addi $sp, $sp, 4
	lw $a0, 0($sp)
	syscall
	b __label_1
__label_0:
	li $t0, -1
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	addi $sp, $sp, 4
	lw $t0, 0($sp)
	beqz $t0, __label_2
	li $t0, 107
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	li $v0, 11
	addi $sp, $sp, 4
	lw $a0, 0($sp)
	syscall
	b __label_3
__label_2:
	li $t0, 111
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	li $v0, 11
	addi $sp, $sp, 4
	lw $a0, 0($sp)
	syscall
__label_3:
__label_1:
	li $t0, 10
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	li $v0, 11
	addi $sp, $sp, 4
	lw $a0, 0($sp)
	syscall
	li $v0, 10
	syscall
atoi:
	move $t0, $a0
	li $t1, 0
	li $t2, 10
atoi_loop:
	lbu $t3, 0($t0)
	beq $t3, $zero, atoi_end
	li $t4, 48
	blt $t3, $t4, atoi_error
	li $t4, 57
	bgt $t3, $t4, atoi_error
	addi $t3, $t3, -48
	mul $t1, $t1, $t2
	add $t1, $t1, $t3
	addi $t0, $t0, 1
	b atoi_loop
atoi_error:
	li $v0, 10
	syscall
atoi_end:
	move $v0, $t1
	jr $ra
.data
arg:
	.word 0
