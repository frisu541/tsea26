	.code


	;; Test the 'add' instruction
	set	r0,0xffff
	set 	r1,1
	nop
	nop
	add 	r2,r0,r1 	; set carry flag to 1
	nop
	nop
	set 	r0,4
	set 	r1,5
	nop
	nop
	add 	r0,r0,r1
	nop
	nop
	out 	0x11,r0		; should be 9 (0009)
	nop
	nop

	;; Test the 'addc' instruction
	set	r0,0xffff
	set 	r1,1
	nop
	nop
	add 	r2,r0,r1 	; set carry flag to 1
	nop
	nop
	set 	r0,4
	set 	r1,5
	nop
	nop
	addc 	r0,r0,r1
	nop
	nop
	out 	0x11,r0		; should be 10 (000a)


	;; Test the 'sub' instruction
	set 	r0,4
	set 	r1,5
	nop
	nop
	sub 	r0,r0,r1
	nop
	nop
	out 	0x11,r0		; should be -1 (ffff)


	;; Test the 'subc' instruction
	set 	r0,4
	set 	r1,5
	nop
	nop
	subc 	r0,r0,r1
	nop
	nop
	out 	0x11,r0		; should be -2 (fffe)


	;; Test the 'abs' instruction
	abs 	r0,r0
	nop
	nop
	out 	0x11,r0		; should be 2 (0002)
	nop
	nop

	;; Test the 'cmp' instruction
	set	r0,4
	set	r1,4
	nop
	nop
	cmp	r0,r1
	nop
	nop
	move	r0,fl0		; read flags register
	nop
	nop
	out	0x11,r0
	nop
	nop

	;; Test the 'min' and 'max' instructions
	set	r0,0xfffd 	; -3
	set 	r1,0xffff	; -1
	nop
	nop
	max	r2,r0,r1
	nop
	nop
	out 	0x11,r2		; max: should be ffff
	nop
	nop

	min 	r2,r0,r1
	nop
	nop
	out	0x11,r2 	; min: should be fffd
	nop
	nop
	
	;; Both negative, r0 > r1
	set	r0,0xffff 	; -1
	set 	r1,0xfffd	; -3
	nop
	nop
	max	r2,r0,r1
	nop
	nop
	out 	0x11,r2		; max: should be ffff
	nop
	nop

	min 	r2,r0,r1
	nop
	nop
	out	0x11,r2 	; min: should be fffd
	nop
	nop

	;; r0 positive, r1 negative
	set	r0,1
	set 	r1,0xffff	; -1
	nop
	nop
	max	r2,r0,r1
	nop
	nop
	out 	0x11,r2		; max: should be 0001
	nop
	nop

	min 	r2,r0,r1
	nop
	nop
	out	0x11,r2 	; min: should be ffff
	nop
	nop

	;; r0 negative, r1 positive
	set	r0,0xffff 	; -1
	set 	r1,1
	nop
	nop
	max	r2,r0,r1
	nop
	nop
	out 	0x11,r2		; max: should be 0001
	nop
	nop

	min 	r2,r0,r1
	nop
	nop
	out	0x11,r2 	; min: should be ffff
	nop
	nop

	;; both positive, r0 > r1
	set	r0,3
	set 	r1,1
	nop
	nop
	max	r2,r0,r1
	nop
	nop
	out	0x11,r2		; max: should be 0003
	nop
	nop

	min 	r2,r0,r1
	nop
	nop
	out	0x11,r2 	; min: should be 0001
	nop
	nop

	;; both positive, r0 < r1
	set	r0,1
	set 	r1,3
	nop
	nop
	max	r2,r0,r1
	nop
	nop
	out	0x11,r2		; max: should be 0003
	nop
	nop

	min 	r2,r0,r1
	nop
	nop
	out	0x11,r2 	; min: should be 0001
	nop
	nop

	;; terminate simulation
	out	0x12,r0
	nop
