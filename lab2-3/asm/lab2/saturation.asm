	.code

	;; Test positive values
	set	r0,0x2345
	set	r1,0x6789
	nop
	move	acr0.h,r0
	move	acr0.l,r1
	set	guards01,0x0000
	nop
	nop

	; now acr0 = 0x0023456789
	move	r0,acr0	 	 ; r0 = 0x2345
	move	r1,sat acr0	 ; r1 = 0x2345
	move	r2,mul2 acr0 	 ; r2 = 0x468a
	move	r3,sat mul2 acr0 ; r3 = 0x468a
	move	r4,mul4 acr0     ; r4 = 0x8d15 (no saturation)
	move	r5,sat mul4 acr0 ; r5 = 0x7fff (saturation should occur)

	out	0x11,r0		; Send the result to the IOS0011 file
	out	0x11,r1		; so that the result from srsim can be
	out	0x11,r2		; compared to that of the RTL code.
	out	0x11,r3		; If the results are different, you have
	out	0x11,r4		; found a bug in the RTL code.
	out	0x11,r5		; ...

	;;  Test negative values
	set	r0,0x8012
	set	r1,0x3456
	nop
	move	acr0.h,r0
	move	acr0.l,r1
	set	guards01,0xFFFF
	nop
	nop
	
	move	r0,acr0	 	 ; r0 = 0x8012
	move	r1,sat acr0	 ; r1 = 0x8012
	move	r2,mul2 acr0 	 ; r2 = 0x0024 (no saturation)
	move	r3,sat mul2 acr0 ; r3 = 0x8000 (saturation should occur)

	out	0x11,r0		
	out	0x11,r1		
	out	0x11,r2	
	out	0x11,r3


	;; terminate simulation
	out	0x12,r0
	nop
