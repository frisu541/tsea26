	.code


	set	r0,0x1111
	set	r1,0x8011
	set 	r2,0x0001
	set 	r5,0xFFFF
	nop

	add 	r6,r5,0x0001
	add 	r3,r0,r1	; r3 = 0x9122
	add 	r6,r5,0x0001
	add	r4,r0,r2	; r4 = 0x1112
	out 	0x11,r3
	out	0x11,r4

	add 	r6,r5,0x0001
	addc 	r3,r0,r1	; r3 = 0x9123
	add 	r6,r5,0x0001
	addc	r4,r0,r2	; r4 = 0x1112
	out 	0x11,r3
	out	0x11,r4

	add 	r6,r5,0x0001
	sub 	r3,r0,r1	; r3 = 0x9100
	add 	r6,r5,0x0001
	sub	r4,r1,r2	; r4 = 0x8010
	out 	0x11,r3
	out	0x11,r4
	

	;; terminate simulation
	out	0x12,r0
	nop
