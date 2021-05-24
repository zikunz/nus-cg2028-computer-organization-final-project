 	.syntax unified
 	.cpu cortex-m3
 	.thumb
 	.align 2
 	.global	fir
 	.thumb_func

@  CG2028 Assignment, Sem 1, AY 2020/21
@  (c) CG2028 Teaching Team, ECE NUS, 2020
@  LEE HAO YUAN (A0201511E)
@  ZHU ZIKUN (A0205947X)

@  Please note that "x_n" is equivalent to "x[n]" and refers to the n-th element in the array of x. Some brief comments and machine code (if applicable)
@  are written next to and directly below each asm code, respectively. For detailed explanations, please refer to our report.

@  Register map:
@  R0 - Stores N, returns y_n.
@  R1 - Stores the pointer to an array containing N + 1 filter coefficients (b_0 to b_N) passed in by the C program.
@  R2 - Stores the current x_n.
@  R3 - Stores the calculated value of y_n.
@  R4 - Stores either current or next value of filter coefficients in the array of b, i.e. b[j] or b[j + 1].
@  R5 - Stores the memory address of STORE, a label declared to reserve space in the memory to store x_store values.
@  R6 - Stores the required value of x_store (used as temp) loaded from the memory.
@  R7 - Stores the constant decimal of 10000.
@  R8 - Stores N and is used as a counter for both the first and second loop.



fir:
		@ PUSH registers which are modified by fir (parameter registers excluded)
		PUSH {R3-R8}

		@ Body of asm function starts here
		MOV R8, R0         @ Moves N from R0 to R8.
				           @ 0000 00 011010 0000 1000 0000000 0 0000 (0x01A08000)

		LDR R4, [R1], #4   @ Loads R4 with the content of memory address referenced by R1, adds 4 to the memory address referenced by R1.
						   @ 0000 01 001001 0001 0100 0000 00000100 (0x04914004)

		MUL R3, R2, R4     @ Multiplies the content of R2 and R4 and stores the result in R3.
					       @ 0000 00 000000 0000 0011 0100 000 1 0010 (0x00003412)

		LDR R5, =STORE     @ Loads the memory address associated with the label STORE into R5.


loop:
		LDR R4, [R1], #4   @ Loads R4 with the content of memory address referenced by R1, adds 4 to the address referenced by R1.
						   @ 0000 01 001001 0001 0100 0000 00000100 (0x04914004)

		LDR R6, [R5], #4   @ Loads R6 with the content of memory address referenced by R5, adds 4 to the address referenced by R5.
						   @ 0000 01 001001 0101 0110 0000 00000100 (0x04956004)

		MLA R3, R4, R6, R3 @ Multiplies the content previously loaded into R4 and R6, adds the result to R3 and stores the final result in R3.
						   @ 0000 00 000010 0011 0011 0110 000 10100  (0x00233614)

		SUBS R8, #1        @ Subtracts 1 from the value in R8 and update the condition flags.
		                   @ 0000 00 100101 1000 1000 0000 00000001 (0x02588001)

		BNE loop           @ Checks if Z = 0. If so, return to line 47, else, proceed to line 62.
				           @ 0001 10 000000 000000000000 00010100 (0x18000014)

		MOV R8, R0         @ Moves N from R0 to R8.
				           @ 0000 00 011010 0000 1000 0000000 0 0000 (0x01A08000)

		SUB R8, #1         @ Subtracts 1 from the value in R8.
						   @ 0000 00 100100 1000 1000 0000 00000001 (0x02488001)


		SUB R5, #4         @ Decrements the address referenced by R5 by 4.
						   @ 0000 00 100100 0101 0101 0000 00000100 (0x02455004)


store:
		LDR R7, [R5, #-4]  @ Loads R7 with content from the memory address referenced by R5 minus 4.
						   @ 0000 01 010001 0101 0111 0000 00000100 (0x05157004)

		STR R7, [R5]       @ Stores the value previously loaded into R7 (in Line 2) into the memory address referenced by R5.
						   @ 0000 01 010000 0101 0111 0000 00000000 (0x05057000)

		SUB R5, #4         @ Subtracts the memory address referenced by R5 by 4.
						   @ 0000 00 100100 0101 0101 0000 00000100 (0x02455004)

		SUBS R8, #1        @ Subtracts 1 from the value in R8 and update the condition flags.
						   @ 0000 00 100101 1000 1000 0000 00000001 (0x02588001)

		BNE store          @ Checks if Z = 0. If so, return to line 73, else, proceed to line 90.
		                   @ 0001 10 000000 000000000000 00010100 (0x18000014)


		STR R2, [R5]       @ Stores the value in R2 to the memory address of R5.
						   @ 0000 01 010000 0101 0010 0000 00000000 (0x05052000)

		@ Prepare y_n to be returned
		MOVW R7, #0x2710   @ Moves the decimal number 10000 to R7.

		UDIV R0, R3, R7    @ Performs an unsigned division of value in R3 by value in R7 and stores the result in R0.

		@ POP original register values (exclduing R0).
		POP {R3-R8}

		@ Return to C program
		BX LR

@label: .word value
.equ N_MAX, 10
.lcomm STORE 4 * N_MAX
