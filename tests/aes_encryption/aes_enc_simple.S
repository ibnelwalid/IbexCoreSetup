# Simple assembly program that will print "Hello, World!" to the console
# through Spike.

.text
.global _start; _start:
  li sp, 0x80001000
  addi t0, zero, 0x210
  addi t3, zero, 12
  clmul t2, t3, t0
  clmul t4, t3, t0
  aes32esi t2, zero, t0, 0
  aes32esi t2, zero, t0, 1
  aes32esi t2, zero, t0, 2
  aes32esi t2, zero, t0, 3
  aes32esmi t2, zero, t0, 0
  aes32esmi t2, zero, t0, 1
  aes32esmi t2, zero, t0, 2
  aes32esmi t2, zero, t0, 3
  addi t3, t0, 5
  la t1, tohost
  li t2, 1
  sw t2, 0(t1)
  ecall

.data
.align 4; .global tohost;   tohost:   .dword 0
.align 4; .global fromhost; fromhost: .dword 0
syscall_buffer:
.skip 64
hello_world:
.string "Hello, World!\n"