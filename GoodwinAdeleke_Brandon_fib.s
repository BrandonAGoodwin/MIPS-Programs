    .data
    .align 2
pr:     .asciiz "Provide an integer for the Fibonacci computation:"
wi:     .asciiz "Invalid input please try again or input nothing to quit:"    
input:  .space 1024    
    .text
main:

start:
    la $a0, pr
    li $v0, 4
    syscall                 # Print out input requesst to command line
    
    la $s0, input           # $s0: Stores the address of the user input
    
    move $a0, $s0           # $a0: Stores the address the user input will be stored at
    li $a1, 1024
    li $v0, 8       
    syscall                 # Read user input from command line
    
    # Maybe unessasary but makes sure that the input is correct
    move $a0, $s0
    jal CHECK               # Check the user input represents a string otherwise ask for input again
    
    li $v0, 10              
    syscall                 # End the program

# Checks if a string represents an integer
# $a0: String to be checked
# $v0: Integer (if string represents an integer)
CHECK:
    addi $sp, $sp, 0
    sw $ra, ($sp)
    
    move $s0, $a0           # $s0: Stores the address of the string
    
    move $t0, $a0
    li $t1, 0               # $t1: Stores the pointer to the current character
    # ASCII offset = 48
check_loop:

    
    if

FIB:
    addi $sp, $sp, 0
    sw $ra, ($sp)
    
