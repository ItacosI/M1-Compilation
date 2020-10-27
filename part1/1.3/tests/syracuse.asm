.text
	beqz $a0, init_end
	lw $a0, 0($a1)
	jal atoi
	la $t0, arg
	sw $v0, 0($t0)
init_end:
	la $t0, arg
	lw $t0, 0($t0)
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	la $t0, acc
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	sw $t1, 0($t0)
__label_1:
	la $t0, acc
	lw $t0, 0($t0)
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	li $t0, 1
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	addi $sp, $sp, 4
	lw $t0, 0($sp)
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	sne $t0, $t0, $t1
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	addi $sp, $sp, 4
	lw $t0, 0($sp)
	beqz $t0, __label_0
	li $t0, 2
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	la $t0, acc
	lw $t0, 0($t0)
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	addi $sp, $sp, 4
	lw $t0, 0($sp)
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	rem $t0, $t0, $t1
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	li $t0, 0
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	addi $sp, $sp, 4
	lw $t0, 0($sp)
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	seq $t0, $t0, $t1
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	addi $sp, $sp, 4
	lw $t0, 0($sp)
	beqz $t0, __label_2
	la $t0, acc
	lw $t0, 0($t0)
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	jal even
	addi $sp, $sp, 4
	lw $v0, 0($sp)
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	sw $v0, 0($sp)
	subi $sp, $sp, 4
	la $t0, acc
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	sw $t1, 0($t0)
	b __label_3
__label_2:
	la $t0, acc
	lw $t0, 0($t0)
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	jal odd
	addi $sp, $sp, 4
	lw $v0, 0($sp)
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	sw $v0, 0($sp)
	subi $sp, $sp, 4
	la $t0, acc
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	sw $t1, 0($t0)
__label_3:
	b __label_1
__label_0:
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
#print_int
print_int:
	lw $a0, 4($sp)
	li $v0, 1
	syscall
	sw $a0, 0($sp)
	subi $sp, $sp, 4
	jr $ra
#power
power:
	lw $s0, 8($sp)
	lw $s1, 4($sp)
	li $t0, 1
	b power_loop_guard
power_loop_code:
	mul $t0, $t0, $s1
	subi $s0, $s0, 1
power_loop_guard:
	bgtz $s0, power_loop_code
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	jr $ra
#odd
odd:
	move $fp, $sp
	li $t0, 47
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	li $v0, 11
	addi $sp, $sp, 4
	lw $a0, 0($sp)
	syscall
	li $t0, 3
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	la $t0, n
	lw $t0, 0($t0)
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	addi $sp, $sp, 4
	lw $t0, 0($sp)
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	mul $t0, $t1, $t0
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	li $t0, 1
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	addi $sp, $sp, 4
	lw $t0, 0($sp)
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	add $t0, $t1, $t0
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	jr $ra
	addi $sp, $sp, 4
	lw $v0, 0($sp)
	beq $fp, $sp, __label_7
__label_6:
	addi $sp, $sp, 4
	lw $t0, 0($sp)
	bne $fp, $sp, __label_6
__label_7:
	sw $v0, 0($sp)
	subi $sp, $sp, 4
#even
even:
	move $fp, $sp
	li $t0, 92
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	li $v0, 11
	addi $sp, $sp, 4
	lw $a0, 0($sp)
	syscall
	li $t0, 2
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	la $t0, n
	lw $t0, 0($t0)
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	addi $sp, $sp, 4
	lw $t0, 0($sp)
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	div $t0, $t0, $t1
	sw $t0, 0($sp)
	subi $sp, $sp, 4
	jr $ra
	addi $sp, $sp, 4
	lw $v0, 0($sp)
	beq $fp, $sp, __label_5
__label_4:
	addi $sp, $sp, 4
	lw $t0, 0($sp)
	bne $fp, $sp, __label_4
__label_5:
	sw $v0, 0($sp)
	subi $sp, $sp, 4
#function
.data
acc:
	.word 0
arg:
	.word 0
