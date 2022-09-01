# Simple assembly program that will print "Hello, World!" to the console
# through Spike.

.text
.global _start; _start:
  li sp, 0x80001000
  addi t0, zero, 1
  addi t3, t0, 5
  aes32esi t2, zero, zero, 0
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