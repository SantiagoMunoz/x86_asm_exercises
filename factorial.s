# PURPOSE: To calculate the factorial of a number
#

.section .data
	# No global data used
.section .text

.globl _start
.globl factorial
_start:
	movl %esp, %ebp
	pushl $5
	call factorial
	addl $4, %esp
	movl %eax, %ebx
	movl $1, %eax
	int $0x80

# PURPOSE: Recursively calculate the factorial of a number
#

# PARAMETERS: 
#	Input number

# VARIABLES:
#	eax - used to hold the input number
#       ebx - used to perform a multiplication
#

.type factorial, @function
factorial:
	pushl %ebp
	movl %esp, %ebp
	
	movl 8(%ebp), %eax
	cmpl $1, %eax
	je factorial_end	
	
	decl %eax
	pushl %eax
	call factorial
	addl $4, %esp

	movl 8(%ebp), %ebx
	imull %ebx, %eax

factorial_end:
	movl %ebp, %esp
	popl %ebp
ret


