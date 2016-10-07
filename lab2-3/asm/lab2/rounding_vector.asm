	.code

	;; Test MAC rounding here, positive values
	set	r0,0x7ecf
	set	r1,0xc04e
	nop
	move	acr0.h,r0
	move	acr0.l,r1
	set	guards01,0x0000
	nop
	nop

	; now acr0 = 0x007ecfc04e
	move	r0,acr0	 	 	; r0 = 0x7ecf
	move	r1,rnd acr0	 	; r1 = 0x7ed0
	move	r2,mul4 acr0 	 	; r2 = 0xfb3f (0xfb3f0138)
	move	r3,rnd mul4 acr0 	; r3 = 0xfb3f
	move	r4,sat rnd mul4 acr0    ; r4 = 0x7fff (saturation should occur)
	nop
	nop
	move 	r5,fl0

	out	0x11,r0		; Send the result to the IOS0011 file
	out	0x11,r1		; so that the result from srsim can be
	out	0x11,r2		; compared to that of the RTL code.
	out	0x11,r3		; If the results are different, you have
	out	0x11,r4		; found a bug in the RTL code.
	out	0x11,r5

	;; terminate simulation
	out	0x12,r0
	nop
