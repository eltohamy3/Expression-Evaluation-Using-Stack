.data
# Global variables
	filteredExp:  				.space 1200					# filtered expression
	standardExp:    			.space 1200     			# Assuming res array 
	minusMul: 					.asciiz  "(0-1)*"
	minusDiv: 					.asciiz  "(0-1)/"
	fail_msg: 					.asciiz "Expression is not valid.\n"
	restart: 					.asciiz  "please press any key in the keyboard to  restart the program..."
	restart_done: 				.asciiz "Restart Done\n"
	head: 						.word 0            		# Pointer to the head of the linked list (initialized to null)  # integer stack 
	stack_size: 				.word 0      				# Size of the stack (initialized to 0)   #integer stack 
	array_size: 				.word 0
	string_array: 				.space 1000
	tempStringSize: 			.word 0
	newLine:						.asciiz "\n"
	space:						.asciiz " "		
	tempString:  				.space 36
	expression:  				.space 1200
	tempExpression: 			.space 1200
	emptyStack:   				.asciiz "Stack is empty\n"
	prompt:       				.asciiz "Enter infixExpression : "
	valuPrint:      			.asciiz "Value: "
	POS_Str:         			.asciiz "postfix Expression = "
	STANDARD_STR:     		.asciiz "Standard Expression = "
.text
.globl main
main:
	# tempexpression --> filteredExpression --> standardExpression
	la $a0 , prompt
	jal printString					# prompt message
         
	la $a0 , tempExpression
	li $a1 , 100
	li $v0 , 8 
	syscall								# input expression

	la $t0 , tempExpression 		# expression's address
	la $t1 , filteredExp	# filtered expression's address
	li $t3 , ' '
	li $t4 , '\n'
	Filterloop:
		lb $t2 , 0($t0)			# load from expression
		beq $t2 , $zero , null
     	beq $t2 , $t3 , incrementFlterLoop
   	beq $t2 , $t4 , incrementFlterLoop
    	sb $t2 , 0($t1)		# store in the filtered one
    	addi $t1 , $t1 , 1
    	incrementFlterLoop:
      	addi $t0 , $t0 , 1
       	j Filterloop                    
    	null:
      	sb $t2 , 0($t1)					# null terminating the filtered expression
   		j exiteFilterLoop                 
	exiteFilterLoop:
		jal toStandardInfix 
    	la $a0, STANDARD_STR        		# Load address of res
    	jal printString

  		la $a0, standardExp        # Load address of res
   	jal printString
    	jal printNewLine   	 
   	 
   	# Load address of the string into $a0
  	  	la $a0, standardExp
  	  	# Call the Bal function to check parentheses balance
    	jal validParentheses
    	
    	beq $v0,$0,not_valid
   	# Call the isValidExpression function
   	la $a0 , standardExp
    	jal isValidExpression

    	# Check the result
      bne $v0, $zero, valid
	not_valid:
		la $a0 , fail_msg
		jal printString
	
		la $a0 , restart
		jal printString
	
		li $v0 , 12   # system call for read char  
		syscall 
		li $t0 , 0 
		li $t1 ,20 
	
	newLineLOOP:
	 	beq $t0 , $t1 ,  exite_newLineLOOP	    
		jal printNewLine	    
		addi $t0 , $t0 ,1 
		j newLineLOOP
	    
	exite_newLineLOOP:
		la $a0 , restart_done
		jal printString	       	    
	 	j main
  	 
 	valid:      
    	la $t0 , standardExp
     	la $t1 , expression
	copyloop1:
     	lb $t2 , 0($t0)
    	beq $t2 , $zero , null12
     	sb $t2 , 0($t1)
    	addi $t1 , $t1 , 1
     	addi $t0 , $t0 , 1
     	j copyloop1
	null12:
    	sb $t2 , 0($t1)
  		j exitecopyloop1                 
 	exitecopyloop1:
         
		jal Infix_to_postfix
		
      la $a0 , POS_Str
      jal printString
        	    
     	la $s4, string_array
 		li $s5, 0
 		lw $t6, array_size
 		
	print_postfix_loop:
		bge $s5, $t6, end_print_postfix_loop  
  		sll $t7, $s5, 2
   	add $t7, $t7, $s4
    	lw $t8, 0($t7)   			
   	move $a0, $t8
    	jal printString    
    	addi $s5, $s5, 1        
   	j print_postfix_loop
	end_print_postfix_loop:
 		jal printNewLine    		   
  		la $a0 , string_array
  	  	jal Evaluation

   	move $t0 , $v0    # $t0 contane the result  
     	la $a0 , valuPrint
   	jal printString

  		li $v0 , 1 
  		move $a0 , $t0 
  		syscall
	
		li $v0, 10 # end program
   	syscall
