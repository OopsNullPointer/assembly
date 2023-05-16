.data
Prompt_Message	: .asciiz "\nPlease determine operation, entry (E), inquiry (I) or quit (Q):\n"
Final_Message	: .asciiz "\nThank you!\n"
errorMessage1	: .asciiz "\nThe character you have entered does not correspond to any operation.\n"
errorMessage2	: .asciiz "\nThere is no such entry in the phonebook.\n"
errorMessage3	: .asciiz "\nThere have already been 10 entries!\n"
I_Message		: .asciiz "\nEnter the number of the entry you wish to retrieve:\n"
nameMessage		: .asciiz "\nPlease enter first name:\n"
surnameMessage	: .asciiz "Please enter last name:\n"
phoneMessage	: .asciiz "Please enter the phone:\n"
PEMessage	    : .asciiz "\nThe number is:\n"
dotAndSpace		: .asciiz ". "
NEntryMessage	: .asciiz "\nThank you, the new entry is:\n"

.align 2
usersName	: .space 20	
usersSurname: .space 20
usersPhone	: .space 20
FString		: .space 62        					#Space of usersName + space + usersSurname + space + usersPhone  
list		: .space 620 
.text
	main:
		addiu $sp, $sp, -8 						#Makes space,by moving stack pointer.
		la $s3, list($zero)						#Loads adress of the start of the list (in $s3). 																
		sw $s3, 0($sp)							#Pushes  $s3(saves $s3 at offset 4).
		sw $ra, 4($sp)							#Main is a caller so we store the $ra.
		addi $s1, $0, 0  	 					#We initialize s1, the counter for the entries.
		addi $s2, $0, 0 						#Initialization of s2 (list's index). 
		
		while:					
			jal	Prompt_User						#We call the prompt user which prints the Prompt_Message and returns the user's character.
			addi $t0,$v0,0						#We set the register t0 to the return value of the promt_user 	###########!!!janablepo		
			
			ori $a3, $0, 81                     #81-> Q in ascii code
			beq $a3, $t0, exit 					#If the user presses Q the program is terminated by jumping to the exit1 which calls "Terminate_Program"	
			
			ori $a3, $0, 113					#113-> q in ascii code
			beq $a3, $t0, exit					#If the user presses q the program is terminated by jumping to the exit1 which calls "Terminate_Program"
			
			ori $a3, $0, 73						#73-> I in ascii code
			beq $a3, $t0, Print_Entry			#If the user presses I it jumps to Print_Entry. 		
			
			ori $a3, $0, 69						#69-> E in ascii code
			beq $a3, $t0, Get_Entry				#If the user presses E it jumps to Get_Entry.

			li $v0,4                    		#It prints an error message if the user has not entered a valid character.
			la $a0,errorMessage1 
			syscall		
		
		j while
		
		exit:
		lw $ra, 4($sp)							#Pops $ra.
		lw $s3, 0($sp)            				#Pops $s3.
		addiu $sp, $sp, 8 						#Resets stack pointer.
		jal Terminate_Program	        		#Terminates program.
	jr $ra
	
	Prompt_User:                       			#Prints "Prompt_Message" message and returns user's character.
		li $v0,4 								#Prints message "Prompt_Message" .
		la $a0,Prompt_Message			
		syscall
		
		li $v0,12								#Reads user's character.
		syscall	
	jr $ra                              		#Returns the character.

	Print_Entry:								#Asks user for the entry number they want to retrieve and prints that entry.
		ori $v0, $0, 4 
		la $a0,I_Message						#Prints message "I_Message" 
		syscall
	
		ori $v0, $0, 5							#Reads user's integer.
		syscall								
	
		addi $t6,$v0,0							#Sets register t6 to the value of the users input								
		addi $t4,$zero,1						#Sets register t4 to 1 in order to check if the user's integer is less than 1
		slt $a3, $t6, $t4						#bltu $t6,$t4,EInput,we used register $7 ($a3) to save the result of the comparison, exits if its less than 1
		bne $a3, $0, EInput
		slt $a3, $s1, $t6						#bgt  $t6,$s1,EInput,we used register $7 ($a3) to save the result of the comparison, if the input is above the existing number of entries
		bne $a3, $0, EInput												
												#Defines the boundraries of the wanted entry.  													
		addi $t4,$zero,62						#Sets register t4 to 62 which is the max space of one FString entry.
		mul  $t5,$t6,$t4						#Sets the max boundrary: t5(which is the (user's input) * 62 -1).
		addi $t5,$t5,-1	
		addi $t6,$t6,-1							#Sets the min boundrary: t3 (which is the (user's input-1) * 62).
		mul  $t3,$t6,$t4
		addi $t1,$zero,0						#Initializes the index of the FString(the string of the wanted entry)	.
		
		while6:							
			lb 	 $t2,list($t3)		 			#Loads each byte of the list to $t2.		
			sb 	 $t2,FString($t1)				#Stores $t2 to the FString.
			beq  $t3,$t5,endOfTheEntry			#Exits loop when the index of the list reaches max boundary.
			addi $t1,$t1,1              		#Increases index of FString.
			addi $t3,$t3,1			    		#Increases index of list.
		j while6
		
		endOfTheEntry:
		ori $v0, $0, 4
		la $a0,PEMessage						#Prints the PEMessage.
		syscall
		
		ori $v0, $0, 1							#Prints the integer the user had entered.
		addi $a0,$t6,1					
		syscall	
		
		ori $v0, $0, 4							#Prints dot and space in order to apear in console as ["number". ] exmpl 1. .....                    
		la $a0,dotAndSpace          
		syscall
		
		ori $v0, $0, 4							#Prints the entry the user had asked.              
		la $a0,FString          
		syscall	
		
		delete1:								#Deletes the "FString" array in order to reuse it later. 
			sb	 $zero,FString($t1)
			beq  $t1,$zero,while            	#Once the "FString" is deleted, it jumps back to the while in main.
			addi $t1,$t1,-1
		j delete1
		
	j while
	
		EInput:									#Prints the error message if the user enters an invalid character (different than 1 to number of entries).
		ori $v0, $0, 4                  
		la $a0,errorMessage2          
		syscall	
	j while                             		#Jumps back to the while in main.
		
	Get_Entry:
		slti $a3, $s1, 10 
		beq $a3, $0, FullEntries				#Checks if the user has entered more than 10 times if he does then it prints an error message and jumps back to the while in main. 
		addi $s1, $s1, 1						#Increases the counter for the entries.
		
		jal Get_Name                   			#Gets user's first name and stores it in the string usersName.
		jal Get_Surname							#Gets user's last name and stores it in the string usersSurname.
		jal Get_Phone                 			#Gets user's phone and stores it in the string usersPhone.
		jal combine								#Combines the 3 strings in 1 string (called "FString") with a space in between.
	 
	j while

	FullEntries:                   				#Prints an error message (too many entries) and jumps back to the while in main.
		ori $v0, $0, 4                    
		la $a0,errorMessage3          
		syscall	
	j while

	delete:                         			#Deletes the "FString" in order to reuse it later. 
		while5:          
			sb $zero, FString($a1)     			#$a1 is FString's length.
			beq $a1,$zero,continue
			addi $a1,$a1,-1
		j while5
		continue:
	jr $ra
	
    combine:									#here we combine all three (name surname snd phone) to one string with the name FString which later on is copied in the list which contains all the entries.
		addiu $sp, $sp, -4
		sw   $ra, 0($sp)						#Combine is a caller so we store the $ra.
		addi $13, $0, 32  						#we use register $t5 in order to add a space in the string between first name and last name and phone 32 is space in ascii code.
		addi $a1, $0, 0							#we use a1 to initialize the FString's index.
		addi $t4, $0, 0           				#we use $t4 and we initialize it as an index of usersName, usersSurname and usersPhone.
		addi $t3, $0, 10	          			#10 is enter in ascii code.
		addi $t6,$zero,19         		
		
		while1:			            			#we use register $a1, $t2 , $t3 ,$t4 in this while loop which are temporary registers and we load the first name in the FString array.
			lb  $t2,usersName($t4)				#we use $t2 to load byte from usersName in order to save each byte to the FString array.  				
			beq $t4,$t6,endName
			beq $t2,$t3,endName					#if it finds enter (10) it stops and the name is stored in the FString array and goes to endName.
		    sb  $t2,FString($a1)				#stores the first name letter by letter without the enter character.
		    addi $a1, $a1, 1  					#here we increase the index of the new string "FString" by 1.
			addi $t4, $t4, 1 					#here we increase the index of the "usersName" by 1.
		j while1
		
		endName:								#after the name ends the while1 loop exits here in order to continue saving in the FString array the last name and the phone.
			addi $t4,$zero,0					#set register $t4 to 0 in order to start loading bytes from usersSurname starting from 0 until the end.		
			sb $t5,FString($a1)					#here we save to FString array the space character in ascii in order to save the last name after the first name with a space in between.
			while2:								#we use register a1, t2 , t3 ,t4 in this while loop which are temporary registers and we load the last name in the FString array which contains the first name from the previous loop.	
				addi $a1,$a1,1					#Increase by 1 the index a1 (FString's index) after adding the space character and also for the loop.			
				lb   $t2,usersSurname($t4)		#We use t2 to load byte from usersSurname in order to save each bye to the FString array. 
				beq  $t4,$t6,endSurname
				beq  $t2,$t3,endSurname			#If it finds enter (10) it stops and the name is stored in the FString array and goes to endSurname.
				sb   $t2,FString($a1)			#Stores the last name letter by letter without the enter character.
				addi $t4, $t4, 1 				#Here we increase the index of the "usersSurname" by 1.
			j while2						

		endSurname:								#After the last name ends the while2 loop exits here in order to continue saving in the FString array the phone. 
			addi $t4,$zero,0					#Set register $t4 to 0 in order to start loading bytes from usersPhone starting from 0 untill the end.	
			sb $t5,FString($a1)					#Here we save to FString array the space character in ascii in order to save the phone after the last name with a space in between.
			while3:								#We load the last name in the FString array which contains the first name and last name from the previous loops.
				addi $a1,$a1,1					#Increase by 1 the index a1 (FString's index) after adding the space character and also for the loop.						
				lb   $t2,usersPhone($t4)		#We use t2 to load byte from usersPhone in order to save each bye to the FString array.
				beq  $t4,$t6,print_the_entry
				beq  $t2,$t3,print_the_entry	#If it finds enter (10) it stops and the name is stored in the FString array and goes to print_the_entry.
				sb   $t2,FString($a1)			#Stores the last name letter by letter without the enter caracter.
				addi $t4,$t4,1					#Here we increase the index of the "usersSurname" by 1.
			j while3							
			
		print_the_entry:						#Here is the end of the combine process and we print the new entry of the user.
		
		ori $v0, $0, 4 
		la $a0,NEntryMessage					#Prints the new entry message.
		syscall
		
		ori $v0, $0, 1
		move $a0,$s1							#Prints the counter for entries in order to print later the number like so 1. .... 
		syscall	
		
		ori $v0, $0, 4                    
		la $a0,dotAndSpace						#Prints dot and space in order to look like 1. ....         
		syscall
		
		ori $v0, $0, 4 
		la $a0,FString							#Prints the new entry in the console 
		syscall		
		
		jal make_List							#Entries the FString in the list.
		jal delete                    			#Deletes the "FString" in order to reuse it later. 
		
		lw $ra,0($sp)
		addiu $sp,$sp, 4
	jr $ra
	
	make_List:									#Makes the list that contains every entry. 
		addi $t1,$zero,0						#intitializing $t1 regster to 0 in order to save every byte to the lisst starting from 0 until $a1 which is its FString's length. 	

		while4:									
			lb	 $t7,FString($t1)				#Loads each byte of the FString to $t7.	
			sb 	 $t7,list($s2)					#Stores $t7 to the list.
			addi $s2,$s2,1						#Increases list's index.
			beq	 $t1,$a1,end1		    		#Exits loop when the index of the FString reaches its end.
			addi $t1,$t1,1						#Increases FString's index.
		j while4
		
		end1:
		addi $t1, $0, 62 						#Sets register $t1 to 62 which is the max space of one FString entry.
		sub $s3, $t1, $a1 
		addi $t2, $s3, -1 
		add $s2, $s2, $t2                       #Sets list's index $s2 = $s2 + (62 - FStrings_length) - 1	
	jr $ra
	
	Get_Name:									#Prints a message in the console and gets the first name the user has entered.
		ori $v0, $0, 4 
		la $a0,nameMessage						#Prints message for user to enter their First Name.
		syscall
		
		ori $v0, $0, 8								
		la $a0,usersName
		ori $a1, $0, 20
		sw $v0,usersName						#Stoes user's first name in string "usersName".
		syscall
	jr $ra
	
	Get_Surname:								#Prints a message in the console and gets the last name the user has entered.
		ori $v0, $0, 4 
		la $a0,surnameMessage					#Prints message for user to enter their Surname.
		syscall
		
		ori $v0, $0, 8 
		la $a0,usersSurname
		ori $a1, $0, 20
		sw $v0,usersSurname						#Stoes user's surname in string "usersSurname".
		syscall
	jr $ra
	
	Get_Phone:									#Prints a message in the console and gets the phone the user has entered.
		ori $v0, $0, 4 
		la $a0,phoneMessage			    		#Prints message for user to enter their phone.
		syscall		
	
		ori $v0, $0, 8 
		la $a0,usersPhone				
		ori $a1, $0, 20
		sw $v0,usersPhone						#Stores user's Phone in string "usersPhone".
		syscall		
	jr $ra
	
	Terminate_Program:							#Terminates the program and it's called after the user presses q or Q.			
		ori $v0, $0, 4 							#Prints message "Final_Message".
		la $a0,Final_Message 			
		syscall
	
		ori $v0, $0, 10							#Terminates the program.
		syscall
	jr $ra