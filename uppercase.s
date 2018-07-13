# PURPOSE: This program takes an input file and converts it to uppercase
#
# INPUT:
#    runtime argument 1: input file
#    runtime argument 2: output file
#
# PROCESSING:
#    1) Open the input file
#    2) Open the output file
#    3) Read a buffer from the input file
#    4) Convert all letters in the input buffer to uppercase
#    5) Save the buffer to the output file


#system call definitions
.equ SYS_OPEN,      5
.equ SYS_CLOSE,     6
.equ SYS_EXIT,      1
.equ SYS_WRITE,     4
.equ SYS_READ,      3

#open options
.equ OPT_READONLY,              0
.equ OPT_CREATE_WRONLY_TRUNC,   03101

#standard file descriptors
.equ STDIN,         0
.equ STDOUT,        1
.equ STDERR,        2

.equ LINUX_SYSCALL, 0x80

.section .bss
.equ BUFFER_SIZE,   500
.lcomm BUFFER_DATA, BUFFER_SIZE

.section .text

.globl _start
_start:
#Initialize program: save stackptr
 movl %esp, %ebp
 subl $8, %esp       # Save 2 long to save the two file descriptors

open_fd_in:
 movl $SYS_OPEN, %eax
 movl 8(%ebp), %ebx  #First argument was the name of the program
 movl $OPT_READONLY, %ecx
 movl $0666, %edx
 int $LINUX_SYSCALL
 movl %eax, -4(%ebp) #Store in file descriptor

open_fd_out:
 movl $SYS_OPEN, %eax
 movl 12(%ebp), %ebx  #First argument was the name of the program
 movl $OPT_CREATE_WRONLY_TRUNC, %ecx
 movl $0666, %edx  #Permissions for the new file
 int $LINUX_SYSCALL
 movl %eax, -8(%ebp) #Store in file descriptor

read_loop_begin:
#Read buffer from stdin
 movl $SYS_READ, %eax
 movl -4(%ebp), %ebx     #input file descriptor
 movl $BUFFER_DATA, %ecx
 movl $BUFFER_SIZE, %edx
 int $LINUX_SYSCALL
#Have we reached the end of the file?
 cmpl $0, %eax
 je end

#Convert buffer to uppercase (call to function)
 pushl $BUFFER_DATA  #Location of the buffer
 pushl %eax          #Buffer size
 call uppercase_conversion
 popl %eax
 addl $4, %esp       #Free the stack associated to the location of the argument
#Write buffer to output buffer
 movl %eax, %edx     #Buffer size
 movl $SYS_WRITE, %eax
 movl -8(%ebp), %ebx #Output file
 movl $BUFFER_DATA, %ecx
 int $LINUX_SYSCALL
#Bonus! Write the same buffer to stdout
 movl $SYS_WRITE, %eax
 movl $STDOUT, %ebx
 int $LINUX_SYSCALL
 jmp read_loop_begin
end:
#Close files
 movl $SYS_CLOSE, %eax
 movl -4(%ebp), %ebx
 int $LINUX_SYSCALL
 movl $SYS_CLOSE, %eax
 movl -8(%ebp), %ebx
 int $LINUX_SYSCALL
#Call linux to exit
 movl $SYS_EXIT, %eax
 movl $0, %ebx   #Return code
 int $LINUX_SYSCALL


# PURPOSE: Convert a text buffer to uppercase
#
# ARGUMENTS: 
#   Argument 1: The size of the buffer
#   Argument 2: The localtion of the buffer
#
#

# VARIABLES:
#    %eax is used to store the buffer size
#    %eax is used to store the buffer location
#    %ecx is used to store the buffer offset
#    %dl is used to store the current byte
.equ TO_UPPERCASE, 'A'-'a'
uppercase_conversion:
 push %ebp
 movl %esp, %ebp
 movl 8(%ebp), %eax         #Store buffer size into eax
 movl 12(%ebp), %ebx        #Store buffer location into ebx
 movl $0, %ecx              #Offset index starts at zero
uppercase_loop:
 cmp %ecx, %eax             #Has the offset reached the total length? Then exit
 je uppercase_end
 movb (%ebx, %ecx, 1), %dl  #Read bye from buffer
 cmpb $'a', %dl              #Check  it is, in fact, a lowercase letter
 jl uppercase_loop_end
 cmpb $'z', %dl
 jg uppercase_loop_end
 addb $TO_UPPERCASE, %dl    #If its a letter, turn it into an uppercase
 movb %dl, (%ebx, %ecx, 1)
uppercase_loop_end:
 addl $1, %ecx              #Increase index and go to the next loop
 jmp uppercase_loop
uppercase_end:
 movl %ebp, %esp
 popl %ebp
 ret
