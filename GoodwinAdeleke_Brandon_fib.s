    .data
    .align 2
pr:     .asciiz "Provide an integer for the Fibonacci computation:\n"
wi:     .asciiz "<ERROR: Invalid input please try again>\n"    
fn:     .asciiz "The Fibonacci numbers are:\n"
col:    .asciiz ": "        # Colon and Space
nl:     .asciiz "\n"        # New line
input:  .space 1024         # Space in memory to store user input before it's checked  
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
    
    move $a0, $s0           # $a0: The argument for check is the string input
    jal CHECK               # Check the user input represents a string otherwise ask for input again
    move $s0, $v0           # $s0: Now contains the integer value to be used for FIB
    
    la $a0, fn
    li $v0, 4
    syscall                 # Print the fib output text

    li $t0, 4               # Temporarily store 4 for multiplication
    addi $t2, $s0, -1       # $t2: Input - 1 (The size of the heap as the outputs for 0 and 1 don't need to be stored)
    mul $a0, $t2, $t0       # $a0: The amount of heap space to be allocated
    li $v0, 9
    syscall                 # Allocate heap space for calculated values
    move $s1, $v0           # $s1: Holds the address of the array to hold the calculated values
    
    li $s2, 0               # $s2: Initialise counter to 0
loop:
    bgt $s2, $s0, end       # Branch to end if all values 0 to n have been calculated
    
    move $a0, $s2
    li $v0, 1
    syscall                 # Print out the input for the fib function
    la $a0, col     
    li $v0, 4
    syscall                 # Print out the colon and space
    
    move $a0, $s2           # Give the current value (the counter) as the input
    move $a1, $s1           # Give the array of results as for memoisation
    jal FIB                 # Calculate the nth Fibonacci number
    
    move $a0, $v0           
    li $v0, 1
    syscall                 # Print out output of FIB
    la $a0, nl
    li $v0, 4
    syscall                 # Print a new line
    addi $s2, $s2, 1        # Increment the counter
    j loop                  # Go back to the beginning of the loop
end:
    li $v0, 10              
    syscall                 # End the program

# Checks if a string represents an (positive) integer
# $a0: String to be checked
# $v0: Integer (if string represents an integer)
CHECK:
    addi $sp, $sp, -8
    sw $ra, 4($sp)          # Store the return address
    sw $s0, 0($sp)          # $s0: Stores the string address
    
    move $s0, $a0           # $s0: Stores the address of the string

    li $t9, 48              # $t9: Holds the ASCII value offset for digits 0-9
    li $t8, 10              # $t8: Holds the multiplier for when each digit is added to the integer

    li $v0, 0               # $v0: Initialise the output to zero
    li $t1, 0               # $t1: Stores the pointer to the current character
check_loop:
    lb $t1, 0($s0)          # Get the byte in the string that is currently being pointed to
    beqz $t1, end_of_string # Branch of the end of string is reached
    
    sub $t1, $t1, $t9       # Sub the ASCII value offset to get the digit
    bltz $t1, invalid_input # If the value is less than 0, then it isn't a digit
    
    addi $t2, $t1, -9       # Subtract 9 
    bgtz $t2, invalid_input # If the value is greater than 9, then it isn't a digit
    
    mul $v0, $v0, $t8       # Multiply the current stored integer by 10
    add $v0, $v0, $t1       # Add the digit to the integer
    addi $s0, $s0, 1        # Increment the pointer
    j check_loop            # Go to the begining of the loop

invalid_input:
    lw $ra, 4($sp)          # Load values from the stack
    lw $s0, 0($sp)          
    addi $sp, $sp, 8        # Restore the stack pointer
    
    la $a0, wi              # Load the invalid input message
    li $v0, 4 
    syscall                 # Print invalid input message to the console
    j main                  # Jump back to the beginning of the code
end_of_string:
    lw $ra, 4($sp)          # Load values from the stack
    lw $s0, 0($sp)
    addi $sp, $sp, 8        # Restore the stack pointer
    jr $ra                  # Return

# $a0: The position of the value in the fibonacci sequence we want to return
# $a1: The array that stores any pre-calculated values / to store newly calculated values
FIB:
    addi $sp, $sp, -16
    sw $ra, 12($sp)         # Store the return address
    sw $s0, 8($sp)          # $s0: Store the input
    sw $s1, 4($sp)          # $s1: Store the result array
    sw $s2, 0($sp)          # $s2: Store the first result
    
    move $s0, $a0
    move $s1, $a1 
    
    addi $t0, $s0, -1       # The input minus 1
    bgtz $t0, calculate     # If the input is greater than 1 then calculate the fib value
    move $v0, $s0           # If the input is less or equal to one (either 1 or 0) then return the input value
    j fib_end               # End fib
calculate:
    move $a0, $s0           # $a0: Give the input
    move $a1, $s1           # $a1: The address of the results array
    jal FIND                # Find the value stored in the correspoinding part of the results table
    bne $v0, $zero, fib_end # If this value is not zero, return the value

    addi $a0, $s0, -1       # $a0: The input value - 1
    move $a1, $s1           # $a1: The address of the result array for memoisation
    jal FIB                 # Get the previous value in the fibonacci sequence
    
    move $s2, $v0           # $s2: Stores the first result
    
    addi $a0, $s0, -2       # $a0: The input value - 2
    move $a1, $s1           # $a1: The address of the result array for memoisation
    jal FIB                 # Get the penultimate value in the fibonacci sequence
    
    add $v0, $s2, $v0       # Add the ultimate and penultimate values
    move $a0, $s0           # $a0: The input value
    move $a1, $s1           # $a1: The result array
    move $a2, $v0           # $a2: The result
    jal STORE               # Store the result in the result array

fib_end:
    lw $ra, 12($sp)         # Load values from the stack
    lw $s0, 8($sp)
    lw $s1, 4($sp)
    lw $s2, 0($sp)
    addi $sp, $sp, 16       # Restore the stack pointer
    jr $ra                  # Return

# $a0: Input value
# $a1: Results array
FIND:
    li $t0, 4               # Temporarily store 4 for multiplication
    addi $a0, $a0, -2       # Subtract two because we start storing results of inputs from n = 2 upwards (The result of n = 2 will be stored in the first heap space)
    mul $t0, $a0, $t0       # Multiply by 4
    add $a1, $t0, $a1       # Add the offset to the heap pointer to find the location of any pre-calculated result
    lw $v0, 0($a1)          # Load the value stored in this location
    jr $ra                  # Return

# $a0: Input value
# $a1: Results array
# $a2: Result
STORE:
    li $t0, 4               # Temporarily store 4 for multiplication
    addi $a0, $a0, -2       # Subtract two because we start storing results of inputs from n = 2 upwards (The result of n = 2 will be stored in the first heap space)
    mul $t0, $a0, $t0       # Multiply by 4
    add $a1, $t0, $a1       # Add the offset to the heap pointer to find the location of any pre-calculated result
    sw $a2, 0($a1)          # Store the result in this location    
    jr $ra                  # Return

