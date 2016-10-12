	.code

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Test MAC positive values, rnd with a 1, rnd + sat (no saturation),
;;; rnd with a 0 + sat + scale (should saturate)
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	set	r0,0x7ecf
	set	r1,0xc04e
	nop
	move	acr0.h,r0
	move	acr0.l,r1
	set	guards01,0x0000
	nop
	nop

	; now acr0 = 0x007ecfc04e
	move	r0,acr0			; r0 = 0x7ecf
	move	r1,rnd acr0	 	; r1 = 0x7ed0
	move	r2,mul4 acr0 	 	; r2 = 0xfb3f (0xfb3f0138)
	nop
	move  	r3,fl0
	move	r4,rnd mul4 acr0 	; r4 = 0xfb3f
	nop
	move 	r5,fl0
	move	r6,sat rnd mul4 acr0    ; r6 = 0x7fff (saturation should occur)
	nop
	move 	r7,fl0

	out	0x11,r0		; Send the result to the IOS0011 file
	out	0x11,r1		; so that the result from srsim can be
	out	0x11,r2		; compared to that of the RTL code.
	out	0x11,r3		; If the results are different, you have
	out	0x11,r4		; found a bug in the RTL code.
	out	0x11,r5
	out	0x11,r6
	out	0x11,r7

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Test MAC positive value, rnd and sat when rnd gives overflow (but wasn´t before)	
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	set	r0,0x7fff
	set	r1,0xff00
	nop
	move	acr0.h,r0
	move	acr0.l,r1
	set	guards01,0x0000
	nop
	nop

	; now acr0 = 0x007fffff00
	move	r0,acr0			; r0 = 0x7fff
	move	r1,rnd acr0	 	; r1 = 0x8000
	nop
	move  	r2,fl0
	move	r3,sat rnd acr0 	; r3 = 0x7fff
	nop
	move 	r4,fl0

	out	0x11,r0		; Send the result to the IOS0011 file
	out	0x11,r1		; so that the result from srsim can be
	out	0x11,r2		; compared to that of the RTL code.
	out	0x11,r3		; If the results are different, you have
	out	0x11,r4		; found a bug in the RTL code.

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  Test MAC negative values rnd overflow, rnd + sat overflow
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	set	r0,0xfdcf
	set	r1,0xc04e
	nop
	move	acr0.h,r0
	move	acr0.l,r1
	set	guards01,0xfd00
	nop
	nop

	; now acr0 = 0xfdfecfc04e
	move	r0,acr0			; r0 = 0xfdcf
	move	r1,rnd acr0	 	; r1 = 0xfdd0
	nop
	move	r2, fl0
	move	r3,sat rnd acr0    	; r6 = 0x8000 (saturation should occur)
	nop
	move 	r4,fl0

	out	0x11,r0		; Send the result to the IOS0011 file
	out	0x11,r1		; so that the result from srsim can be
	out	0x11,r2		; compared to that of the RTL code.
	out	0x11,r3		; If the results are different, you have
	out	0x11,r4		; found a bug in the RTL code.


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;;; Test each of the mac-instuctions
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	set 	r0,0xa54f
	set 	r1,0x03ff
	set	r2,0xa54f
	set	r3,0xf687

	move 	acr0.h,r0
	move 	acr0.l,r1
	move	acr1.h,r0
	move	acr1.l,r1
	set	guards01,0x00ff

	;; addl
	addl	acr2,acr0,acr1
	nop
	nop

	move	r4,fl0
	move 	r5,guards23
	move	r6,acr2
	move 	r7,mul65536 acr2

	out 	0x11,r4
	out	0x11,r5
	out	0x11,r6
	out	0x11,r7
	
	;; subl
	subl	acr2,acr0,acr1
	nop
	nop

	move	r4,fl0
	move 	r5,guards23
	move	r6,acr2
	move 	r7,mul65536 acr2

	out 	0x11,r4
	out	0x11,r5
	out	0x11,r6
	out 	0x11,r7	

	;; cmpl
	cmpl 	acr0,acr0
	nop
	nop

	move	r4,fl0
	nop
	nop

	cmpl 	acr0,acr1
	nop
	nop

	move	r5,fl0
	
	out 	0x11,r4
	out 	0x11,r5

	;; absl
	absl 	acr2,acr0
	absl	acr3,acr1
	nop
	nop

	move	r4,fl0
	move 	r5,guards23
	move	r6,acr2
	move 	r7,mul65536 acr2
	move	r8,acr3
	move	r9,mul65536 acr3

	out 	0x11,r4
	out	0x11,r5
	out	0x11,r6
	out 	0x11,r7	
	out	0x11,r8
	out	0x11,r9
	
	;; negl
	negl 	acr2,acr0
	negl	acr3,acr1
	nop
	nop

	move	r4,fl0
	move 	r5,guards23
	move	r6,acr2
	move 	r7,mul65536 acr2
	move	r8,acr3
	move	r9,mul65536 acr3

	out 	0x11,r4
	out	0x11,r5
	out	0x11,r6
	out 	0x11,r7	
	out	0x11,r8
	out	0x11,r9

	;; movel
	movel 	acr2,r8:r9

	nop
	nop

	move	r4,fl0
	move 	r5,guards23
	move	r6,acr2
	move 	r7,mul65536 acr2

	out 	0x11,r4
	out	0x11,r5
	out	0x11,r6
	out 	0x11,r7
	
	;; clr
	move	r4,fl0
	move 	r5,guards01
	move	r6,acr1
	move 	r7,mul65536 acr1

	out 	0x11,r4
	out	0x11,r5
	out	0x11,r6
	out 	0x11,r7	

	clr 	acr0
	clr 	acr1

	nop
	nop

	move	r4,fl0
	move 	r5,guards01
	move	r6,acr1
	move 	r7,mul65536 acr1

	out 	0x11,r4
	out	0x11,r5
	out	0x11,r6
	out 	0x11,r7	
	
	;; postop
	set 	r0,0x7f35
	set 	r1,0xfffa
	set	r2,0x80f0
	set	r3,0x0000

	move 	acr0.h,r0
	move 	acr0.l,r1
	move	acr1.h,r0
	move	acr1.l,r1
	set	guards01,0x08fa

	postop	acr2,rnd sat acr0
	postop	acr3,rnd sat mul2 acr1

	nop
	nop

	move	r4,fl0
	move 	r5,guards23
	move	r6,acr2
	move 	r7,mul65536 acr2
	move	r8,acr3
	move	r9,mul65536 acr3

	out 	0x11,r4
	out	0x11,r5
	out	0x11,r6
	out 	0x11,r7	
	out	0x11,r8
	out	0x11,r9

	clr 	acr0
	clr	acr1
	clr	acr2
	clr	acr3
	
	;; mul
	set	r0,0x06ef
	set	r1,0xff8e
	nop
	nop

	mulss	acr0,r0,r1
	nop
	mulus	acr1,r0,r1
	nop
	muluu	acr2,r0,r1
	nop
	mulss	div2 acr3,r0,r1
	nop
	nop
	
	move	r4,fl0
	move 	r5,guards01
	move	r6,acr0
	move 	r7,mul65536 acr0
	move 	r8,acr1
	move	r9,mul65536 acr1

	out 	0x11,r4
	out	0x11,r5
	out	0x11,r6
	out 	0x11,r7
	out	0x11,r8
	out 	0x11,r9

	move 	r5,guards23
	move	r6,acr2
	move 	r7,mul65536 acr2
	move 	r8,acr3
	move	r9,mul65536 acr3

	out 	0x11,r4
	out	0x11,r5
	out	0x11,r6
	out 	0x11,r7
	out	0x11,r8
	out 	0x11,r9	
	
	;; mac
	macss	acr3,r0,r1
	nop
	nop
	
	move	r4,fl0
	move 	r5,guards23
	move	r6,acr3
	move 	r7,mul65536 acr3

	out 	0x11,r4
	out	0x11,r5
	out	0x11,r6
	out 	0x11,r7

	macss	mul65536 acr3,r0,r1
	nop
	nop

	move	r4,fl0
	move 	r5,guards23
	move	r6,acr3
	move 	r7,mul65536 acr3

	out 	0x11,r4
	out	0x11,r5
	out	0x11,r6
	out 	0x11,r7
	
	;; mdm
	mdmss 	mul4 acr3,r0,r1
	nop
	nop

	move	r4,fl0
	move 	r5,guards23
	move	r6,acr3
	move 	r7,mul65536 acr3

	out 	0x11,r4
	out	0x11,r5
	out	0x11,r6
	out 	0x11,r7

	
	;; terminate simulation
	out	0x12,r0
	nop
