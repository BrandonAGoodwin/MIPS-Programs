	.data
	.align 2
k:      .word   4           # Including a null character to terminate string
s:      .asciiz "bac"
n:      .word   6
L:      .asciiz "abc"
        .asciiz "bbc"
        .asciiz "cba"
        .asciiz "cde"
        .asciiz "dde"
        .asciiz "dec"

storage:    .space 1024     # Free space in memory to store sorted strings (Can be reused for each string)

    .text
### ### ### ### ### ###
### MainCode Module ###
### ### ### ### ### ###
main:
    li $t9, 4               # $t9 = Constant 4
    
    lw $s0, k               # $s0: Length of the key word
    la $s1, s               # $s1: Key word
    lw $s2, n               # $s2: Size of string list
    la $s4, storage         # $s4: Next free space in memory
    
    move $t8, $s1           # $t8: Constantly the word
    
    # Allocate heap space for string array:
    
    li $v0, 9               # Syscall code 9: allocate heap space
    mul $a0, $s2, $t9       # Calculate the amount of heap space
    syscall
    move $s3, $v0           # $s3: Base address of a string array
    
    # Record addresses of declared strings into a string array:
    
    move $t0, $s2           # $t0: Counter i = n
    move $t1, $s3           # $t1: Address pointer j 
    la $t2, L               # $t2: Address of declared list L

READ_DATA:
    blez $t0, FIND          # If i > 0, read string from L
    
    move $a0, $t2           # Give the current string address as the first argument
    li $a1, 0               # Set the start pointer to 0
    move $a2, $s0           # Set the length to the size of the string
    move $a3, $s4           # Set the next free address in memory as the third argument
    
    addi $sp, $sp, -12
    sw $t0, 8($sp)
    sw $t1, 4($sp)
    sw $t2, 0($sp)
    jal M_SORT              # Sort the string before adding it to the heap
    lw $t0, 8($sp)
    lw $t1, 4($sp)
    lw $t2, 0($sp)
    addi $sp, $sp, 12
    
    sw $v0, 0($t1)          # Put the address of the string into the string array.
    add $s4, $v0, $s0       # Move the address pointer forward by the length of the word
    
    addi $t0, $t0, -1       # Decrement counter
    addi $t1, $t1, 4        # Move to the next position in the array
    add $t2, $t2, $s0       # Point to the next item in the list 
    j READ_DATA
 
FIND: 
    move $a0, $s1           # Make the keyword the string to sort
    li $a1, 0               # Initialize the start pointer to 0
    move $a2, $s0           # Give the length of the word as argument 2
    move $a3, $s4           # Give the address of free memory as argument 3

    jal M_SORT              # Sort the keyword
    
    move $a0, $v0           # Give the sorted key word ($v0) as the first argument
    move $a1, $s3           # Give the address to the array of sorted strings as the second argument
    move $a2, $s2           # Give the length of the word as the third argument
    move $a3, $s0           # Give the next free address in memory as the fourth argument
    
    jal COUNT               # Count the number of times the keyword appears in the string array
    
    move $a0, $v0           # $v0: The output of count, stores the number of times the keyword ($a0) appears in the string array ($a1)
    li $v0, 1
    syscall                 # Print out this value
    
    li $v0, 10              # End the program
    syscall

# $a0: The string to compare
# $a1: The string array
# $a2: The number of strings in the string array
# $a3: The length of all strings
# $v0: The number of anagrams in string array so far
COUNT:
    li $v0, 0               # Initialise $v0 to 0
    addi $sp, $sp, -4
    sw $ra, 0($sp)
count_loop:

    beqz $a2, count_end     # If there are no strings in the array return $v0
    li $t1, 0               # $t1: Initialize the counter 
    jal COMPARE
    
    add $v0, $v0, $v1       # $v1: Output of COMPARE
    
    addi $a1, $a1, 4        # Move to the next string in the string array
    addi $a2, $a2, -1       # Reduce the size of the array list
    
    j count_loop
    
COMPARE:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
compare_loop:
    beq $t1, $a3, true      # Branch if you've compared all strings
    
    add $t4, $a0, $t1       # Offset by the char we are comparing
    lb $s0, ($t4)           # Get the nth/($t1)th character of the key word
    
    lw $s1, 0($a1)          # Get the address of the current word from the string array
    add $t4, $s1, $t1       # Offset by the char we are comparing
    lb $s1, ($t4)           # Get the nth/($t1)th character of the key word
    
    sub $t3, $s0, $s1       # $t3: Holds the result of subtracting the 2 characters ASCII values if 0 then both the values are the same
    
    bne $t3, $zero, false   # If the characters aren't the same then jump to false
    addi $t1, $t1, 1        # Else, increment the counter ($t1)
    
    j compare_loop          # Loop to compare the next character
    
