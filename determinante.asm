.data
  p1: .asciiz "Digite o tamanho ordem da matriz (n): "
  p2: .asciiz "Digite um numero na matriz: "
  resp: .asciiz "O determinante da matriz é: "
.text

main:
    li   $t0,  0		# contador
    li   $v0,  4
    la   $a0,  p1		# print p1
    syscall
    
    li   $v0,  5		# ler inteiro
    syscall
    
    move $s0, $v0
    mul  $s2, $s0, $s0		# s2 = n*n
    
    mul  $a0, $s2, 4		# a0 = 4 * s2 (inteiro = 4 bytes)    
    li	 $v0,  9		# alocar espaco para n*n inteiros
    syscall
    
    move $s1, $v0
      
	FOR:		# ler matriz n*n
    	li   $v0,  4
    	la   $a0,  p2		# print p2
    	syscall
    	
    	li   $v0,  5		# ler inteiro
    	syscall
    	
    	mul  $t1, $t0, 4		# t1 = t0 * 4
    	add  $t1, $t1, $s1		# t1 += s1
    	sw   $v0, 0($t1)
    	addi $t0, $t0, 1    		# t0++
    	bne  $t0, $s2, FOR		# while ( t0 < s2 ), s2 = n*n
    
    move $a0, $s1		# parametros da funcao determinante
    move $a1, $s0		# a0 = Matriz, a1 = n
    
    jal  determinante
    
    move $s0, $v0		# s0 = return da funcao
    
    li   $v0,  4
    la   $a0,  resp	# print resp
    syscall
    
    move $a0, $s0
    li	 $v0, 1			# print determinante
    syscall
    
    li	 $v0, 10
    syscall
    
determinante: # (matriz, n)

    addi $sp, $sp, -28		# pilha de recursao para nao perder os dados
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)
    sw   $s1, 8($sp)
    sw   $s2, 12($sp)
    sw 	 $s3, 16($sp)
    sw   $s4, 20($sp)
    sw   $s5, 24($sp)		# salva s5 no sp
    
    li   $s2, 1			# S2 = 1
    li   $s3, 0			# S3 = 0
    li   $s4, 0			# S4 = 0
    
    move $s0, $a0		# s0 = matriz[0]
    move $s1, $a1		# s1 = n

    li   $t0, 1			# t0 = 1
    slt  $t1, $s1, $t0		# if s1 < t0 t1 = 1 else t1 = 0
    bne  $t1,  $0, return0	# if s1 < 1 goto return0
    
    beq  $t0, $s1, return1  	# if s1 = 1 goto return1
    addi $a1, $s1, -1		# a1 = n - 1
    mul  $a0, $a1, $a1		# a0 = (n-1)*(n-1)
    mul  $a0, $a0, 4		# a0 = (n-1)*(n-1)*4 bytes
    
    li	 $v0,  9		# alocar memoria com o tamanho (n-1)*(n-1)*4
    syscall
    move $s5, $v0		# endereço da memoria alocada
    
    # s5 - nova matriz, s0 - matriz do parametro
    
    FOR2:
    	li  $t0,  1
    	FOR3:
    	    mul $t2, $t0, $a1		# t2 = t0 * n-1
    	    mul $t3, $t0, $s1		# t3 = t0 * n
    	    
    	    li  $t1,  0
    	    FOR4: 	    
    	    	add  $t4, $t2, $t1	# t4 = t2 + t1
    	    	sub  $t4, $t4, $a1
    	    	mul  $t4, $t4, 4	# t4 = 4 bytes * t4
    	    	
    	    	add  $t5, $t3, $t1	# t5 = t3 + t1
    	    	mul  $t5, $t5, 4	# t5 = 4 bytes * t5
    	    	
    	    	slt  $t6, $t1, $s3
    	    	bne  $t6,  $0, L00	# if t5 != 0 goto L00
    	    	addi $t5, $t5, 4	# t5 = t5 + 4 bytes
    	    	
    	    	L00:
    	    	add  $t4, $t4, $s5
    	    	add  $t5, $t5, $s0
    	        lw   $t6, 0($t5)	# passa o valor de s0 para s5
    	        sw   $t6, 0($t4)
    	        addi $t1, $t1, 1    	# t1++
    	        bne  $t1, $a1, FOR4	# if ( t1 != a1 ) goto FOR4
    	        
    	    addi $t0, $t0, 1 	   	# t0 = t0 + 1
    	    bne  $t0, $s1, FOR3		# if ( t0 != a1 ) goto FOR3
    	    
    	move $a0, $s5			# endereço da memoria alocada
    	jal  determinante		# chamada recursiva
    	addi $a1, $s1, -1		# a1 = n - 1
    	mul  $t8, $s3, 4		# t8 = t8 * 4 bytes
    	add  $t8, $t8, $s0		# t8 = t8 + s0
    	lw   $t8, 0($t8)		# carrega um valor da primeira linha da matriz em t8
    	mul  $t8, $t8, $s2		# t8 = t8 * s2
    	mul  $t8, $t8, $v0		# t8 = t8 * return det
    	add  $s4, $s4, $t8		# s4 = s4 + t8 (resp)
    	mul  $s2, $s2, -1		# s2 = s2 * -1 (multiplicador do cofator)
    	
    	addi $s3, $s3, 1 	   	# s3 = s3 + 1 (coluna do cofator)
        bne  $s3, $s1, FOR2		# if ( s3 != s1 ) goto FOR2
    	move $v0, $s4			# v0 = s4 (valor return)
    	
    fim:
    	lw   $ra, 0($sp)	# limpa da pilha o que ja foi usado
        lw   $s0, 4($sp)        
        lw   $s1, 8($sp)
        lw   $s2, 12($sp)
        lw   $s3, 16($sp)
        lw   $s4, 20($sp)
        lw   $s5, 24($sp)
        addi $sp, $sp, 28
        jr $ra			# return
    
return0:
    li   $v0, 0
    j    fim    

return1:
    lw   $v0, 0($a0)
    j    fim
