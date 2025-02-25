; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -mattr=+experimental-v -riscv-v-vector-bits-min=128 -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -mtriple=riscv64 -mattr=+experimental-v -riscv-v-vector-bits-min=128 -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -mtriple=riscv32 -mattr=+experimental-v -riscv-v-vector-bits-min=128 -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -mtriple=riscv64 -mattr=+experimental-v -riscv-v-vector-bits-min=128 -verify-machineinstrs < %s | FileCheck %s

define void @and_v8i1(<8 x i1>* %x, <8 x i1>* %y) {
; CHECK-LABEL: and_v8i1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetivli a2, 8, e8,mf2,ta,mu
; CHECK-NEXT:    vle1.v v25, (a0)
; CHECK-NEXT:    vle1.v v26, (a1)
; CHECK-NEXT:    vmand.mm v25, v25, v26
; CHECK-NEXT:    vse1.v v25, (a0)
; CHECK-NEXT:    ret
  %a = load <8 x i1>, <8 x i1>* %x
  %b = load <8 x i1>, <8 x i1>* %y
  %c = and <8 x i1> %a, %b
  store <8 x i1> %c, <8 x i1>* %x
  ret void
}

define void @or_v16i1(<16 x i1>* %x, <16 x i1>* %y) {
; CHECK-LABEL: or_v16i1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetivli a2, 16, e8,m1,ta,mu
; CHECK-NEXT:    vle1.v v25, (a0)
; CHECK-NEXT:    vle1.v v26, (a1)
; CHECK-NEXT:    vmor.mm v25, v25, v26
; CHECK-NEXT:    vse1.v v25, (a0)
; CHECK-NEXT:    ret
  %a = load <16 x i1>, <16 x i1>* %x
  %b = load <16 x i1>, <16 x i1>* %y
  %c = or <16 x i1> %a, %b
  store <16 x i1> %c, <16 x i1>* %x
  ret void
}

define void @xor_v32i1(<32 x i1>* %x, <32 x i1>* %y) {
; CHECK-LABEL: xor_v32i1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addi a2, zero, 32
; CHECK-NEXT:    vsetvli a2, a2, e8,m2,ta,mu
; CHECK-NEXT:    vle1.v v25, (a0)
; CHECK-NEXT:    vle1.v v26, (a1)
; CHECK-NEXT:    vmxor.mm v25, v25, v26
; CHECK-NEXT:    vse1.v v25, (a0)
; CHECK-NEXT:    ret
  %a = load <32 x i1>, <32 x i1>* %x
  %b = load <32 x i1>, <32 x i1>* %y
  %c = xor <32 x i1> %a, %b
  store <32 x i1> %c, <32 x i1>* %x
  ret void
}

define void @not_v64i1(<64 x i1>* %x, <64 x i1>* %y) {
; CHECK-LABEL: not_v64i1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addi a1, zero, 64
; CHECK-NEXT:    vsetvli a1, a1, e8,m4,ta,mu
; CHECK-NEXT:    vle1.v v25, (a0)
; CHECK-NEXT:    vmnand.mm v25, v25, v25
; CHECK-NEXT:    vse1.v v25, (a0)
; CHECK-NEXT:    ret
  %a = load <64 x i1>, <64 x i1>* %x
  %b = load <64 x i1>, <64 x i1>* %y
  %c = xor <64 x i1> %a, <i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1>
  store <64 x i1> %c, <64 x i1>* %x
  ret void
}

define void @andnot_v8i1(<8 x i1>* %x, <8 x i1>* %y) {
; CHECK-LABEL: andnot_v8i1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetivli a2, 8, e8,mf2,ta,mu
; CHECK-NEXT:    vle1.v v25, (a0)
; CHECK-NEXT:    vle1.v v26, (a1)
; CHECK-NEXT:    vmandnot.mm v25, v25, v26
; CHECK-NEXT:    vse1.v v25, (a0)
; CHECK-NEXT:    ret
  %a = load <8 x i1>, <8 x i1>* %x
  %b = load <8 x i1>, <8 x i1>* %y
  %c = xor <8 x i1> %a, <i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1>
  %d = and <8 x i1> %b, %c
  store <8 x i1> %d, <8 x i1>* %x
  ret void
}