#----------------------------------------------------------------------------------------------------------
toStandardInfix:
	addi   $sp ,$sp ,-4 
	sw $ra , 0($sp)
	
	# counter i 
	li $t3 , 0    		
	# &filtered expression 					
	la $s0 , filteredExp  
	# standardExpression size 	
	li $s1 ,0   			
	# &standardExpression 				
	la $s2 , standardExp	
	
	to_standard_infix_loop:
		# t1 --> s[i]        t0 --> s[i-1]	
		# load from filteredExpression	
		lb $t1 , 0($s0) 					
		# if(null-terminator) break
		beq $t1 , $zero , end_to_standard_loop 
		# if(i != 0) jump
		bne $zero ,$t3  , I_largThanZero		
		# if(s[0] == '-') push (0-1)*	
   	beq $t1, '-', Edit_for_multiplication	
   	# if(exp[0] == '+') continue
		beq $t1 , '+', next_iteration		
		# if(exp[0] != '-' && exp[0] != '+') push			
		j push_to_res									
		
		I_largThanZero:
			# filteredExpression[i-1]
			lb $t0 , -1($s0)  					
		   # if(exp[i] != '+') jump  	
			bne $t1 , '+' , continue			
		     		
		  	# if(exp[i] == '+')
		  	# $v0 = isOperator(exp[i-1])
			move $a0 , $t0	
    		jal isOperator     				
    		# if(exp[i]=='+' && isOperator(exp[i-1]))	continue	
       	beq $v0,$0, handlerightbracket
      	j next_iteration				
       		      
     		handlerightbracket:
     			# if(exp[i]=='+' && exp[i-1] == '(')	continue
       		beq $t0 , '(' , next_iteration	
       		# else
       		j push_to_res				
		
				# if(exp[i] != '+')	     
        	continue:
        		# if(exp[i] != '(')	jump
        		bne $t1, '(',continue2	
        		# if )( --> push '*'	
           	beq $t0,')',add_asterisk   
           	   
           	# isDigit(s[i-1])
          	move $a1 , $t0
          	jal isDigit 
          	# if(!isDigit(s[i-1])) jump  						
          	beq $v0,$0, continue2
          	# if A( --> push '*'    			
          	j add_asterisk						      	 
		
				# if(exp[i] != '(' || !isDigit(exp[i-1]))
      	continue2: 
      		# if(exp[i] != '-') push s[i]
          	bne $t1, '-', push_to_res	
                	
           	# if(exp[i] == '-')  
           	# $v0 = isOperator(s[i-1])      
          	move $a0 , $t0
           	jal isOperator    
           	# if(!isOperator(s[i-1])) jump    			
          	beq $v0, $0, not_operator 	   
                	
         	# if(isOperator(s[i-1]))
         	# if /-	--> push (0-1)/
           	beq $t0, '/', Edit_for_division	
           	# else  --> push (0-1)*
          	j Edit_for_multiplication			
      	not_operator:
      		# if (- --> push (0-1)*
         	beq $t0,'(',Edit_for_multiplication	
         	# else
          	j push_to_res								

      	Edit_for_multiplication:
      		# push (0-1)*
        		la $a1, minusMul		
          	jal Copy_additional_expression		
           	j next_iteration
     		Edit_for_division:
     			# push (0-1)/
         	la $a1, minusDiv
          	jal Copy_additional_expression	
          	j next_iteration
         
        	add_asterisk:
        		# Load the ASCII code for '*'
        		li $t4, '*'    			
        		# next standardExp's idx	
       		add $t8 , $s2 , $s1   	
       		# Storing an * 	
        		sb $t4, 0($t8)        	
        		# increase the size of the standardExp 	
        	 	addi $s1, $s1 , 1  
        	 	# pushing the '('  		
        		j push_to_res					

    		push_to_res:
    			# next standardExp idx
       		add $t8 , $s2 , $s1	
       		# store filteredExp[i] in standardExp	
        	 	sb $t1, 0($t8) 
        	 	# increase the size of the standardExp            	
        		addi $s1, $s1 , 1         	
       	next_iteration:
       		# i ++
				addi $t3, $t3 , 1				
				addi $s0, $s0 , 1				 
         	j to_standard_infix_loop
	end_to_standard_loop:
	
    	add $t8 , $s2 , $s1   
     	sb $zero, 0($t8)                	
    	lw $ra , 0($sp)
   	addi $sp , $sp , 4 
     	jr $ra				