compare_end:
    lw $ra, 0($sp)          # Get the return address
    addi $sp, $sp, 4        # Move the stack pointer back
    jr $ra                  # Return

true:
    li $v1, 1               # $v1: Output of COMPARE (1 because the two strings were the same)
    j compare_end           # Jump to compare_end

false:
    li $v1, 0               # $v1: Output of COMPARE (0 because the two strings were different)
    j compare_end           # Jump to compare_end
    
count_end:                  
    lw $ra, 0($sp)          # Get the return address
    addi $sp, $sp, 4        # Move the stack pointer back
    jr $ra                  # Return

M_SORT:
    move $t4, $a0           # $t4: Temporary storage for $a0 while it is used to allocate heap space
    li $a0, 12              # The heap needs to store 3 addressed
    li $v0, 9
    syscall
    move $t8, $v0           # $t8: The pointer to the heap
    li $t7, 0               # $t7: Stores the state of the heap

    move $a0, $t4           # Return the original value of $a0 back
    addi $a2, $a2, -2       # Change $a2 so it represents a pointer to the end character

SPLIT:
    addi $sp, $sp, -32      
    sw $ra, 28($sp)         # Store the return address
    sw $s0, 24($sp)         # $s0: String Address
    sw $s1, 20($sp)         # $s1: Start Pointer (Start of left sub array)
    sw $s2, 16($sp)         # $s2: Mid Pointer (Start of right sub array)
    sw $s3, 12($sp)         # $s3: End Pointer (End of right sub array)
    sw $s4, 8($sp)          # $s4: String address of left merge
    sw $s5, 4($sp)          # $s5: Length of left merge
    sw $s6, 0($sp)          # $s6: The pointer to next free space in memory

    move $s0, $a0           # Load in string address
    move $s1, $a1           # Load in start pointer
    move $s3, $a2           # Load in end pointer
    move $s6, $a3           # Store the next free space in memory

    jal SET_HEAP            # Set up heap to point to free spaces in memory

    sub $t0, $s3, $s1       # If these are equal or the left is greater than the right we are finished

    blez $t0, RETURN_SINGLE_CHAR   

    add $t0, $s1, $s3       # Add the start and end pointers together
    li $t1, 2               # Temporary 2 for division
    div $s2, $t0, $t1       # $s2: Divide the pointers by 2 to get the mid pointer        

    move $a0, $s0           # Give the sorted string address as an argument
    move $a1, $s1           # Give start pointer as start pointer argument
    move $a2, $s2           # Give mid pointer as end pointer argument
    jal SPLIT
    move $s4, $v0           # $s4: Store the sorted string
    move $s5, $v1           # $s5: Length of sorted string

    addi $t0, $s2, 1        # The start pointer of the right merge is mid + 1
    move $a0, $s0
    move $a1, $t0           # Input the mid pointer as the start of the right merge
    move $a2, $s3           # Input the end pointer as the end of right merge
    jal SPLIT

    jal SET_HEAP            # Set up the heap to sort the two strings
    sw $s4, 0($t8)          # Store the two unsorted strings in the heap
    jal flip
    sw $v0, 0($t8)

    move $a0, $s4           # $a0: The left string address
    move $a1, $v0           # $a1: The right string address
    move $a2, $s5           # $a2: Length of left string
    move $a3, $v1           # $a3: Length of right string
    jal INTERLEAVE          # The output of interleave will be $v0 and $v1

    move $a3, $s6           # Set the address to the next free memory for the next SPLIT call 

    j RETURN

RETURN_SINGLE_CHAR:
    lw $v0, 0($t8)          # Get free address in memory
    jal flip                # Flip the heap pointer

    add $t0, $s0, $s1       # $t0: The single character at the end of this SPLIT
    lb $t0, 0($t0)          
    sb $t0, 0($v0)          # $v0: Store the single character at the begining of the copied string

    addi $t0, $v0, 1        # Add a null pointer after the character so it can be printed as a string
    sb $zero, 1($t0)

    li $v1, 1               # $v1: The length of the sorted string

    j RETURN

RETURN:
    lw $ra, 28($sp)       
    lw $s0, 24($sp)     
    lw $s1, 20($sp)        
    lw $s2, 16($sp)         
    lw $s3, 12($sp)         
    lw $s4, 8($sp)        
    lw $s5, 4($sp)
    lw $s6, 0($sp)
    addi $sp, $sp, 32

    jr $ra

INTERLEAVE:

    addi $sp, $sp, -20
    sw $ra, 16($sp)         
    sw $s0, 12($sp)         # $s0: The left string address
    sw $s1, 8($sp)          # $s1: The right string adddress
    sw $s2, 4($sp)          # $s2: The left string length
    sw $s3, 0($sp)          # $s3: The right string length

    move $s0, $a0           
    move $s1, $a1   
    move $s2, $a2   
    move $s3, $a3

    move $v0, $t9           # $v0: Store our output in the address currently stored in $t9

    li $t1, 0               # $t1: Left string pointer
    li $t2, 0               # $t2: Right string pointer
    li $t3, 0               # $t3: Sorted string pointer

