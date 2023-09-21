.data # start of the data section, strings first

_NL:		.asciiz "\n" # NEW LINE
_t0:		.asciiz " is the base number. Calculation: 4 * i - yam\n\n"	#define global string
_t9:		.asciiz "\n"	#define global string
_t8:		.asciiz " bigger than 100!"	#define global string

.align 2 # start all global variable aligned
x:		.space 400	#define global variable
yam:		.space 4	#define global variable


.text

.globl main


main:			#Start of function
		subu $t0  $sp 52	#set up $t0 to be the new spot for SP
		sw $ra ($t0)	#Store the return address
		sw $sp 4($t0)	#Store the old stack pointer
		move $sp $t0	#Set the stack pointer to the new value

		la $a0, yam	#Load global variable from memory, expression
		li $v0, 5	#Read in a number
		syscall
		sw $v0 ($a0)	#End read statement

		la $a0, yam	#Load global variable from memory, expression
		lw $a0 ($a0)	#expression is identifier
		li $v0 1	#Print global variable
		syscall

		li $v0, 4	#print a string
		la $a0, _t0	#print fetch string location
		syscall

		li $a0 0	#Load a number, expression
		sw $a0, 16($sp)	#store assignment value in memory
		li $a0 8	#get identifier offset
		add $a0,$a0,$sp	#we have direct reference to memory
		lw $a1, 16($sp)	#Get right hand side stored value
		sw $a1 ($a0)	#Assigned, end assignment statement

		li $a0 100	#Load a number, expression
		sw $a0, 20($sp)	#store assignment value in memory
		li $a0 12	#get identifier offset
		add $a0,$a0,$sp	#we have direct reference to memory
		lw $a1, 20($sp)	#Get right hand side stored value
		sw $a1 ($a0)	#Assigned, end assignment statement

_t12:			#WHILE top argument
		li $a0 8	#get identifier offset
		add $a0,$a0,$sp	#we have direct reference to memory
		lw $a0 ($a0)	#expression is identifier
		sw $a0 24($sp)	#store a0 termporarily
		li $a0 100	#Load a number, expression
		move $t0 $a0	#store right hand side evaluation in $t0
		lw $a0 24($sp)	#load left hand side
		slt $a0, $a0, $t0	#end expression less than
		beq $a0 $0 _t13	#WHILE branch out

		li $a0 4	#Load a number, expression
		sw $a0 28($sp)	#store a0 termporarily
		li $a0 8	#get identifier offset
		add $a0,$a0,$sp	#we have direct reference to memory
		lw $a0 ($a0)	#expression is identifier
		move $t0 $a0	#store right hand side evaluation in $t0
		lw $a0 28($sp)	#load left hand side
		mul $a0,$a0,$t0	#complete multiplication expression
		sw $a0 32($sp)	#store a0 termporarily
		la $a0, yam	#Load global variable from memory, expression
		lw $a0 ($a0)	#expression is identifier
		move $t0 $a0	#store right hand side evaluation in $t0
		lw $a0 32($sp)	#load left hand side
		sub $a0,$a0,$t0	#complete subtract expression
		sw $a0, 36($sp)	#store assignment value in memory
		li $a0 8	#get identifier offset
		add $a0,$a0,$sp	#we have direct reference to memory
		lw $a0 ($a0)	#expression is identifier
		sll $t0, $a0, 2	#multiply wordsize
		la $a0, x	#Load global variable from memory, expression
		add $a0, $a0, $t0	#increase address by t0 to get array access point
		lw $a1, 36($sp)	#Get right hand side stored value
		sw $a1 ($a0)	#Assigned, end assignment statement

		li $a0 8	#get identifier offset
		add $a0,$a0,$sp	#we have direct reference to memory
		lw $a0 ($a0)	#expression is identifier
		sll $t0, $a0, 2	#multiply wordsize
		la $a0, x	#Load global variable from memory, expression
		add $a0, $a0, $t0	#increase address by t0 to get array access point
		lw $a0 ($a0)	#expression is identifier
		li $v0 1	#Print global variable
		syscall

		li $a0 8	#get identifier offset
		add $a0,$a0,$sp	#we have direct reference to memory
		lw $a0 ($a0)	#expression is identifier
		sll $t0, $a0, 2	#multiply wordsize
		la $a0, x	#Load global variable from memory, expression
		add $a0, $a0, $t0	#increase address by t0 to get array access point
		lw $a0 ($a0)	#expression is identifier
		sw $a0 40($sp)	#store a0 termporarily
		li $a0 100	#Load a number, expression
		move $t0 $a0	#store right hand side evaluation in $t0
		lw $a0 40($sp)	#load left hand side
		sgt $a0, $a0, $t0	#end expression greater than
		beq $a0 $0 _t14	#jump to else, start of if statement

		li $v0, 4	#print a string
		la $a0, _t8	#print fetch string location
		syscall


		j _t15	#then statement end

_t14:			#else target


_t15:			#end of if statement
		li $v0, 4	#print a string
		la $a0, _t9	#print fetch string location
		syscall

		li $a0 8	#get identifier offset
		add $a0,$a0,$sp	#we have direct reference to memory
		lw $a0 ($a0)	#expression is identifier
		sw $a0 44($sp)	#store a0 termporarily
		li $a0 1	#Load a number, expression
		move $t0 $a0	#store right hand side evaluation in $t0
		lw $a0 44($sp)	#load left hand side
		add $a0,$a0,$t0	#complete add expression
		sw $a0, 48($sp)	#store assignment value in memory
		li $a0 8	#get identifier offset
		add $a0,$a0,$sp	#we have direct reference to memory
		lw $a1, 48($sp)	#Get right hand side stored value
		sw $a1 ($a0)	#Assigned, end assignment statement


		j _t12	#WHILE jump back

_t13:			#WHILE end

		li $v0 0	#return NULL (0)
		lw $ra ($sp)	#reset return address
		lw $sp 4($sp)	#reset stack pointer

		li $v0, 10	#Main function ends
		syscall	# MAIN FUNCTION EXITS