#----------------------------------------------------------------------------------------------------------
# a1 --> the string to be copied ("(0-1)")
# copy loop function 
Copy_additional_expression:
  	addi $sp , $sp , -16 
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
   
   # &standardExp
	la  $t0  , standardExp   
	# &minusDiv or & minusMul
  	move $t1 , $a1   		
	# index of the standardExp
	add $t0 , $t0 , $s1   				
   	
 	Copy_additional_expression_loop:
  		# Load from minusMul or minusDiv
  		lb  $t2, 0($t1)   
  		# if(null-terminator)	break    			
 		beq  $t2, $zero, done_copy 
 		# store in standardExp 	
 		sb   $t2, 0($t0)
		# incerment both memory locations       			
		addi $t0, $t0, 1             	
  		addi $t1, $t1, 1
  		# increment standardExp's size      
  		addi $s1 , $s1,1 
  		# loop  				 
  		j  Copy_additional_expression_loop
  	done_copy:
    	lw $t0 , 0($sp)
    	lw $t1 , 4 ($sp)
    	lw $t2 , 8 ($sp)
    	lw $t3 , 12 ($sp)
    	addi $sp , $sp , 16
   	jr $ra
#----------------------------------------------------------------------------------------------------------
isValidExpression:
    addi $sp, $sp, -16   
    sw $ra, 0($sp)      
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    sw $t2, 12($sp)
    
    # &standardExp
    move $t2 , $a0    
    # flag for the previous char 
    # 1-->digit, 2-->operator
    # 3-->'(',   4-->')'
    li $t0, -1           

    IsvalidLoop:
    	# load from standardExp
   	lb $t1, 0($t2)  
   	# if('\n') break
   	beq $t1, '\n', end_loop
   	# if(null-terminator) break
    	beqz $t1, end_loop  
    	# moving to next character
   	addi $t2, $t2, 1  
        
   	# Check character
    	beq $t1, '(', check_open_bracket
     	beq $t1, ')', check_close_bracket
        
  		# call isDigit function    $v0 return flage 
    	move $a1 , $t1
     	jal isDigit         # check if character is a digit
        
   	bne $v0, $zero, checkDigit
        
    	# call is operator function  
    	move $a0 , $t1 
     	jal isOperator
     	# if not a digit, check if it's an operator
     	bne $v0, $zero, check_operator  

    check_open_bracket:
    	# if previous was ')' or initial, return false
   	beq $t0, 4, unbalanced 
   	# if previous was a digit, return false 
     	beq $t0, 1, unbalanced 
     	# set prev = 3 (for '(')
    	li $t0, 3               
     	j IsvalidLoop

    check_close_bracket:
    	# if previous was initial, return false
     	beq $t0, -1, unbalanced 
     	# if previous was '(', return false
     	beq $t0, 3, unbalanced  
     	# if previous was operator , return false
     	beq $t0, 2, unbalanced  
     	# set prev = 4 (for ')')
     	li $t0, 4               
     	j IsvalidLoop
	checkDigit:
   	beq $t0, 4, unbalanced
  	  	li $t0, 1
    	j IsvalidLoop    

    check_operator:
    	# if previous was initial, return false
    	beq $t0, -1, unbalanced  
    	# if previous was an operator, return false
    	beq $t0, 2, unbalanced   
    	# if previous was '(', return false
    	beq $t0, 3, unbalanced  
    	# set prev = 2 (for operator) 
  		li $t0, 2                
     	j IsvalidLoop

    end_loop:
    	# if previous was '(', return false
    	beq $t0, 3, unbalanced   
    	# if previous was an operator, return false
    	beq $t0, 2, unbalanced   
    	# return 1 (true)
     	li $v0, 1                
     	j end_expression

    unbalanced:
    	# return 0 (false)
   	li $v0, 0                

    end_expression:
   	 lw $ra, 0($sp)      
   	 lw $t0 , 4($sp)
   	 lw $t1 , 8($sp)
    	 lw $t2, 12 ($sp)
    	 addi $sp , $sp 16
       jr $ra                    
