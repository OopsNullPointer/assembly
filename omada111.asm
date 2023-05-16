.data
#Here are the messages that will be displayed on the console
message1: .asciiz "\nPlease enter your character:\n "
message2: .asciiz "\nThe String is:\n"
exitMessage: .asciiz "\n\nThank you for using our program!"
ArrayOfInputs: .space 100

.text
	main:
   
        #initialising the register $t0 which is used as an index for the array
		addi $t0,$zero,0

        while:    
       
            #prints the message "enter your character"
			li $v0,4
			la $a0 , message1
			syscall

			#gets users character
			li $v0,12                      #we used the number 12 to read character
			syscall
           
            #checks before storing if the character is "@"
			beq $v0, '@',exit              #we use register $v0 because the input is stored there temporarily
           
            #stores the character that the user entered
			sb $v0,ArrayOfInputs($t0)      #store the user's input from the register $v0 into the ArrayOfInputs($t0)
           
            #increasing the index by 1
			addi $t0,$t0,1

		j while

		exit:

		#prints the message "The String is"
		li $v0,4
		la $a0 , message2
		syscall

		#pirnts the string that the user entered
		li $v0 , 4                    
		la $a0,ArrayOfInputs($zero)          #we load the adress of the array into register $a0 and we use syscall to print it  
		syscall

		#prints the exit message
		li $v0,4
		la $a0 , exitMessage
		syscall

		#terminates the program
		li $v0,10
		syscall
