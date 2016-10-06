	.code


	;; Test the 'add' instruction
	set	r0,0xffff
	set 	r1,1
	nop
	add 	r2,r0,r1 	; set carry flag to 1
	nop
	set 	r0,4
	set 	r1,5
	nop
	add 	r2,r0,r1
	nop
	out 	0x11,r2		; should be 9 (0009)


	;; Test the 'addc' instruction
	set	r0,0xffff
	set 	r1,1
	nop
	add 	r2,r0,r1 	; set carry flag to 1
	nop
	set 	r0,4
	set 	r1,5
	nop
	addc 	r2,r0,r1	
	nop
	out 	0x11,r2		; should be 10 (000a)


	;; Test the 'sub' instruction
	set 	r0,4
	set 	r1,5
	nop
	sub 	r2,r0,r1	
	nop
	out 	0x11,r2		; should be -1 (ffff)	


	;; Test the 'subc' instruction
	set 	r0,4
	set 	r1,5
	nop
	subc 	r2,r0,r1	
	nop
	out 	0x11,r2		; should be -2 (fffe)



	;; Test the 'abs' instruction
	abs 	r0,r2
	nop
	out 	0x11,r0		; should be 2 (0002)

	;; Test the 'cmp' instruction
	set	r0,4
	set	r1,4
	nop
	nop
	cmp	r0,r1
	nop
	move	r0,fl0		; read flags register
	nop
	out	0x11,r0	


	;; TODO: test the 'min' and 'max' instructions
	;; ...


	;; terminate simulation
	out	0x12,r0
	nop