#----------------------------------------------------------------------------------------------------------
validParentheses:
    addi $sp, $sp, -4   
    sw $ra, 0($sp)      
    
    # counter i
    li $t0, 0           

    # Loop over the string
    loop2:
    	# load from standardExpression
   	lb $t1, 0($a0)  
   	# if(null-terminator) break
    	beqz $t1, end_loop2 
    	# moving to the next character
     	addi $a0, $a0, 1  

     	# increment counter if '('
  		beq $t1, '(', increase_cnt
  		# decrement counter if ')'
    	beq $t1, ')', decrease_cnt
    	# loop
     	j loop2           

    increase_cnt:
    	# increment counter
    	addi $t0, $t0, 1  
     	j loop2

    decrease_cnt:
    	# decrement counter
    	addi $t0, $t0, -1 
    	# if(counter < 0) return 0
     	bltz $t0, unbalanced2
     	j loop2

    unbalanced2:
    	# return 0
     	li $v0, 0          
     	j end_balance2

    end_loop2:
    	# if(counter != 0) return 0
     	bnez $t0, unbalanced2
     	# else return 1
     	li $v0, 1       

    end_balance2:
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra 
#----------------------------------------------------------------------------------------------------------
Infix_to_postfix:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	# temp --> to split the expression
	li $t2, 0	
	# counter	
	li $t4, 0		
	stringLoop:
		# $t5 = expression[i]
		lb $t5, expression($t4)	
		# if(expression[i] == '\n') break		
		beq $t5, '\n', exitStringLoop	
		# if(null-terminated) break
		beq $t5, $zero, exitStringLoop
		# if(expression[i] == ' ') continue		
		beq $t5, ' ', increment			

		# isDigit's argument
		move $a1, $t5			
		# $v0 = isDigit(expression[i])	
		jal isDigit				
		# if(isOperator(expression[i])) jump
		beq $v0, $zero, operator		
		innerLoop:
			# if(expression[i]) == ' ') continue
			beq $t5, ' ', increment		
			# $t3 = int(expression[i])
			addi $t3, $t5, -48	
			# temp = temp * 10	
			mul $t2, $t2, 10		
			# temp = temp * 10 + int(exp[i])
			add $t2, $t2, $t3	
			# i ++	
			addi $t4, $t4, 1		
			
			# loading the next char
			lb $t5, expression($t4)
			# if(expression[i] == '\n') break
			beq $t5, '\n', exitStringLoop	
			# if(null terminated) break 
			beq $t5, $zero, exitStringLoop		
			
			# isDigit's argument
			move $a1, $t5		
			# $v0 = isDigit(expression[i])	
			jal isDigit			
			# if(!isDigit(exp[i]))	break
			bne $v0, $zero, innerLoop	
		exitInnerLoop:	
			# i --
			addi $t4, $t4, -1		
			# toString's argument
			move $a0, $t2
			# toString(temp)			
			jal toString		
			# pushStringToArray()	
			jal pushStringToArray		
			# temp = 0	
			li $t2, 0			
			# i++ and loop			 
			j increment			
		operator:
			beq $t5, '(', leftParenthesis	
			beq $t5, ')', rightParenthesis	
			bge $t5, 42, else
			
			# if(expression[i] == '(') push
			leftParenthesis:		
				# argument
				move $a0, $t5		
				# stackPush(exp[i])
				jal push		
				# i++ and loop
				j increment		
						
			rightParenthesis:		
				parenthesisLoop:
					# $v0 = stackTop()
					jal top		
					# $t6 = $v0
					move $t6, $v0		
					# loop until '(' is found
					beq $t6, '(', exitParenthesisLoop	
					
					# pushToString's argument
					move $a1, $t6		
					# pushToString(stackTop())	
					jal pushToString	
					# push the operator to the array
					jal pushStringToArray	
					# stackPop()
					jal pop	
					# loop	
					j parenthesisLoop	
				exitParenthesisLoop:
					# stackPop()
					jal pop		
					# i++ and loop
					j increment		
			else:
				elseLoop:
					# $v0 = stackTop()
					jal top	
					# $t6 = $v0 		
					move $t6, $v0		
					# exit if stack is empty	
					beq $t6, -1, exitElseLoop	
										
					# if(stackTop() == '^') t0 = 1 
					seq $t0, $t6, '^'		
					# if(exp[i] == '^') t1 = 1 
					seq $t1, $t5, '^'		
					# $t1 = $t0 & $t1
					and $t1, $t1, $t0		
					# if("^^") push(exp[i])
					beq $t1, 1, exitElseLoop	
					
					# periority's argument
					move $a0, $t5			
					# $v0 = periority(exp[i])
					jal periority			
					# $t7 = returned value 
					move $t7, $v0			
					
					# periority's argument
					move $a0, $t6			
					# $v0 = periority(stackTop())
					jal periority			
					# pushing the largest priority
					bgt $t7, $v0, exitElseLoop	
					
					# pushToString's argument
					move $a1, $t6			
					# pushToString(stackTop())	
					jal pushToString		
					# push the operator to the array
					jal pushStringToArray		
					# stackPop()
					jal pop	
					# loop		
					j elseLoop			
				exitElseLoop:
					# stackPush's argument
					move $a0, $t5			
					# stackPush(exp[i])		
					jal push			
		increment:
			# i++
			addi $t4, $t4, 1	
			# loop
			j stringLoop		
	exitStringLoop:
		# i-- --> expression.size
		addi $t4, $t4, -1			
		# $t1 = expression[size - 1]
		lb $t1, expression($t4)			
		# if($t1 == ')') empty the stack
		beq $t1, ')', stackNotEmptyLoop		
		# toString's argument
		move $a0, $t2				
		# toString(exp[size - 1])
		jal toString				
		# pushStringToArray()
		jal pushStringToArray			
	
	stackNotEmptyLoop:
		# $v0 = stackTop()
		jal top		
		# $t6 = $v0	
		move $t6, $v0			
		# if(stackEmpty()) exit
		beq $t6, -1, exitStackNotEmptyLoop	
	
		# pushToString's argument
		move $a1, $t6		
		# pushToString(stackTop())
		jal pushToString	
		# pushStringToArray()
		jal pushStringToArray	
		# stackPop()
		jal pop		
		# loop
		j stackNotEmptyLoop	

	exitStackNotEmptyLoop:
	
		lw $ra, 0($sp)
		addi $sp, $sp, 4
    	jr $ra

