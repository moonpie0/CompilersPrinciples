   .arch armv7-a
    @ comm section  保存全局变量
    .comm n,4
    .comm array,400
   .text
   .align 2

    @ rodata section 保存常量
    .section  .rodata
    .align 2

 _str0:
    .ascii   "%d\0"  @输入一个参数
    .align 2

_str1:
    .ascii   "%d\n"
    .align 2

    @ text section code 代码段
    .text
    .align 2


    .global Fib
Fib:
    str fp, [sp, #-4] !	@将寄存器fp压入栈中，同时更新sp指针
    mov fp, sp	@表示将sp指针设置为当前栈指针
    sub sp, sp, #408	@为局部变量分配8字节的栈空间，只有一个变量+sp，所以栈空间为8字节
    str r0, [fp, #-8]	@表示将参数n压入栈中，偏移量为-8
    ldr r3, _bridge+12
    str r3, [fp, #-408]
    
    @ 初始化数组 arr，arr[0] = 0, arr[1] = 1

    mov r4, #0                  @ 将0存储到寄存器r4
    mov r5, #1                  @ 将1存储到寄存器r5
    str r4, [r3]                @ 存储0到arr[0]
    str r5, [r3, #4]            @ 存储1到arr[1]

    @ 初始化循环计数器 i = 2
    mov r6, #2

loop:

    @ 计算 arr[i] = arr[i - 1] + arr[i - 2]
    sub r1, r6, #1
    mov r4, #4
    mul r2, r1, r4

    ldr r4, [r3, r2]            @ 加载arr[i - 1]到r4   4*(i-1)
    mov r1, #4
    sub r2, r2, r1
    ldr r5, [r3, r2]                @ 加载arr[i - 2]到r5   4*(i-1)-4
    add r4, r4, r5              @ 计算arr[i - 1] + arr[i - 2]
    mov r1, #8
    add r2, r2, #8
    str r4, [r3, r2]            @ 存储结果到arr[i]     4*(i-1)+4

    @ 增加计数器 i
    add r6, r6, #1              @ 计数器i加1
    
    @ 如果 i <= n，继续循环
    cmp r6, r0                  @ 比较i和n
    ble loop                    @ 如果i <= n，跳转回循环

    @ 返回 arr[n]
    
    ldr r0, [r3, r2]            @ 加载arr[n]到r0，作为函数返回值

    @ 退出Fib函数，恢复寄存器并返回
    add sp, fp, #0		@将栈指针恢复到原始值
    ldr fp, [sp], #4		@从栈中弹出fp寄存器，并更新sp指针
    bx lr		@恢复pc指针，并返回

    .global main
main:
    push   {fp,lr}   @表示将寄存器fp和lr压入栈中，并更新sp指针

    @ 输入整数
    ldr r1,_bridge                    @r1=&n
    ldr r0, _bridge+4              @*r0 = "%d\0"
    bl __isoc99_scanf	@ 调用scanf函数，从标准输入读取一个整数，并将结果存储在n中	
    ldr r2, _bridge                   @r2 = &n
    ldr r0, [r2]                          @ r0 = a
    

    @ 调用Fib函数计算斐波那契数列的第n项
    bl Fib                   @ 调用Fib函数
    
    @ 打印结果
    mov r1, r0          @ r1 = r0
    ldr r0, _bridge+8 @ *r0 = "%d\0"
    bl printf     @ printf("%d\n");

end:
    @ 退出程序
    mov r0, #0
    pop {fp, pc}        @return 0

_bridge:
    .word    n
    .word    _str0
    .word    _str1
    .word    array


    .section	.note.GNU-stack,"",%progbits