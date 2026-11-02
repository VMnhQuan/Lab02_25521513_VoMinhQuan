        .data
arr:    .word 4, 9, 1, 6
        .text
main:   la   $a0, arr
        li   $a1, 4
        jal  sum_array
        move $a0, $v0
        li   $v0, 1
        syscall
        li   $v0, 10
        syscall
# sum_array: tong cac phan tu cua mang word
# Tham so : $a0 = dia chi mang, $a1 = n (n >= 0)
# Tra ve  : $v0 = tong
sum_array:
        move $v0, $zero
sa_loop:
        beq  $a1, $zero, sa_done
        lw   $t0, 0($a0)
        add  $v0, $v0, $t0
        addi $a0, $a0, 4
        addi $a1, $a1, -1
        j    sa_loop
sa_done:
        jr   $ra