#----------------------------------------------------------------------------------------------------------
toString:	# String toString(int num)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
    	
	li $t1, 10      	# base
	move $t2, $a0    	# num
	li $t3, 0        	# i

	convert_loop:
		# num / 10
    	div $t2, $t1  
    	# $t9 = num % 10    		
   	mfhi $t9          
   	# $t9 = char(num)		
   	addi $t9, $t9, 48 
   	# storing the char in tempString     		
    	sb $t9, tempString($t3)  
   	# get the quotient   	
   	mflo $t2       
    	# increment i       		
    	addi $t3, $t3, 1   
    	# repeat until quotient is zero    		
    	bnez $t2, convert_loop 		
    	j reverse

	reverse:
   	li $t1, 0		
   	# store the size of the tempString
    	sw $t3, tempStringSize	
    	# the last index of the string
    	addi $t3, $t3, -1   	

	reverse_loop:
		# Exit loop if start index >= end index
  		bge $t1, $t3, reverse_done  	
  		# Load character at start index
   	lb $t2, tempString($t1)		
   	# Load character at end index
  		lb $t8, tempString($t3)         
  		# Store character from end index at start index
    	sb $t8, tempString($t1)         
    	# Store character from start index at end index
    	sb $t2, tempString($t3)       
    	# Move start index forward  
    	addi $t1, $t1, 1              	# Move end index backward  	
   	addi $t3, $t3, -1  
   	# loop        	
    	j reverse_loop			

	reverse_done:
   	lw $ra, 0($sp)
    	addi $sp, $sp, 4
    	jr $ra
#----------------------------------------------------------------------------------------------------------
isDigit:	# bool isDigit(char c);
		# Set the default value to 0
    	li $v0, 0          
    	# if(exp[i] < '0') return 0
    	blt $a1, '0', end_isDigit	
    	# if(exp[i] > '9') return 0
    	bgt $a1, '9', end_isDigit	
    	# if(exp[i] >= '0' && exp[i] <= '9') return 1
    	li $v0, 1          

	end_isDigit:
    	jr $ra             # return
#----------------------------------------------------------------------------------------------------------
pushToString:	# void pushToString(char c);
	# index where we will push the char	
	lw $t0, tempStringSize		
	# tempString[size] = c
	sb $a1, tempString($t0)		
	# size ++
	addi $t0, $t0, 1		
	# updating the size of the tempString
	sw $t0, tempStringSize		
	jr $ra
#----------------------------------------------------------------------------------------------------------
pushStringToArray:	# void pushStringToArray(string str);
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	# last index of the tempString
	lw $t0, tempStringSize		
	# pushing a null terminator
	sb $zero, tempString($t0)	
	
	# Allocating memory
	# allocating a memory whose address will be stored in $v0
	li $v0, 9			
	# size of the memory allocated (10 bytes)
	li $a0, 10			
	syscall
	# $t2 = address for the memory allocated
	move $t9, $v0			
	
	# copyString 1st's argument
	la $a1, tempString		
	# copyString 2nd's argument
	move $a2, $t9		
	# copyString(str1, str2)	
	jal copyString			
	
	# $t3 = array size
	lw $t3, array_size
	# offset = $t3 * 4		
	sll $t3, $t3, 2			
	# pushing the allocated memory address in the array 
	sw $t9, string_array($t3)	
	
	# $t3 = array size
	lw $t3, array_size	
	# incrementing the size	
	addi $t3, $t3, 1		
	# updating the size
	sw $t3, array_size		
		
	# $t0 = 0	
	li $t0, 0			
	# pointer of the tempString to index 0
	sw $t0, tempStringSize		
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
#----------------------------------------------------------------------------------------------------------
copyString:	# copyString(string str1, string str2)
	# Counter $s0 = 0
	li $s0, 0	
	copyStringloop:
		# address of tempString[i]
		add $t1, $s0, $a1	
		# $t2 = name[i]
		lb $t8, 0($t1)		
		# if(str1[i] == '\0')	break		
		beq $t8, $zero, exitCopyStringLoop	
		# address of memory allocated	
		add $t1, $s0, $a2		
		# copying the character		
		sb $t8, 0($t1)			
		# increment $s0
		addi $s0, $s0, 1		
		# Loop until reaching the null terminator
		j copyStringloop	
	exitCopyStringLoop:
	jr $ra
