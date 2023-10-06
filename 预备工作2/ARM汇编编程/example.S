	.arch armv7-a
	@ comm section 保存全局变量，未初始化
	.comm	n, 4
	.comm	i, 4
	.comm	f, 4
	.text
	.align	2
	@ rodata section 保存常量
	.section	.rodata
	.align	2
_str0:
	.ascii	"%d\0"
	.align	2
_str1:
	.ascii 	"%d\n"
	@ text section 代码段
	.text
	.align	2
	
	.global	jiecheng
jiecheng:	 @ int jiecheng(int n)
	str	fp, [sp, #-4] !	@将寄存器fp压入栈中，同时更新sp指针
	mov	fp, sp		@表示将sp指针设置为当前栈指针
	sub	sp, sp, #8		@为局部变量分配8字节的栈空间，只有一个变量+sp，所以栈空间为8字节
	str	r0, [fp, #-8]	@表示将参数n压入栈中，偏移量为-8
	ldr	r1, _bridge	@f的地址
	ldr	r2, [r1]		@r2=f
	ldr	r1, _bridge+4	@i的地址
	ldr	r3, [r1]		@r3=i
.L2:
	cmp	r3, r0		@比较i和n的大小
	bgt	.L3		@大于则跳转
	mul	r4, r2, r3		
	mov	r2, r4		@f=f*i
	add	r3, r3, #1		@i=i+1,没有addi这个指令
	b	.L2
.L3:
	mov	r0, r2
	add	sp, fp, #0		@将栈指针恢复到原始值
	ldr	fp, [sp], #4		@从栈中弹出fp寄存器，并更新sp指针
	bx	lr		@恢复pc指针，并返回

	.global	main
main:
	push	{fp, lr}		@表示将寄存器fp和lr压入栈中，并更新sp指针
	mov	r0, #1		@将立即数1的值赋给寄存器r0
	ldr	r1, _bridge	@将常量f的地址赋值给r1
	str	r0, [r1]		@将r0的值存到r1所指的地址中，即f=1
	mov	r0, #2		@将立即数2的值赋给寄存器r0
	ldr	r1, _bridge+4	@将常量f的地址赋值给r1
	str	r0, [r1]		@将r0的值存到r1所指的地址中，即i=2
	add	fp, sp, #4		@表示为局部变量分配4字节的占空间
	ldr	r1, _bridge+8	@将常量n的地址赋给寄存器r1
	ldr	r0, _bridge+12	@将字符串_str0的地址赋值给寄存器r0
	bl	__isoc99_scanf	@表示调用scanf函数读取整数参数n	
	ldr	r1, _bridge+8	
	ldr	r0, [r1] 	@r0=n
	bl	jiecheng		
	mov	r1, r0
	ldr	r0, _bridge+16	@_str1
	bl	printf
	mov	r0, #0
	pop	{fp, pc}		@return 0

_bridge:
	.word	f
	.word	i
	.word 	n
	.word	_str0
	.word	_str1

	.section	.note.GNU-stack,"",%progbits