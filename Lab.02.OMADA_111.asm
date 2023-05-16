.data
message: .asciiz "Please enter a string:\n"
usersString: .space 100		
finalString: .space 100
.text
	main:
	#prints message "message"
	li $v0,4 
	la $a0 , message 
	syscall	
	jal Get_Input		 #calls subroutine "Get_Input" with jump and link		
	jal Process			 #calls subroutine "Process" with jump and link	
	jal Print_Output	 #calls subroutine "Print_Output" with jump and link			
	#terminates the program
	li $v0,10
	syscall
	
	Get_Input:	
		#get users string
		li $v0,8
		la $a0,usersString
		li $a1,100
		sw $v0,usersString	#stores the string
		syscall				
	jr $ra					#jump register in main where 'jal Print_Output' is	
		
	Process:
		addi $t0,$zero,0	#initialising the index of usersString
		addi $t7,$zero,0	#initialising the index of finalString
			
		while:
			
			lb $t1,usersString($t0)	#loads the specific byte of usersString in register $t1 in each loop
			addi $t3, $zero,10		#gives register $t3 the value of 'enter' in ascii 
			beq $t1,$t3,exit		#this branch exits the while when usersString ends
			
			addi $t4,$t7,-1			#gives index $t4 the previous index of the finalString in order to check if the previous byte is 'space'
			lb $t6,finalString($t4)	#loads the specific byte of finalStrig in register $t6 each loop 
			addi $t5,$zero,32		#gives register $t5 the value of 'space' in ascii to check later if the previous character of the finalString is space						
				
			#Check if the character is capital letter specifically if the ascii code of the letter is between A and Z  
			addi $t3, $zero,65		#in ascii 'A'->65
			slt $7, $9, $11         #bltu $t1,$t3,exit2,we used register $7 ($a3) to save the result of the comparison, exits if its less than 'A'
			bne $7, $0, exit2		
			addi $t3, $zero,90		#in ascii'Z'->90
			slt $7, $11, $9         #bgtu $t1,$t3,exit2, exits if its greater than 'Z' 
			bne $7, $0, exit2		
			addi $t2,$t1,32			#adds to register $t1 32(in ascii code) in order to change the letter from capital to lowercase
			addi $t1,$t2,0			#moves register $t2 to $t1 in order to store byte in the finalString
				
			#Check if the character is between '!'  '/' 
			exit2:
			addi $t3, $zero,33		#in ascii '!'->33
			slt $7, $9, $11        
			bne $7, $0,exit3 		#bltu $t1,$t3,exit3,we used register $7 ($a3) to save the result of the comparison, exits if its less than '!'
			addi $t3, $zero,47		#in ascii '/'->33
			slt $7, $11, $9         
			bne $7, $0,exit3		#bgtu $t1,$t3,exit3,we used register $7 ($a3) to save the result of the comparison, exits if its greater than '/'
				
			beq $t6,$t5,exit7		#checks if the previous character is space, if it is it goes to exit7 else it goes to the next line
			addi $t2,$zero,32		#sets register $t2 to ascii 32 which is 'space'
			addi $t1,$t2,0			#moves register $t2 to $t1 in order to store byte in the finalString
				
			#Check if the character is between ':'  '@' 
			exit3:
			addi $t3, $zero,58		#in ascii ':'->58
			slt $7, $9, $11         #bltu $t1,$t3,exit4, exits if its less than ':'
			bne $7, $0,exit4
			addi $t3, $zero,64		#in ascii '@'->64
			slt $7, $11, $9         #bgtu $t1,$t3,exit4, exits if its greater than '@'
			bne $7, $0, exit4				
			beq $t6,$t5,exit7		#checks if the previous character is space, if it is it goes to exit7 else it goes to the next line
			addi $t2,$zero,32		#sets register $t2 to ascii 32 which is 'space'
			addi $t1,$t2,0			#moves register $t2 to $t1 in order to store byte in the finalString
			
			#Check if the character is between '['  '`' 
			exit4:
			addi $t3, $zero,91		#in ascii '['->91
			slt $7, $9, $11         #bltu $t1,$t3,exit5,exits if its less than '[' 
			bne $7, $0,exit5
			addi $t3, $zero,96		#in ascii '`'->96
			slt $7, $11, $9         #bgtu $t1,$t3,exit5,exits if its greater than '`' 
			bne $7, $0,exit5			
			beq $t6,$t5,exit7		#checks if the previous character is space, if it is it goes to exit7 else it goes to the next line
			addi $t2,$zero,32		#sets register $t2 to ascii 32 which is 'space'
			addi $t1,$t2,0			#moves register $t2 to $t1 in order to store byte in the finalString
				
			#Check if the character is between '{'  '~' 
			exit5:
			addi $t3, $zero,123     #in ascii '{'->123 
			slt $7, $9, $11         #bltu $t1,$t3,exit6 ,we used register $7 ($a3),exits if its less than '{'
			bne $7, $0,exit6
			addi $t3, $zero,126		#in ascii '~'->126
			slt $7, $11, $9         #bgtu $t1,$t3,exit6 ,exits if its greater than '~'
			bne $7, $0,exit6				
			beq $t6,$t5,exit7		#checks if the previous character is space, if it is it goes to exit7 else it goes to the next line
			addi $t2,$zero,32		#sets register $t2 to ascii 32 which is 'space'
			addi $t1,$t2,0			#moves register $t2 to $t1 in order to store byte in the finalString
			
			#stores the new string that has changed according to the exercise
			exit6:	
			sb $t1,finalString($t7) #stores byte to finalString	
			addi $t7,$t7,1			#if it stores something the index increases by one
			
			exit7:					#if the byte is a character and the previous byte was also a character then this exit does not store anything in the finalString					
			addi $t0,$t0,1			#increases the index of usersString by one in every loop in order to get every byte of usersString
		j while						#jumps to while loop
		exit:						#if the while loop has run as many times as the length of usersString it exits here		
	jr $ra							#jump register in main where 'jal Process' is
	
	Print_Output:
		#pirnts the string that has been processed to the final sting 
		li $v0 , 4                    
		la $a0,finalString           
		syscall			
	jr $ra							#jump register in main where 'jal Print_Output' is