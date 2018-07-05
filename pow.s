#PURPOSE: Given four numbers a, b, c and d, calculate a^b+c^d
#

.section .data

.section .text

.globl main
main:
 movl %esp, %ebp
 pushl $0           #argument b into stack
 pushl $2           #argument a into stack
 call power
 addl $8, %esp       #free the space taken by a and b
 pushl %eax         #store a^b into stack
 push $2            #argument d into stack
 push $5            #argument c into stack
 call power
 addl $8, %esp       #free the space taken by c and d
 popl %ebx          #recover the result from the first call to pow into %3bv
 addl %eax, %ebx    #add the results from both operations together
 movl $1, %eax      #call kernel to exit program
 int $0x80

#PURPOSE: Given two numbers a and b, calculate a^b
#
#INPUT: - First argument: number a (base)
#       - Second argument: number b (power)
#
#OUTPUT: Gives the result as return value
#
#VARIABLES:
#       %ebx - Holds the base number
#       %ecx - Holds the power
#       -4(%ebp) - Holds the current result
#
#       %eax is used for temporary storage


.type power, @function

power:
 pushl %ebp             #push the old stack base pointer
 movl %esp, %ebp        #the current stack position is now the stack base pointer
 subl $4, %esp          #reserve one word for the local variable

 movl 8(%ebp), %ebx     #save base number into ebx
 movl 12(%ebp), %ecx    #save power number into ecx

 cmpl $0, %ecx          # If the power is not zero, skip to normal operation
 jne normal_operation   #
 movl $1, -4(%ebp)      # If the power is zero, set the result to 1 and skip normal operation
 jmp end_power          #

normal_operation:
 movl %ebx, -4(%ebp)    #Initialize the local variable with the base number
power_loop:
 cmpl $1, %ecx          #if power is one, exit the loop
 je end_power           #
 movl -4(%ebp), %eax    #load current result into eax
 imull %ebx, %eax       #multiply current result by the base number
 movl %eax, -4(%ebp)    #store current result in stack
 decl %ecx              #decrease pow
 jmp power_loop         #go to the next iteration

end_power:  
 movl -4(%ebp), %eax    #copy the current result as return value
 movl %ebp, %esp        #free all the stack reserved since the function started
 popl %ebp              #restore the previous stack pointer
 ret
