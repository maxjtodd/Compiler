.data # start of the DATA section, strings first

_L0:	.asciiz "inside f"		#global string
_NL: .asciiz "\n "# NEw line
.align 2 # start all of global variable aligned

x4:	.space 400		# define a global variable

.text
 
.globl main

 			
	.text		
			
f:			#Start of Function 
	subu $t0  $sp 12		#set up $t0 to be the new spot for SP
	sw $ra ($t0)		 #Store the return address 
	sw $sp 4($t0)		 #Store the old stack pointer 
	move $sp $t0 		# set the stack pointer to the new value
			
	li $v0, 4		#print a string
	la $a0, _L0		#print fetch string location
	syscall		
	li $v0, 4		#print NEWLINE
	la $a0, _NL		#print NEWLINE string location
	syscall		
			
	li $a0 8		#get Identifier offset
	 add $a0,$a0,$sp		# we have direct reference to memory 
	lw $a0 ($a0)		#expression is identifier
	li $v0 1		#set up write call
	syscall		
	li $v0, 4		#print NEWLINE
	la $a0, _NL		#print NEWLINE string location
	syscall		
			
	li $a0 8		#get Identifier offset
	 add $a0,$a0,$sp		# we have direct reference to memory 
	lw $a0 ($a0)		#expression is identifier
	lw $ra ($sp)		# reset return address 
	lw $sp 4($sp)		# reset stack pointer 
	jr $ra       		# return to our caller
	li $v0 0    		#  return  NULL zero (0) 
	lw $ra ($sp)		# reset return address 
	lw $sp 4($sp)		# reset stack pointer 
	jr $ra       		# return to our caller
			
	.text		
			
main:			#Start of Function 
	subu $t0  $sp 20		#set up $t0 to be the new spot for SP
	sw $ra ($t0)		 #Store the return address 
	sw $sp 4($t0)		 #Store the old stack pointer 
	move $sp $t0 		# set the stack pointer to the new value
			
	li $a0 2		# expresion a number
	sw $a0 12($sp)		# stor arg value in our runtime stack
	subu $t2 $sp 12		#set up the new target for the function call
	lw $t0 12($sp)		# load paramter value from stack 
	sw $t0 8($t2)		#store paramater into new activation record
			# about to call a function, set up each parameter in the new activation record
	jal f		#jump and link to function
	sw $a0, 16($sp)		#store RHS value in memory
	li $a0 8		#get Identifier offset
	 add $a0,$a0,$sp		# we have direct reference to memory 
	lw $a1, 16($sp)		# Get RHS stored value
	sw $a1 ($a0)		# ASSIGN final store 
			
	li $a0 8		#get Identifier offset
	 add $a0,$a0,$sp		# we have direct reference to memory 
	lw $a0 ($a0)		#expression is identifier
	li $v0 1		#set up write call
	syscall		
	li $v0, 4		#print NEWLINE
	la $a0, _NL		#print NEWLINE string location
	syscall		
			
	li $v0 0    		#  return  NULL zero (0) 
	lw $ra ($sp)		# reset return address 
	lw $sp 4($sp)		# reset stack pointer 
	li $v0, 10		#Main function ends 
	syscall		#MAIN FUNCTION EXITS