interleave_loop:

    # If left string is empty add all of the remaining elements in the right string to the sorted string

    sub $t0, $s2, $t1       
    blez $t0, left_empty_loop

    # If right string is empty add all of the remaining elements in the left string to the sorted string

    sub $t0, $s3, $t2
    blez $t0, right_empty_loop

    add $t0, $s0, $t1       # $t0: Now holds the address of the (t1)th character
    lb $s4, 0($t0)          # $s4: x (of x :: xs) Load the character into $s4

    add $t0, $s1, $t2       # $t0: Now holds the address of the (t2)th character
    lb $s5, 0($t0)          # $s5: y (of y :: ys) Load the character into $s5

    # If y < x then branch to yltx

    add $t4, $v0, $t3       # $t4: The next available position in the sorted array

    sub $t0, $s4, $s5
    bgtz $t0, yltx

# x < y
    sb $s4, 0($t4)          # Store x in the next available position in the sorted array
    addi $t3, $t3, 1        # Increment the sorted array pointer
    addi $t1, $t1, 1        # Increment the start pointer of the left array 
    j interleave_loop       
# y < x 
yltx:
    sb $s5, 0($t4)          # Store y in the next available position in the sorted array 
    addi $t3, $t3, 1        # Increment the sorted array pointer
    addi $t2, $t2, 1        # Increment the start pointer of the right array 
    j interleave_loop

left_empty_loop:

    # If start of right is greater than end of right

    sub $t0, $s3, $t2
    blez $t0, interleave_end

    add $t0, $s1, $t2       # $t0: Now holds the address of the (t2)th character
    lb $s5, 0($t0)          # $s5: y (of y :: ys)

    add $t4, $v0, $t3       # $t4: The next available position in the sorted array

    sb $s5, 0($t4)          # Store y in the next available position in the sorted array 
    addi $t3, $t3, 1        # Increment the sorted array pointer
    addi $t2, $t2, 1        # Increment the start pointer of the right array     
    j left_empty_loop

right_empty_loop:

    # If start of left is greater than end of left

    sub $t0, $s2, $t1 
    blez $t0, interleave_end

    add $t0, $s0, $t1       # $t0: Now holds the address of the (t2)th character
    lb $s4, 0($t0)          # $s4: x (of x :: xs)

    add $t4, $v0, $t3       # $t4: The next available position in the sorted array

    sb $s4, 0($t4)          # Store x in the next available position in the sorted array 
    addi $t3, $t3, 1        # Increment the sorted array pointer
    addi $t1, $t1, 1        # Increment the start pointer of the left array     
    j right_empty_loop

interleave_end:

    #$v0: Is already the address of the sorted string
    add $v1, $s2, $s3       # $v1: The length of the sorted string (The sum of the component string lengths)
    add $t0, $v0, $v1
    sb $zero, 0($t0)        # Add the null pointer to the end

    lw $ra, 16($sp)
    lw $s0, 12($sp)
    lw $s1, 8($sp)
    lw $s2, 4($sp)
    lw $s3, 0($sp)
    addi $sp, $sp, 20

    jr $ra

# Make $t8 point to the other part of the heap
# $t8: Always points to one oof the two first positions in the heap
# $t7: Stores the current state of the heap pointer ($t8)
flip:                   
    beq $t7, $zero, up
#down
    addi $t8, $t8, -4
    li $t7, 0       
    j back
up:   
    addi $t8, $t8, 4
    li $t7, 1
    j back
back:
    jr $ra

# Set up heap to point to free spaces in memory
SET_HEAP:
    addi $a2, $a2, 2
    move $t4, $a0           # $t4: Temporary storage for $a0 while it is used to allocate heap space

    move $t0, $s6           # $t0: Points so the allocated memory for storing temporary strings
    sw $t0, 0($t8)          # Store the pointer to the allocated space in the heap

    # The amount of allocated space in the first 2 heap addressed will never exceed half the maximum word length + 1 so that is the maximum we assign it

    li $t1, 2               # Calculating the length of the word (divided by 2) + 1
    div $t1, $a2, $t1
    addi $t1, $t1, 1        
    
    add $t0, $t0, $t1
    sw $t0, 4($t8)          # Store this address in the second position of the heap

    add $t0, $t0, $t1

    move $t9, $t0           # $t9: The sorted string at the end of interleave

    add $a3, $t0, $a2       # $a3: Set set the next free address in memory
    move $s6, $a3           # $s6: Also the next free address in memory
    
    move $a0, $t4           # Load the original value of $a0 back in
    addi $a2, $a2, -2       # Change $a2 to be the pointer for the last character in the given string

    jr $ra