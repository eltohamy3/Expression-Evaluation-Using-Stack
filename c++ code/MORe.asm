

.data 


	Myname: .asciiz "MY name is Abdelrahman Mahmoud Mohmamed\nSec:2\nBN:34\n"
	program_description: .asciiz "This is a simple program to call  the function f in the preveios examples .\n"


.text 
	.globl  main
	
main:
   	 li $v0, 4                  # System call code for print string
   	 la $a0,Myname    # Load address of Myname
   	 syscall
   	 #first tell the user what the program do 
   	 li $v0, 4                  # System call code for print string
   	 la $a0,program_description     # Load address of program_description 
   	 syscall
   	 
