# CE119 Lab02 - Mang, chuoi, thu tuc va ngan xep
# Ho ten: Vo Minh Quan - MSSV: 25521513 (d = 3, k = 6)
#
# Chuong trinh chinh:
#   1) Thong ke 3 bo du lieu T1, T2, T3 bang stats va histogram,
#      ve pho diem cua T1 bang draw_hist (phan mo rong).
#   2) Kiem tra ngoac cho 8 chuoi cua Bang 16 va chuoi ca nhan P.
# Thanh ghi cua chuong trinh chinh (cac thu tuc khong dung $s):
#   $s0 : chi so bo du lieu / chuoi dang xet
#   $s1 : con tro vao bang mo ta bo du lieu / bang chuoi
#   $s2, $s3 : ket qua tra ve can giu qua syscall
#   $s4 : con tro vao hist khi in, $s5 : chi so nhom khi in

        .data
diem:   .word 9, 6, 0, 1, 5, 8, 10, 5, 9, 1, 7, 6   # S[i] = (A0[i] + 3) mod 11
dl_t2:  .word 10
dl_t3:  .word 4, 4, 4, 4, 4
bo_dl:  .word diem, 12, dl_t2, 1, dl_t3, 5         # (dia chi, n) cua T1, T2, T3
grade_tab: .byte 0, 0, 0, 0, 1, 1, 1, 2, 2, 3, 3   # nhom cua diem 0..10
        .align 2
hist:   .word 0, 0, 0, 0

ch_1:   .asciiz "(a+b)*[c-{d/e}]"
ch_2:   .asciiz "f(x[i]{j}))"
ch_3:   .asciiz "{[(])}"
ch_4:   .asciiz "((a)"
ch_5:   .asciiz ""
ch_6:   .asciiz "no brackets here"
ch_7:   .asciiz "]"
ch_8:   .asciiz "([)]"
ch_P:   .asciiz "([{([{}])}])"                      # k = 6 cap long nhau
        .align 2
bo_ngoac: .word ch_1, ch_2, ch_3, ch_4, ch_5, ch_6, ch_7, ch_8, ch_P

m_min:  .asciiz "min="
m_max:  .asciiz " max="
m_hai:  .asciiz ":\n"
m_chk1: .asciiz "check(\""
m_chk2: .asciiz "\") = ("
m_phay: .asciiz ", "
m_dong: .asciiz ")\n"

        .text
        .globl main
main:
# ---------- 1) Thong ke diem ----------
        li   $s0, 0
        la   $s1, bo_dl
m_tk_lap:
        la   $t0, hist          # xoa hist truoc moi bo du lieu
        sw   $zero, 0($t0)
        sw   $zero, 4($t0)
        sw   $zero, 8($t0)
        sw   $zero, 12($t0)

        li   $v0, 11            # in "T<so>:"
        li   $a0, 'T'
        syscall
        li   $v0, 1
        addi $a0, $s0, 1
        syscall
        li   $v0, 4
        la   $a0, m_hai
        syscall

        lw   $a0, 0($s1)        # dia chi mang
        lw   $a1, 4($s1)        # n
        jal  stats
        move $s2, $v0           # min
        move $s3, $v1           # max

        li   $v0, 4
        la   $a0, m_min
        syscall
        li   $v0, 1
        move $a0, $s2
        syscall
        li   $v0, 4
        la   $a0, m_max
        syscall
        li   $v0, 1
        move $a0, $s3
        syscall
        li   $v0, 11
        li   $a0, '\n'
        syscall

        lw   $a0, 0($s1)
        lw   $a1, 4($s1)
        la   $a2, grade_tab
        la   $a3, hist
        jal  histogram

        la   $s4, hist          # in "g0=.. g1=.. g2=.. g3=.."
        li   $s5, 0
m_in_g:
        li   $v0, 11
        li   $a0, 'g'
        syscall
        li   $v0, 1
        move $a0, $s5
        syscall
        li   $v0, 11
        li   $a0, '='
        syscall
        li   $v0, 1
        lw   $a0, 0($s4)
        syscall
        addi $s5, $s5, 1
        addi $s4, $s4, 4
        li   $v0, 11
        li   $a0, ' '
        slti $t0, $s5, 4
        bne  $t0, $zero, m_in_sep
        li   $a0, '\n'          # sau nhom cuoi thi xuong dong
m_in_sep:
        syscall
        bne  $t0, $zero, m_in_g

        bne  $s0, $zero, m_tk_tiep  # chi ve pho diem cho T1
        la   $a0, hist
        li   $a1, 4
        jal  draw_hist
m_tk_tiep:
        addi $s0, $s0, 1
        addi $s1, $s1, 8
        slti $t0, $s0, 3
        bne  $t0, $zero, m_tk_lap

# ---------- 2) Kiem tra ngoac ----------
        li   $s0, 0
        la   $s1, bo_ngoac
m_ng_lap:
        lw   $s2, 0($s1)        # dia chi chuoi
        li   $v0, 4
        la   $a0, m_chk1
        syscall
        li   $v0, 4
        move $a0, $s2
        syscall
        li   $v0, 4
        la   $a0, m_chk2
        syscall

        move $a0, $s2
        jal  check_brackets
        move $s2, $v0           # vi tri
        move $s3, $v1           # ma loi

        li   $v0, 1
        move $a0, $s2
        syscall
        li   $v0, 4
        la   $a0, m_phay
        syscall
        li   $v0, 1
        move $a0, $s3
        syscall
        li   $v0, 4
        la   $a0, m_dong
        syscall

        addi $s0, $s0, 1
        addi $s1, $s1, 4
        slti $t0, $s0, 9
        bne  $t0, $zero, m_ng_lap

        li   $v0, 10
        syscall