#----------------------------------------------------------------------------------------------------------
periority:   
	addi $sp, $sp, -4
	sw $t5, 0($sp)

	# ASCII for '+'
	li $t1, '+'  
	# ASCII for '-'
	li $t8, '-'  
	# ASCII for '*'
	li $t9, '*'  
	# ASCII for '/'
	li $t0, '/'  
	# ASCII for '^'
	li $t5, '^'  

   # Check the input character and return priority
   beq $a0, $t1, plus_minus_label
   beq $a0, $t8, plus_minus_label
   beq $a0, $t9, multiply_division_label
   beq $a0, $t0, multiply_division_label
   beq $a0, $t5, exponential_label

	li $v0, 0
	j returnPriority
    	
	plus_minus_label:
		# Return 1 for '+' or '-'
		li $v0, 1   
		j returnPriority
    
	multiply_division_label:
		# Return 2 for '*' or '/'
    	li $v0, 2   
    	j returnPriority
    
	exponential_label:
		# Return 3 for '^'
   	li $v0, 3   
    	j returnPriority
    		
  	returnPriority:
		lw $t5, 0($sp)
		addi $sp, $sp, 4
		jr $ra
#----------------------------------------------------------------------------------------------------------
# function to Evaluate the result of a postifex expression 
Evaluation:
	#a0 address of the refrance array of  strings
	#loop for each string refrance in the array 
	#counter i
	li $t7 , 0   
	lw $t6 , array_size 
	# address of refrance array 
	move $s2 , $a0   

	# saving the return address in the stack  
	addi $sp, $sp, -4    
	sw   $ra, 0($sp)
	#move $t8 , $ra
	#ra is the position in the main function 

	loop:
		beq $t7 , $t6 , exite_loop

		# load the address of string 
		# refrance of string 
 		lw $a0 , 0 ($s2)  
		lb $a0 , 0 ($a0)
		beq $a0 , $zero , increment2
		jal isOperator

		beq $v0 , $0 , Number

		# get the top in v0 
		jal top   
		# b  
 		move $s3 , $v0   
 		jal pop 
 		# get the top in v0 
 		jal top    
 		# a 
		move $s4, $v0    
		jal pop 
		move $a0 , $s4
		move $a1 , $s3 
		lw $t0, 0($s2)	
		lb $a2 , 0($t0)
		jal makeoperation
		move $a0 , $v0 
		jal push
		increment2:
			addi $s2 , $s2 , 4 
			addi $t7  , $t7, 1
 			j  loop
		Number:
			# refrance of string to a0 
 			lw $a0 , 0 ($s2)  
  			jal strToInt
  			move $a0 , $v0 
  			jal push 
 			addi $s2 , $s2 , 4 
			addi $t7  , $t7, 1
			j  loop

	exite_loop:
		# result in $v0
  		jal top 
  		lw   $ra, 0($sp)    
   	addi $sp, $sp, 4   
   	jr $ra
#----------------------------------------------------------------------------------------------------------
# Function to convert a null-terminated string to an integer
# $a0: pointer to the input string
# Returns: the integer value of the string in $v0
strToInt:
    # use $t0 , $t1  , $t2, $t3  so save them in momory
    	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
    
    # Initialize variables
    # Loop counter i
    li $t0, 0        
    # Initialize ans to 0
    li $t1, 0        

	strToInt_loop:
		# Load the byte (character) from the string into $t2
   	lb $t2, 0($a0)   
   	# If the byte is 0 (null terminator), exit loop
   	beqz $t2, strToInt_done   
    
    	# ASCII value of '0'
    	li $t3, 48       
   	sub $t2, $t2, $t3

    	# Multiply ans by 10
    	mul $t1, $t1, 10

    	# Add the converted character to ans
   	add $t1, $t1, $t2

    	# Increment loop counter and pointer to next character
   	addi $t0, $t0, 1
   	addi $a0, $a0, 1

    	# Repeat the loop
    	j strToInt_loop

	strToInt_done:
  		# Return the result in $v0
  		# Move the result to $v0
  		move $v0, $t1        
  		lw $t0 , 0($sp)
		lw $t1 , 4 ($sp)
   	lw $t2 , 8 ($sp)
   	lw $t3 , 12 ($sp)
   	addi $sp  , $sp, 16 
    	jr $ra           
