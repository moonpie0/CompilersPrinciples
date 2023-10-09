   .arch armv7-a
    @ comm section  保存全局变量
    .comm a,4
   .text
   .align 2

    @ rodata section 保存常量
    .section  .rodata
    .align 2

 _str0:
    .ascii   "%d\0"  @输入一个参数
    .align 2

msg_no:
    .asciz  "No\n"               
    .align 2

msg_yes:
    .asciz  "Yes\n"                 
    .align 2

    @ text section code 代码段
    .text
    .align 2

    .global main
    
main:
    push   {fp,lr}   @表示将寄存器fp和lr压入栈中，并更新sp指针
    
    ldr r1, _bridge+12    @r1=&a
    ldr r0, _bridge    @将字符串_str0的地址赋值给寄存器r0,*r0 = "%d\0"
    bl __isoc99_scanf	@表示调用scanf函数读取整数参数a到r0
    ldr r2, _bridge+12     @r2 = &a
    ldr r0, [r2]                          @ r0 = a

    cmp r0, #1        @ 比较a和1
    ble is_no         @ 如果a <= 1，跳转到is_no

    cmp r0, #2        @ 比较a和2
    beq is_yes        @ 如果a = 1，跳转到is_yes
    
    @ for (i = 2; i < a; i++)

    mov r1, #2        @ 初始化i为2

loop_start:

    cmp r1, r0        @ 比较i和a
    bge loop_end       @ 如果i >= a，退出循环

    @ if (a % i == 0) break;


    mov   r3, r0        @ 将被除数复制到 r3 中
    mov   r4, r1        @ 将除数复制到 r4 中
    mov   r5, #0        @ 初始化结果寄存器 r5 为 0

loop:
    cmp   r3, r4        @ 比较 r3 和 r4
    blt   done           @ 如果 r3 < r4，跳出循环

    sub   r3, r3, r4    @ 减去除数
    add   r5, r5, #1    @ 增加结果
    b     loop           @ 继续循环


    @mov r2, r0        @ 将a复制到r2

    @sdiv r3, r2, r1   @ 将a除以i，商存在r3中，余数存在r2中

done:
    cmp r3, #0        @ 检查余数是否为零
    beq is_no         @ 如果余数为零，跳转到is_no

    @ i++;

    add r1, r1, #1    @ 增加i

    @ if (i < a) printf("No");

    cmp r1, r0        @ 比较i和a
    blt loop_start     @ 如果i < a，跳转到loop_start
    b is_yes          @ 如果i >= a，跳转到is_yes

is_no:

    @ printf("No");

    mov r0, #1        @ 文件描述符1（标准输出）
    ldr r0,  _bridge+4   @ 载入"No"消息的地址
    bl printf         @ 调用printf

    @ 退出程序

    mov r0, #0
    pop {fp, pc}        @return 0
    
is_yes:

    @ printf("Yes");

    mov r0, #1        @ 文件描述符1（标准输出）
    ldr r0, _bridge+8  @ 载入"Yes"消息的地址
    bl printf         @ 调用printf

    @ 退出程序

    mov r0, #0
    pop {fp, pc}        @return 0

loop_end:

    @ 退出程序
    
    mov r0, #0
    pop {fp, pc}        @return 0

_bridge:
    .word    _str0
    .word    msg_no
    .word    msg_yes
    .word    a

    .section	.note.GNU-stack,"",%progbits