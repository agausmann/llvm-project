; RUN: llc < %s -march=avr -mcpu=atmega328 -O1 | FileCheck %s
; CHECK-NOT: stdwstk

; Checks that we expand STDWSPQRr always - even if it appears outside of the
; FrameSetup/FrameDestroy context.
;
; See:
; - https://reviews.llvm.org/D114611
; - https://reviews.llvm.org/D95664

declare { } @foo(i128, i128) addrspace(1)

define i128 @bar(i128 %a, i128 %b) addrspace(1) {
  %b_neg = icmp slt i128 %b, 0
  %divisor = select i1 %b_neg, i128 0, i128 %b
  %result = tail call fastcc addrspace(1) { } @foo(i128 undef, i128 %divisor)

  ret i128 0
}