# ------------------------------------------------------------
# stats: tim gia tri nho nhat va lon nhat cua mang word
# Tham so : $a0 = dia chi mang, $a1 = n (n >= 1)
# Tra ve  : $v0 = min, $v1 = max
# Thanh ghi su dung: $a0, $a1 (bi thay doi), $t0, $t1
# Thu tuc la, mot luot duyet, khong ghi bo nho.
# ------------------------------------------------------------
stats:
        lw   $v0, 0($a0)        # min = max = phan tu dau
        move $v1, $v0
st_lap: addi $a1, $a1, -1
        beq  $a1, $zero, st_xong
        addi $a0, $a0, 4
        lw   $t0, 0($a0)
        slt  $t1, $t0, $v0      # phan tu < min ?
        beq  $t1, $zero, st_max
        move $v0, $t0
st_max: slt  $t1, $v1, $t0      # max < phan tu ?
        beq  $t1, $zero, st_lap
        move $v1, $t0
        j    st_lap
st_xong:
        jr   $ra

# ------------------------------------------------------------
# histogram: dem so diem trong tung nhom xep loai
# Tham so : $a0 = dia chi mang diem, $a1 = n,
#           $a2 = dia chi grade_tab (byte), $a3 = dia chi hist (word)
# Tra ve  : khong; hist[grade_tab[s]] += 1 voi moi diem s
# Thanh ghi su dung: $a0, $a1 (bi thay doi), $t0, $t1, $t2
# Thu tuc la; tra bang bang lbu, khong so sanh voi nguong.
# ------------------------------------------------------------
histogram:
hg_lap: beq  $a1, $zero, hg_xong
        lw   $t0, 0($a0)        # diem s
        add  $t1, $a2, $t0      # &grade_tab[s] (byte: khong nhan 4)
        lbu  $t1, 0($t1)        # nhom g
        sll  $t1, $t1, 2        # offset word = g * 4
        add  $t1, $a3, $t1      # &hist[g]
        lw   $t2, 0($t1)
        addi $t2, $t2, 1
        sw   $t2, 0($t1)
        addi $a0, $a0, 4
        addi $a1, $a1, -1
        j    hg_lap
hg_xong:
        jr   $ra

# ------------------------------------------------------------
# check_brackets: kiem tra cac cap ngoac ( ) [ ] { } trong chuoi
# Tham so : $a0 = dia chi chuoi .asciiz
# Tra ve  : $v0 = vi tri (dem tu 1), $v1 = ma loi (Bang 15)
# Thanh ghi su dung: $a0 (bi thay doi), $t0-$t4, $t9; dung $sp lam ngan xep
# Thu tuc la. $t9 giu $sp luc vao: ngan xep rong khi $sp == $t9,
# moi duong thoat deu khoi phuc $sp = $t9.
# ------------------------------------------------------------
check_brackets:
        move $t9, $sp           # $sp luc vao thu tuc
        li   $t0, 0             # vi tri ky tu
cb_lap: lbu  $t1, 0($a0)
        beq  $t1, $zero, cb_het
        addi $t0, $t0, 1
        addi $a0, $a0, 1
        li   $t2, '('
        beq  $t1, $t2, cb_push
        li   $t2, '['
        beq  $t1, $t2, cb_push
        li   $t2, '{'
        beq  $t1, $t2, cb_push
        li   $t3, '('           # $t3 = ngoac mo tuong ung
        li   $t2, ')'
        beq  $t1, $t2, cb_dong
        li   $t3, '['
        li   $t2, ']'
        beq  $t1, $t2, cb_dong
        li   $t3, '{'
        li   $t2, '}'
        beq  $t1, $t2, cb_dong
        j    cb_lap             # ky tu khac: bo qua
cb_push:
        addi $sp, $sp, -4       # push ngoac mo
        sw   $t1, 0($sp)
        j    cb_lap
cb_dong:
        beq  $sp, $t9, cb_loi2  # ngan xep rong
        lw   $t4, 0($sp)        # pop
        addi $sp, $sp, 4
        bne  $t4, $t3, cb_loi1  # khac loai
        j    cb_lap
cb_loi1:
        li   $v1, 1
        j    cb_ve
cb_loi2:
        li   $v1, 2
        j    cb_ve
cb_het: beq  $sp, $t9, cb_dung
        addi $t0, $t0, 1        # do dai chuoi + 1
        li   $v1, 3
        j    cb_ve
cb_dung:
        li   $t0, 0
        li   $v1, 0
cb_ve:  move $v0, $t0
        move $sp, $t9           # khoi phuc $sp tren moi duong thoat
        jr   $ra

# ------------------------------------------------------------
# draw_hist: ve pho diem dang cot ngang bang ky tu '|'
# Tham so : $a0 = dia chi mang hist, $a1 = so nhom
# Tra ve  : khong
# Thanh ghi su dung: $a0, $v0 (syscall), $t0-$t3
# Thu tuc la.
# ------------------------------------------------------------
draw_hist:
        move $t0, $a0           # con tro vao hist
        li   $t1, 0             # chi so nhom
        move $t2, $a1
dh_lap: beq  $t1, $t2, dh_xong
        li   $v0, 11
        li   $a0, 'g'
        syscall
        li   $v0, 1
        move $a0, $t1
        syscall
        li   $v0, 11
        li   $a0, ':'
        syscall
        li   $a0, ' '
        syscall
        lw   $t3, 0($t0)        # so sinh vien cua nhom
dh_cot: beq  $t3, $zero, dh_dong
        li   $a0, '|'
        syscall
        addi $t3, $t3, -1
        j    dh_cot
dh_dong:
        li   $a0, '\n'
        syscall
        addi $t0, $t0, 4
        addi $t1, $t1, 1
        j    dh_lap
dh_xong:
        jr   $ra
