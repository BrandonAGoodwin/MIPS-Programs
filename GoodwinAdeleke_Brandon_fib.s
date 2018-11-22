    .data
    .align 2
pr:     .asciiz "Provide an integer for the Fibonacci computation:"
wi:     .asciiz "Invalid input please try again or input nothing to quit:"    
input:  .space 1024    
    .text
main:

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
    
    # Allocate heap space for array of already processed results
    
    # Loop fib from 0 to user input
loop:
    # All temporaries need to be changed
    beqz $t0, end
    
    
    jal FIB
    
    move $a0, $v0
    move $t0, $v0
    li $v0, 1
    syscall                 # Print out output of FIB
    j loop
end:
    li $v0, 10              
    syscall                 # End the program

# Checks if a string represents an integer
# $a0: String to be checked
# $v0: Integer (if string represents an integer)
CHECK:
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)
    
    move $s0, $a0           # $s0: Stores the address of the string
    
    li $s1, 0
    li $t9, 48              # $t9: Holds the ASCII value offset for digits 0-9
    move $t0, $a0
    li $t1, 0               # $t1: Stores the pointer to the current character
    # ASCII offset = 48
check_loop:
    lb $t1, 0($s0)
    # Might be good practice to set the stack pointer right before ending the program
    beqz $t1, end_of_string # Branch of the end of string is reached
    
    sub $t1, $t1, $t9       # Sub the ASCII value offset to get the digit
    
    bltz $t1, invalid_input
    addi $t2, $t1, -9
    
    bgtz $t2, invalid_input
    
    multi $s1, 10
    add $s1, $s1, $t1
    j check_loop
    
    addi $s0, $s0, 1
invalid_input:
    lw $ra, 8($sp)
    lw $s0, 4($sp)
    lw $s1, 0($sp)
    addi $sp, $sp, 12
    la $a0, wi
    li $v0, 4
    syscall                 # Print invalid input message to the console
    j main                  # Jump back to the beginning of the code
end_of_string:

# $a0: The position of the value in the fibonacci sequence we want to return
# $a1: The array that stores any pre-calculated values / to store newly calculated values
FIB:
    addi $sp, $sp, 0
    sw $ra, ($sp)

    