#----------------------------------------------------------------------------------------------------------
makeoperation:
	#arguments   ---->  operand1 a0,  operand a1 and operation a2
	
	 #use $t0  so save it on the memory
	 addi $sp , $sp , -4 
	 sw $t0 , 0($sp)
	#checking if the operation is +
	li $t0, '+'   
	beq $a2, $t0, plus_exit
	
	#checking if the operation is -
	li $t0, '-'   
	beq $a2, $t0, minus_exit
	
	#checking if the operation is *
	li $t0, '*'   
	beq $a2, $t0, mult_exit
	
	#checking if the operation is /
	li $t0, '/'   
	beq $a2, $t0, divison_exit
	
	#checking if the operation is ^
	li $t0, '^'   
	beq $a2, $t0, exponent_exit
	
	# if the input is invalid  
	# flag ig operation is invalid
	add $t1, $a0, $0   
	j exiteMakeoperation
	
	plus_exit:
		add $v0, $a0, $a1
		j exiteMakeoperation
 	
	minus_exit:
		sub $v0, $a0, $a1
		j exiteMakeoperation
 
	mult_exit:
		mul $v0, $a0, $a1
		j exiteMakeoperation
 	
	divison_exit:
		div $v0, $a0, $a1
		j exiteMakeoperation
 	
	exponent_exit:
    		addi $sp, $sp, -4    # saving the return address in the stack  
    		sw   $ra, 0($sp)
    		jal power           # calling power function
    		lw   $ra, 0($sp)    # restoring the return address
    		addi $sp, $sp, 4    # restore stack pointer to deallocate space for the return address
    
		j exiteMakeoperation
	exiteMakeoperation:
		lw $t0 , 0($sp)
		addi $sp , $sp, 4 
		jr $ra 
#----------------------------------------------------------------------------------------------------------
power:
	#arguments: base ---> a, exponenet ----> a1      2,3
	# use $t0 , $t1 , $t2 
	addi $sp , $sp, -12 
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	# result t1 = 1
	addi $t1, $0, 1  
	# index = 0 
	add $t0, $0, $0   
	loop1:
		slt $t2, $t0, $a1
		# if index > exponenet ----> exit loop
		beq  $t2, $0, exit_loop1    
		#  operation
		mul $t1, $t1, $a0   
		# incrementing index
		addi $t0, $t0, 1    
		j loop1
	exit_loop1:
		# result in V0
		add $v0, $t1, $0  
   	lw $t0 , 0($sp)
 		lw $t1 , 4 ($sp)
  		lw $t2 , 8 ($sp)
   	addi  $sp , $sp , 12 
		jr $ra	
#----------------------------------------------------------------------------------------------------------
isOperator:    
 	addi $sp , $sp , -24 
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	
	move $v0, $zero
	move $t0, $a0	
	li $t1, '+' 	 
	li $t2, '-' 	 
	li $t3, '*'	 
	li $t4, '/'	 
	li $t5, '^'   

	beq $t0, $t1, set
	beq $t0, $t2, set
	beq $t0, $t3, set
	beq $t0, $t4, set
	beq $t0, $t5, set
	j exit
	#exit label change boolean value
	set:
		addi $v0, $zero, 1
	exit:
  		lw $t0 , 0($sp)
 		lw $t1 , 4 ($sp)
   	lw $t2 , 8 ($sp)
    	lw $t3 , 12 ($sp)
    	lw $t4 , 16 ($sp)
    	lw $t5 , 20 ($sp)
  		addi $sp ,$sp , 24
		jr $ra	
#----------------------------------------------------------------------------------------------------------
#a0 = value to be push 
push:   
 	# use $t5 , $t0 , $t1
 	addi $sp , $sp , -12
  	sw $t0 , 0 ($sp)
  	sw $t1 , 4 ($sp)
  	sw $t2 , 8 ($sp)      
  	add $t2,$zero,$a0	# assign the value to be pushed in $t2
    
   # System call for memory allocation 
 	li $v0, 9  
 	# Allocate memory for 2 words (node structure)           	
  	li $a0, 8    
  	# Allocate memory and store address in $v0         	
  	syscall               	

 	#move $a0 , $t2
 	# Store the data value in the node's 'value' field
 	sw $t2, 0($v0)        	

 	# Link the new node to the current head of the linked list
 	# Load the current head pointer
  	lw $t0, head          	
  	# Store the address of the current head in 'next' field of the new node
 	sw $t0, 4($v0)      
 	# Update the head pointer to point to the new node  	
 	sw $v0, head          	

 	# Increment the stack size
 	# Load the current stack size
  	lw $t1, stack_size    	
  	# Increment the stack size
  	addi $t1, $t1, 1      	
  	# Store the updated stack size
  	sw $t1, stack_size    	
    	
  	lw $t0 , 0 ($sp)
  	lw $t1 , 4 ($sp)
  	lw $t2 , 8 ($sp)
  	addi $sp , $sp, 12 
  	jr $ra                	
