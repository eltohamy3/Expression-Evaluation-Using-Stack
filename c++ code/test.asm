    .text
    .globl reverse

# Function to reverse the elements of an array of n integers

reverse:
        # Arguments:
        # $a0 = address of the array
        # $a1 = number n of elements
        move $s0 , $a0 

        # Initialize loop counters
        li $t0, 0      # Loop counter (start)
        li $t1, n-1     # Loop counter (end)
        
    reverse_loop:
        # Check if start counter is less than end counter
        bge $t0, $t1, end_reverse
        
        # load the start index 
        sll $t3 , $t0 , 2 
        add $t3 , $t3 , $s0 
        lw $t4  ,0 ($t3)

        # load the end index 
        sll $t5 , $t1 , 2 
        add $t5 , $t5 , $s0 
        lw $t6 , 0 ($t5)
        # swap elements 
        sw $t6 , 0($t3)
        sw $t4 , 0 ($t5)
        addi	$t0, $t0,1 
        addi	$t1, $t1, -1
        
        j reverse_loop
        
    end_reverse:
        jr $ra   # Return to caller
