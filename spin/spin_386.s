#include "textflag.h"

// void lock(int32 *ptr, int32 old, int32 new)
TEXT ·lock(SB), NOSPLIT, $0-12
	MOVL	ptr+0(FP), BX
	MOVL	old+4(FP), DX
	MOVL	new+8(FP), CX
again:
	MOVL	DX, AX
	LOCK
	/* 该asm函数的功能是使用CMPXCHG指令比较并交换寄存器CX和内存地址0(BX)中的值。
	如果CX与0(BX)中的值相等，则将CX的值存储到0(BX)中，
	否则将0(BX)中的值存储到CX中。该指令常用于原子操作和线程同步中。 */
	CMPXCHGL	CX, 0(BX)
	/* JE (Jump if Equal): 这是一个条件跳转指令，
	只有当标志寄存器中的零标志（ZF）为1，即前一个比较操作结果为零（表示相等）时，
	才会执行跳转。它用于实现条件控制流。
	JMP (Jump): 这是一个无条件跳转指令，无论什么情况都会转移到指定的标签位置执行。
	它用于改变程序的执行顺序，常用于循环、分支或直接跳转到程序的任意位置。 */
	JE		ok
	PAUSE
	JMP		again
ok:
	RET

// void unlock(int32 *ptr, int32 val)
TEXT ·unlock(SB), NOSPLIT, $0-8
	MOVL	ptr+0(FP), BX
	MOVL	val+4(FP), AX
	/* 在汇编语言中，0(BX)这种表达方式是寻址模式的一种表示，称为基址寻址。
	这里的意思是访问以BX寄存器内容作为地址的内存位置。直接写BX指的是使用寄
	存器的内容本身，而不是寄存器指向的内存位置的内容。由于XCHGL指令需要一
	个内存地址来完成值的交换，所以使用0(BX)是为了定位到内存中由BX寄存器值指示
	的位置进行操作，而非操作寄存器BX自身。 
	
	XCHGL指令在汇编语言中用于交换两个操作数的值，
	这里的操作数可以是一个寄存器和另一个寄存器，
	或者是一个寄存器和内存中的一个值。*/
	XCHGL	AX, 0(BX)
	RET