define void @ornot_v16i1(<16 x i1>* %x, <16 x i1>* %y) {
; CHECK-LABEL: ornot_v16i1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetivli a2, 16, e8,m1,ta,mu
; CHECK-NEXT:    vle1.v v25, (a0)
; CHECK-NEXT:    vle1.v v26, (a1)
; CHECK-NEXT:    vmornot.mm v25, v25, v26
; CHECK-NEXT:    vse1.v v25, (a0)
; CHECK-NEXT:    ret
  %a = load <16 x i1>, <16 x i1>* %x
  %b = load <16 x i1>, <16 x i1>* %y
  %c = xor <16 x i1> %a, <i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1>
  %d = or <16 x i1> %b, %c
  store <16 x i1> %d, <16 x i1>* %x
  ret void
}

define void @xornot_v32i1(<32 x i1>* %x, <32 x i1>* %y) {
; CHECK-LABEL: xornot_v32i1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addi a2, zero, 32
; CHECK-NEXT:    vsetvli a2, a2, e8,m2,ta,mu
; CHECK-NEXT:    vle1.v v25, (a0)
; CHECK-NEXT:    vle1.v v26, (a1)
; CHECK-NEXT:    vmxnor.mm v25, v25, v26
; CHECK-NEXT:    vse1.v v25, (a0)
; CHECK-NEXT:    ret
  %a = load <32 x i1>, <32 x i1>* %x
  %b = load <32 x i1>, <32 x i1>* %y
  %c = xor <32 x i1> %a, <i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1>
  %d = xor <32 x i1> %b, %c
  store <32 x i1> %d, <32 x i1>* %x
  ret void
}

define void @nand_v8i1(<8 x i1>* %x, <8 x i1>* %y) {
; CHECK-LABEL: nand_v8i1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetivli a2, 8, e8,mf2,ta,mu
; CHECK-NEXT:    vle1.v v25, (a0)
; CHECK-NEXT:    vle1.v v26, (a1)
; CHECK-NEXT:    vmnand.mm v25, v25, v26
; CHECK-NEXT:    vse1.v v25, (a0)
; CHECK-NEXT:    ret
  %a = load <8 x i1>, <8 x i1>* %x
  %b = load <8 x i1>, <8 x i1>* %y
  %c = and <8 x i1> %a, %b
  %d = xor <8 x i1> %c, <i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1>
  store <8 x i1> %d, <8 x i1>* %x
  ret void
}

define void @nor_v16i1(<16 x i1>* %x, <16 x i1>* %y) {
; CHECK-LABEL: nor_v16i1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetivli a2, 16, e8,m1,ta,mu
; CHECK-NEXT:    vle1.v v25, (a0)
; CHECK-NEXT:    vle1.v v26, (a1)
; CHECK-NEXT:    vmnor.mm v25, v25, v26
; CHECK-NEXT:    vse1.v v25, (a0)
; CHECK-NEXT:    ret
  %a = load <16 x i1>, <16 x i1>* %x
  %b = load <16 x i1>, <16 x i1>* %y
  %c = or <16 x i1> %a, %b
  %d = xor <16 x i1> %c, <i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1>
  store <16 x i1> %d, <16 x i1>* %x
  ret void
}

define void @xnor_v32i1(<32 x i1>* %x, <32 x i1>* %y) {
; CHECK-LABEL: xnor_v32i1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addi a2, zero, 32
; CHECK-NEXT:    vsetvli a2, a2, e8,m2,ta,mu
; CHECK-NEXT:    vle1.v v25, (a0)
; CHECK-NEXT:    vle1.v v26, (a1)
; CHECK-NEXT:    vmxnor.mm v25, v25, v26
; CHECK-NEXT:    vse1.v v25, (a0)
; CHECK-NEXT:    ret
  %a = load <32 x i1>, <32 x i1>* %x
  %b = load <32 x i1>, <32 x i1>* %y
  %c = xor <32 x i1> %a, %b
  %d = xor <32 x i1> %c, <i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1>
  store <32 x i1> %d, <32 x i1>* %x
  ret void
}