#----------------------------------------------------------------------------------------------------------
# Pop operation to remove a node from the stack
pop:
	#use  #$t0 , $t2  and save $ra 
 	addi $sp , $sp , -12
	sw $ra, 0($sp) 
	sw $t0 ,4($sp) 
	sw $t2 , 8($sp)
	
  	#lw $t0, stack_size           
	lw $t0, head
	# Check if the stack is empty (head is null)
 	beq $t0, $zero, pop_empty  	
	
 	# Update the head pointer to point to the next node
 	# Load the address of the next node
 	lw $t0, 4($t0)        		
 	# Update the head pointer
 	sw $t0, head          		

  	# Decrement the stack size
  	# Load the current stack size
 	lw $t2, stack_size    	
 	# Decrement the stack size
  	addi $t2, $t2, -1     	
  	# Store the updated stack size
  	sw $t2, stack_size    	
    	
 	j exitePop
	pop_empty:
   	# Stack is empty, handle error or return safely
    	la $a0, emptyStack
   	jal printString 
	exitePop:
		lw $ra, 0($sp) 
		lw $t0 ,4($sp) 
		lw $t2 , 8($sp)
		addi $sp , $sp , 12
   	jr $ra  # return to the caller (evaluation function )
#----------------------------------------------------------------------------------------------------------
# Get the size of the stack
size:
	# Load the stack size
  	lw $v0, stack_size    	
  	jr $ra                	# Return to the caller    
#----------------------------------------------------------------------------------------------------------
# Top operation to return the value at the top of the stack
top:
	# lw $t0, stack_size           	
 	# use $t0 so save it to the Memory
	addi $sp , $sp , -4 
	sw $t0 , 0 ($sp)
    	
  	lw $t0, head
  	# Check if the stack is empty (head is null)
 	beq $t0, $zero, top_empty  	
   # Load the value stored in the top node 	
 	lw $v0, 0($t0)       
 	# Return to the caller 	
  	j exit_top              	

	top_empty:
  		# Stack is empty, handle error or return safely
  		# Return -1 (or set to an appropriate error value)
  		li $v0, -1           	

 	exit_top:
    	lw $t0 , 0 ($sp)
    	addi $sp , $sp , 4
    	jr $ra               	 
#----------------------------------------------------------------------------------------------------------
isEmpty:
    	# Load the head pointer     	
    	lw $v0, head
    	# Set $v0 to 1 if head is null (stack is empty), otherwise 0
    	seq $v0, $v0, $zero   		
    	jr $ra                		
#----------------------------------------------------------------------------------------------------------
# function to delete all element to the stack 
free:
	# it use $t0 so save it to the memory 
	addi $sp , $sp , -4 
	sw $t0 , 0 ($sp ) 
  	#load the head to $t0 
	lw $t0, head
	#loop untill $t0 = 0 (first head )
	loopEmpty:
		beq $t0, $zero, exitLoopEmpty
		lw $t0, 4($t0)
		j loopEmpty
	exitLoopEmpty:	
		sw $t0, head
		lw $t0 , 0 ($sp)
		addi $sp , $sp ,4
		jr $ra
#----------------------------------------------------------------------------------------------------------
# function to print stack elements
print:
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $t0 , 4($sp)

	lw $t0, head					# the top pointer
	bne $t0, $zero, loopPrint				# check if it's empty
	
	la $a0, emptyStack				# message
 	jal printString  
    	
 	j exitLoopPrint
	loopPrint:
		# check if the pointer reached null
		beq $t0, $zero, exitLoopPrint		
		# printing the current value
		lw $a0, 0($t0)				
		jal printInteger		
		jal printNewLine		
		# moving to the next node
		lw $t0, 4($t0)				
	 	j loopPrint
	exitLoopPrint:	
		lw $ra, 0($sp)
		lw $t0 , 4($sp)
		addi $sp, $sp, 8
		jr $ra
#----------------------------------------------------------------------------------------------------------
printNewLine:
	la $a0, newLine
	li $v0, 4
	syscall
	jr $ra		
#----------------------------------------------------------------------------------------------------------
printInteger:
	li $v0, 1
	syscall
	jr $ra
#----------------------------------------------------------------------------------------------------------
printString:
	li $v0, 4
	syscall
	jr $ra
#----------------------------------------------------------------------------------------------------------
printCharacter:
	li $v0, 11
	syscall
	jr $ra

