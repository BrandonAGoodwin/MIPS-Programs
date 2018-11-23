    .data
    .align 2
pr:     .asciiz "Provide an integer for the Fibonacci computation:\n"
wi:     .asciiz "<ERROR: Invalid input please try again or input nothing to quit>\n"    
fn:     .asciiz "The Fibonacci numbers are:\n"
col:    .asciiz ": "
nl:     .asciiz "\n"
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
    move $s0, $v0           # $s0: Now contains the integer value to be used for FIB
    
    la $a0, fn
    li $v0, 4
    syscall

    # Allocate heap space for array of already processed results
    li $t0, 4
    addi $t2, $s0, 1
    mul $a0, $t2, $t0
    li $v0, 9
    syscall
    move $s1, $v0           # $s1: Holds the address of the array to hold the calculated values
    # Loop fib from 0 to user input
    
    li $s2, 0               # $s2: Initialise counter to 0
loop:
    # All temporaries need to be changed
    bgt $s2, $s0, end
    
    move $a0, $s2
    li $v0, 1
    syscall
    la $a0, col
    li $v0, 4
    syscall
    
    move $a0, $s2
    move $a1, $s1
    jal FIB
    
    move $a0, $v0
    #move $t0, $v0
    li $v0, 1
    syscall                 # Print out output of FIB
    la $a0, nl
    li $v0, 4
    syscall
    addi $s2, $s2, 1
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
    
    li $v0, 0               # v0: Initialise the output to zero
    
    li $t9, 48              # $t9: Holds the ASCII value offset for digits 0-9
    li $t8, 10              # $t8: Holds the multiplier for when each digit is added to the integer
    #move $t0, $a0
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
    
    mul $v0, $v0, $t8
    add $v0, $v0, $t1       # Add the digit to the integer
    addi $s0, $s0, 1        # Increment the pointer
    j check_loop

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
    beqz $v0, end
    lw $ra, 8($sp)
    lw $s0, 4($sp)
    lw $s1, 0($sp)
    addi $sp, $sp, 12
    jr $ra

# $a0: The position of the value in the fibonacci sequence we want to return
# $a1: The array that stores any pre-calculated values / to store newly calculated values
FIB:
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)          # $s0: Store the input
    sw $s1, 4($sp)          # $s1: Store the result array
    sw $s2, 0($sp)          # $s2: Store the first result
    
    move $s0, $a0           
    move $s1, $a1 
    
    # If the input is <= 0 then just output the input
    blez $s0, CHK
    
    li $t0, 1
    beq $s0, $t0, ONE
    # FIND
    li $t0, 4
    addi $t1, $s0, -1
    mul $t0, $t1, $t0
    add $t0, $t0, $s1
    lw $v0, 0($t0)   
    bne $v0, $zero, END

    addi $a0, $s0, -1
    move $a1, $s1
    jal FIB # Run with input -1
    
    # Store the first result
    move $s2, $v0
    
    addi $a0, $s0, -2
    move $a1, $s1
    jal FIB # Run with input -2
    
    add $v0, $s2, $v0 # Add the first and second results
    move $a0, $s0
    move $a1, $s1
    move $a2, $v0
    jal STORE
    j END
    
CHK:move $v0, $zero
    j END
ONE:move $v0, $a0
    j END
END:lw $ra, 12($sp)
    lw $s0, 8($sp)
    lw $s1, 4($sp)
    lw $s2, 0($sp)
    addi $sp, $sp, 16
    jr $ra

# $a0: Results array
# $a1: Input value
#FIND:
li $t0, 4
mul $t0, $a1, $t0
add $t0, $t0, $a0
lw $v0, 0($t0)

jal $ra

# $a0: Input value
# $a1: Results array
# $a2: Result
STORE:
li $t0, 4
addi $a0, $a0, -1 
mul $t0, $a0, $t0
add $a1, $t0, $a1
sw $a2, 0($a1)
jr $ra

