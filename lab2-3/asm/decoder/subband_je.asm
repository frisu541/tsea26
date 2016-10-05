;;; gammal kod: ca 2582 cp (windowing �r ca 1146cp)
;;; ny kod: ca 2374 cp (windowing �r 938cp)

	.code

subband_synthesis_update_V0
;;; updates the V0 pointer as in  *V0 = (*V0-32) & 511;
	ld1	r0,(V0)
	nop
	nop
	sub	r0,32
	nop
	nop
	and	r0,511
	ret	ds2
	nop
	st1	(V0),r0

	.ram1
Vleft				; V[] for left channel
	.skip	1024
Vright				; V[] for right channel
	.skip	1024
V0
	.skip	1

	.rom0
subband_channel_ptr
	.dw	Vleft
	.dw	Vright

	.code

subband_synthesis
	;; r1 => subband stuff (input) buffer in ram1, 32 samples
	;; r2 = channel index (0=left, 1=right)
	;; r3 => pcm (output) buffer in ram1, 32 samples
	;; r8-r15 and ar3 must be preserved

	move	r16,r1		; r16 => input samples in ram1

	set	ar1,subband_channel_ptr
	ld1	r1,(V0)
	nop
	ld0	r0,(ar1,r2)	; r0 => Vleft or Vright
	nop
	nop
	add	r0,r1

	call	ds3 dct32
	nop
	st1	(--ar3),r0
	move	ar0,r0		; ar0 => Vleft/Vright + V0


;;; WINDOWING STARTS HERE

	ld1	r0,(ar3++)	; => Vleft/Vright+V0
	nop
	nop

	;; r0 => Vleft/Vright + V0
	;; r3 => pcm buf (in ram1)

	;; sample 0
	add	r1,r0,16
	set	ar2,D_0
	set	step0,32
	clr	acr0
	move	ar0,r1		; ar0 = work ptr
	nop

	repeat	sam_0_endloop,16
	convss	ap mul4 acr0,(ar2++),(ar0++)
sam_0_endloop

; 	nop
; 	nop
; 	nop
; 	nop
; 	call	dumpACR
	inc	r1
	nop
	move	r0,sat rnd mul4 acr0
	nop
	nop
	set	step0,64
	set	step1,64
	st1	(r3),r0
	inc	r3

	;; samples 1..15
	add	r2,r1,30
	set	r4,14		; iterations-1
	set	ar2,D_1_15

sam_1_15_loop
	clr	acr0
	move	ar0,r1
	move	ar1,r2
	nop

	repeat	sam_1_15_endloop,8
; 	nop
; 	ld0	r0,(ar2)
; 	nop
; 	nop
; 	out	0x11,r0
; 	ld1	r0,(ar0)
; 	nop
; 	nop
; 	out	0x11,r0
; 	nop
	convss	ap mul4 acr0,(ar2++),(ar0++)
; 	nop
; 	call	dumpACR
; 	nop
	convss	am mul4 acr0,(ar2++),(ar1++)
; 	nop
; 	call	dumpACR
; 	nop
; 	nop
; 	nop
; 	nop
sam_1_15_endloop

	nop
	nop
	nop
	nop
	;call	dumpACR
	inc	r1
	dec	r2
	move	r0,sat rnd mul4 acr0
	nop
	clr	acr0
	cmp	0,r4
	
	jump.ne	ds3 sam_1_15_loop
	dec	r4
	st1	(r3),r0
	inc	r3

	;; sample 16
	move	ar0,r1
	set	ar2,D_16
	clr	acr0
	nop


	repeat	sam_16_endloop,8
	convss	ap mul4 acr0,(ar2++),(ar0++)
sam_16_endloop

; 	call	dumpACR

	nop
	nop
	inc	r1
	set	r4,14		; iterations-1
	move	r0,sat rnd mul4 acr0
	nop
	nop
	nop
	nop
	st1	(r3),r0
	inc	r3

	;; samples 17..31
	add	r2,r1,-2
	set	ar2,D_1_15_end

sam_17_31_loop
	move	ar0,r1
	move	ar1,r2
	clr	acr0

	repeat	sam_17_31_endloop,8
	convss	ap mul4 acr0,(--ar2),(ar1++)
	convss	ap mul4 acr0,(--ar2),(ar0++)
sam_17_31_endloop

; 	call	dumpACR
	inc	r1
	dec	r2
	move	r0,rnd sat mul4 acr0
	nop
	cmp	0,r4

	jump.ne	ds3 sam_17_31_loop
	dec	r4
	st1	(r3),r0
	inc	r3

	ret	ds2
	set	step0,1
	set	step1,1





;; --------------------
;; r16 => input data (in ram1)
;; ar0 => output buffer

dct32
	set	sr6,0x1
	set	ar1,coeff_dct32	; Coefficients for dct32 in memory 1
	set	step1,1
	move	r29,ar0
	set	r28,31		; iter-1
	move	ar2,r16

dctloop
	clr	acr0
; 	nop
; 	nop
; 	nop
; 	call	dumpACR
	repeat	endloop,32
; 	nop
; 	ld0	r0,(ar1)
; 	nop
; 	nop
; 	out	0x11,r0
; 	ld1	r0,(ar2)
; 	nop
; 	nop
; 	out	0x11,r0
; 	nop

        convss  am mul4 acr0,(ar1++),(ar2++) ;
endloop
; 	nop
; 	nop
; 	nop
; 	call	dumpACR

	cmp	0,r28
	decn	r28
	move	ar2,r16
	move	r31,sat rnd mul2 acr0
	nop
	nop
	jump.ne	ds3 dctloop
	nop
	st1	(ar0++),r31
	st1	(ar0,511),r31
	
	ret

	.rom0
;;; Automatically generated table, do not edit
	.scale	-1.0
coeff_dct32
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	1.000000
	.df	0.998795
	.df	0.989177
	.df	0.970031
	.df	0.941544
	.df	0.903989
	.df	0.857729
	.df	0.803208
	.df	0.740951
	.df	0.671559
	.df	0.595699
	.df	0.514103
	.df	0.427555
	.df	0.336890
	.df	0.242980
	.df	0.146730
	.df	0.049068
	.df	-0.049068
	.df	-0.146730
	.df	-0.242980
	.df	-0.336890
	.df	-0.427555
	.df	-0.514103
	.df	-0.595699
	.df	-0.671559
	.df	-0.740951
	.df	-0.803208
	.df	-0.857729
	.df	-0.903989
	.df	-0.941544
	.df	-0.970031
	.df	-0.989177
	.df	-0.998795
	.df	0.995185
	.df	0.956940
	.df	0.881921
	.df	0.773010
	.df	0.634393
	.df	0.471397
	.df	0.290285
	.df	0.098017
	.df	-0.098017
	.df	-0.290285
	.df	-0.471397
	.df	-0.634393
	.df	-0.773010
	.df	-0.881921
	.df	-0.956940
	.df	-0.995185
	.df	-0.995185
	.df	-0.956940
	.df	-0.881921
	.df	-0.773010
	.df	-0.634393
	.df	-0.471397
	.df	-0.290285
	.df	-0.098017
	.df	0.098017
	.df	0.290285
	.df	0.471397
	.df	0.634393
	.df	0.773010
	.df	0.881921
	.df	0.956940
	.df	0.995185
	.df	0.989177
	.df	0.903989
	.df	0.740951
	.df	0.514103
	.df	0.242980
	.df	-0.049068
	.df	-0.336890
	.df	-0.595699
	.df	-0.803208
	.df	-0.941544
	.df	-0.998795
	.df	-0.970031
	.df	-0.857729
	.df	-0.671559
	.df	-0.427555
	.df	-0.146730
	.df	0.146730
	.df	0.427555
	.df	0.671559
	.df	0.857729
	.df	0.970031
	.df	0.998795
	.df	0.941544
	.df	0.803208
	.df	0.595699
	.df	0.336890
	.df	0.049068
	.df	-0.242980
	.df	-0.514103
	.df	-0.740951
	.df	-0.903989
	.df	-0.989177
	.df	0.980785
	.df	0.831470
	.df	0.555570
	.df	0.195090
	.df	-0.195090
	.df	-0.555570
	.df	-0.831470
	.df	-0.980785
	.df	-0.980785
	.df	-0.831470
	.df	-0.555570
	.df	-0.195090
	.df	0.195090
	.df	0.555570
	.df	0.831470
	.df	0.980785
	.df	0.980785
	.df	0.831470
	.df	0.555570
	.df	0.195090
	.df	-0.195090
	.df	-0.555570
	.df	-0.831470
	.df	-0.980785
	.df	-0.980785
	.df	-0.831470
	.df	-0.555570
	.df	-0.195090
	.df	0.195090
	.df	0.555570
	.df	0.831470
	.df	0.980785
	.df	0.970031
	.df	0.740951
	.df	0.336890
	.df	-0.146730
	.df	-0.595699
	.df	-0.903989
	.df	-0.998795
	.df	-0.857729
	.df	-0.514103
	.df	-0.049068
	.df	0.427555
	.df	0.803208
	.df	0.989177
	.df	0.941544
	.df	0.671559
	.df	0.242980
	.df	-0.242980
	.df	-0.671559
	.df	-0.941544
	.df	-0.989177
	.df	-0.803208
	.df	-0.427555
	.df	0.049068
	.df	0.514103
	.df	0.857729
	.df	0.998795
	.df	0.903989
	.df	0.595699
	.df	0.146730
	.df	-0.336890
	.df	-0.740951
	.df	-0.970031
	.df	0.956940
	.df	0.634393
	.df	0.098017
	.df	-0.471397
	.df	-0.881921
	.df	-0.995185
	.df	-0.773010
	.df	-0.290285
	.df	0.290285
	.df	0.773010
	.df	0.995185
	.df	0.881921
	.df	0.471397
	.df	-0.098017
	.df	-0.634393
	.df	-0.956940
	.df	-0.956940
	.df	-0.634393
	.df	-0.098017
	.df	0.471397
	.df	0.881921
	.df	0.995185
	.df	0.773010
	.df	0.290285
	.df	-0.290285
	.df	-0.773010
	.df	-0.995185
	.df	-0.881921
	.df	-0.471397
	.df	0.098017
	.df	0.634393
	.df	0.956940
	.df	0.941544
	.df	0.514103
	.df	-0.146730
	.df	-0.740951
	.df	-0.998795
	.df	-0.803208
	.df	-0.242980
	.df	0.427555
	.df	0.903989
	.df	0.970031
	.df	0.595699
	.df	-0.049068
	.df	-0.671559
	.df	-0.989177
	.df	-0.857729
	.df	-0.336890
	.df	0.336890
	.df	0.857729
	.df	0.989177
	.df	0.671559
	.df	0.049068
	.df	-0.595699
	.df	-0.970031
	.df	-0.903989
	.df	-0.427555
	.df	0.242980
	.df	0.803208
	.df	0.998795
	.df	0.740951
	.df	0.146730
	.df	-0.514103
	.df	-0.941544
	.df	0.923880
	.df	0.382683
	.df	-0.382683
	.df	-0.923880
	.df	-0.923880
	.df	-0.382683
	.df	0.382683
	.df	0.923880
	.df	0.923880
	.df	0.382683
	.df	-0.382683
	.df	-0.923880
	.df	-0.923880
	.df	-0.382683
	.df	0.382683
	.df	0.923880
	.df	0.923880
	.df	0.382683
	.df	-0.382683
	.df	-0.923880
	.df	-0.923880
	.df	-0.382683
	.df	0.382683
	.df	0.923880
	.df	0.923880
	.df	0.382683
	.df	-0.382683
	.df	-0.923880
	.df	-0.923880
	.df	-0.382683
	.df	0.382683
	.df	0.923880
	.df	0.903989
	.df	0.242980
	.df	-0.595699
	.df	-0.998795
	.df	-0.671559
	.df	0.146730
	.df	0.857729
	.df	0.941544
	.df	0.336890
	.df	-0.514103
	.df	-0.989177
	.df	-0.740951
	.df	0.049068
	.df	0.803208
	.df	0.970031
	.df	0.427555
	.df	-0.427555
	.df	-0.970031
	.df	-0.803208
	.df	-0.049068
	.df	0.740951
	.df	0.989177
	.df	0.514103
	.df	-0.336890
	.df	-0.941544
	.df	-0.857729
	.df	-0.146730
	.df	0.671559
	.df	0.998795
	.df	0.595699
	.df	-0.242980
	.df	-0.903989
	.df	0.881921
	.df	0.098017
	.df	-0.773010
	.df	-0.956940
	.df	-0.290285
	.df	0.634393
	.df	0.995185
	.df	0.471397
	.df	-0.471397
	.df	-0.995185
	.df	-0.634393
	.df	0.290285
	.df	0.956940
	.df	0.773010
	.df	-0.098017
	.df	-0.881921
	.df	-0.881921
	.df	-0.098017
	.df	0.773010
	.df	0.956940
	.df	0.290285
	.df	-0.634393
	.df	-0.995185
	.df	-0.471397
	.df	0.471397
	.df	0.995185
	.df	0.634393
	.df	-0.290285
	.df	-0.956940
	.df	-0.773010
	.df	0.098017
	.df	0.881921
	.df	0.857729
	.df	-0.049068
	.df	-0.903989
	.df	-0.803208
	.df	0.146730
	.df	0.941544
	.df	0.740951
	.df	-0.242980
	.df	-0.970031
	.df	-0.671559
	.df	0.336890
	.df	0.989177
	.df	0.595699
	.df	-0.427555
	.df	-0.998795
	.df	-0.514103
	.df	0.514103
	.df	0.998795
	.df	0.427555
	.df	-0.595699
	.df	-0.989177
	.df	-0.336890
	.df	0.671559
	.df	0.970031
	.df	0.242980
	.df	-0.740951
	.df	-0.941544
	.df	-0.146730
	.df	0.803208
	.df	0.903989
	.df	0.049068
	.df	-0.857729
	.df	0.831470
	.df	-0.195090
	.df	-0.980785
	.df	-0.555570
	.df	0.555570
	.df	0.980785
	.df	0.195090
	.df	-0.831470
	.df	-0.831470
	.df	0.195090
	.df	0.980785
	.df	0.555570
	.df	-0.555570
	.df	-0.980785
	.df	-0.195090
	.df	0.831470
	.df	0.831470
	.df	-0.195090
	.df	-0.980785
	.df	-0.555570
	.df	0.555570
	.df	0.980785
	.df	0.195090
	.df	-0.831470
	.df	-0.831470
	.df	0.195090
	.df	0.980785
	.df	0.555570
	.df	-0.555570
	.df	-0.980785
	.df	-0.195090
	.df	0.831470
	.df	0.803208
	.df	-0.336890
	.df	-0.998795
	.df	-0.242980
	.df	0.857729
	.df	0.740951
	.df	-0.427555
	.df	-0.989177
	.df	-0.146730
	.df	0.903989
	.df	0.671559
	.df	-0.514103
	.df	-0.970031
	.df	-0.049068
	.df	0.941544
	.df	0.595699
	.df	-0.595699
	.df	-0.941544
	.df	0.049068
	.df	0.970031
	.df	0.514103
	.df	-0.671559
	.df	-0.903989
	.df	0.146730
	.df	0.989177
	.df	0.427555
	.df	-0.740951
	.df	-0.857729
	.df	0.242980
	.df	0.998795
	.df	0.336890
	.df	-0.803208
	.df	0.773010
	.df	-0.471397
	.df	-0.956940
	.df	0.098017
	.df	0.995185
	.df	0.290285
	.df	-0.881921
	.df	-0.634393
	.df	0.634393
	.df	0.881921
	.df	-0.290285
	.df	-0.995185
	.df	-0.098017
	.df	0.956940
	.df	0.471397
	.df	-0.773010
	.df	-0.773010
	.df	0.471397
	.df	0.956940
	.df	-0.098017
	.df	-0.995185
	.df	-0.290285
	.df	0.881921
	.df	0.634393
	.df	-0.634393
	.df	-0.881921
	.df	0.290285
	.df	0.995185
	.df	0.098017
	.df	-0.956940
	.df	-0.471397
	.df	0.773010
	.df	0.740951
	.df	-0.595699
	.df	-0.857729
	.df	0.427555
	.df	0.941544
	.df	-0.242980
	.df	-0.989177
	.df	0.049068
	.df	0.998795
	.df	0.146730
	.df	-0.970031
	.df	-0.336890
	.df	0.903989
	.df	0.514103
	.df	-0.803208
	.df	-0.671559
	.df	0.671559
	.df	0.803208
	.df	-0.514103
	.df	-0.903989
	.df	0.336890
	.df	0.970031
	.df	-0.146730
	.df	-0.998795
	.df	-0.049068
	.df	0.989177
	.df	0.242980
	.df	-0.941544
	.df	-0.427555
	.df	0.857729
	.df	0.595699
	.df	-0.740951
	.df	0.707107
	.df	-0.707107
	.df	-0.707107
	.df	0.707107
	.df	0.707107
	.df	-0.707107
	.df	-0.707107
	.df	0.707107
	.df	0.707107
	.df	-0.707107
	.df	-0.707107
	.df	0.707107
	.df	0.707107
	.df	-0.707107
	.df	-0.707107
	.df	0.707107
	.df	0.707107
	.df	-0.707107
	.df	-0.707107
	.df	0.707107
	.df	0.707107
	.df	-0.707107
	.df	-0.707107
	.df	0.707107
	.df	0.707107
	.df	-0.707107
	.df	-0.707107
	.df	0.707107
	.df	0.707107
	.df	-0.707107
	.df	-0.707107
	.df	0.707107
	.df	0.671559
	.df	-0.803208
	.df	-0.514103
	.df	0.903989
	.df	0.336890
	.df	-0.970031
	.df	-0.146730
	.df	0.998795
	.df	-0.049068
	.df	-0.989177
	.df	0.242980
	.df	0.941544
	.df	-0.427555
	.df	-0.857729
	.df	0.595699
	.df	0.740951
	.df	-0.740951
	.df	-0.595699
	.df	0.857729
	.df	0.427555
	.df	-0.941544
	.df	-0.242980
	.df	0.989177
	.df	0.049068
	.df	-0.998795
	.df	0.146730
	.df	0.970031
	.df	-0.336890
	.df	-0.903989
	.df	0.514103
	.df	0.803208
	.df	-0.671559
	.df	0.634393
	.df	-0.881921
	.df	-0.290285
	.df	0.995185
	.df	-0.098017
	.df	-0.956940
	.df	0.471397
	.df	0.773010
	.df	-0.773010
	.df	-0.471397
	.df	0.956940
	.df	0.098017
	.df	-0.995185
	.df	0.290285
	.df	0.881921
	.df	-0.634393
	.df	-0.634393
	.df	0.881921
	.df	0.290285
	.df	-0.995185
	.df	0.098017
	.df	0.956940
	.df	-0.471397
	.df	-0.773010
	.df	0.773010
	.df	0.471397
	.df	-0.956940
	.df	-0.098017
	.df	0.995185
	.df	-0.290285
	.df	-0.881921
	.df	0.634393
	.df	0.595699
	.df	-0.941544
	.df	-0.049068
	.df	0.970031
	.df	-0.514103
	.df	-0.671559
	.df	0.903989
	.df	0.146730
	.df	-0.989177
	.df	0.427555
	.df	0.740951
	.df	-0.857729
	.df	-0.242980
	.df	0.998795
	.df	-0.336890
	.df	-0.803208
	.df	0.803208
	.df	0.336890
	.df	-0.998795
	.df	0.242980
	.df	0.857729
	.df	-0.740951
	.df	-0.427555
	.df	0.989177
	.df	-0.146730
	.df	-0.903989
	.df	0.671559
	.df	0.514103
	.df	-0.970031
	.df	0.049068
	.df	0.941544
	.df	-0.595699
	.df	0.555570
	.df	-0.980785
	.df	0.195090
	.df	0.831470
	.df	-0.831470
	.df	-0.195090
	.df	0.980785
	.df	-0.555570
	.df	-0.555570
	.df	0.980785
	.df	-0.195090
	.df	-0.831470
	.df	0.831470
	.df	0.195090
	.df	-0.980785
	.df	0.555570
	.df	0.555570
	.df	-0.980785
	.df	0.195090
	.df	0.831470
	.df	-0.831470
	.df	-0.195090
	.df	0.980785
	.df	-0.555570
	.df	-0.555570
	.df	0.980785
	.df	-0.195090
	.df	-0.831470
	.df	0.831470
	.df	0.195090
	.df	-0.980785
	.df	0.555570
	.df	0.514103
	.df	-0.998795
	.df	0.427555
	.df	0.595699
	.df	-0.989177
	.df	0.336890
	.df	0.671559
	.df	-0.970031
	.df	0.242980
	.df	0.740951
	.df	-0.941544
	.df	0.146730
	.df	0.803208
	.df	-0.903989
	.df	0.049068
	.df	0.857729
	.df	-0.857729
	.df	-0.049068
	.df	0.903989
	.df	-0.803208
	.df	-0.146730
	.df	0.941544
	.df	-0.740951
	.df	-0.242980
	.df	0.970031
	.df	-0.671559
	.df	-0.336890
	.df	0.989177
	.df	-0.595699
	.df	-0.427555
	.df	0.998795
	.df	-0.514103
	.df	0.471397
	.df	-0.995185
	.df	0.634393
	.df	0.290285
	.df	-0.956940
	.df	0.773010
	.df	0.098017
	.df	-0.881921
	.df	0.881921
	.df	-0.098017
	.df	-0.773010
	.df	0.956940
	.df	-0.290285
	.df	-0.634393
	.df	0.995185
	.df	-0.471397
	.df	-0.471397
	.df	0.995185
	.df	-0.634393
	.df	-0.290285
	.df	0.956940
	.df	-0.773010
	.df	-0.098017
	.df	0.881921
	.df	-0.881921
	.df	0.098017
	.df	0.773010
	.df	-0.956940
	.df	0.290285
	.df	0.634393
	.df	-0.995185
	.df	0.471397
	.df	0.427555
	.df	-0.970031
	.df	0.803208
	.df	-0.049068
	.df	-0.740951
	.df	0.989177
	.df	-0.514103
	.df	-0.336890
	.df	0.941544
	.df	-0.857729
	.df	0.146730
	.df	0.671559
	.df	-0.998795
	.df	0.595699
	.df	0.242980
	.df	-0.903989
	.df	0.903989
	.df	-0.242980
	.df	-0.595699
	.df	0.998795
	.df	-0.671559
	.df	-0.146730
	.df	0.857729
	.df	-0.941544
	.df	0.336890
	.df	0.514103
	.df	-0.989177
	.df	0.740951
	.df	0.049068
	.df	-0.803208
	.df	0.970031
	.df	-0.427555
	.df	0.382683
	.df	-0.923880
	.df	0.923880
	.df	-0.382683
	.df	-0.382683
	.df	0.923880
	.df	-0.923880
	.df	0.382683
	.df	0.382683
	.df	-0.923880
	.df	0.923880
	.df	-0.382683
	.df	-0.382683
	.df	0.923880
	.df	-0.923880
	.df	0.382683
	.df	0.382683
	.df	-0.923880
	.df	0.923880
	.df	-0.382683
	.df	-0.382683
	.df	0.923880
	.df	-0.923880
	.df	0.382683
	.df	0.382683
	.df	-0.923880
	.df	0.923880
	.df	-0.382683
	.df	-0.382683
	.df	0.923880
	.df	-0.923880
	.df	0.382683
	.df	0.336890
	.df	-0.857729
	.df	0.989177
	.df	-0.671559
	.df	0.049068
	.df	0.595699
	.df	-0.970031
	.df	0.903989
	.df	-0.427555
	.df	-0.242980
	.df	0.803208
	.df	-0.998795
	.df	0.740951
	.df	-0.146730
	.df	-0.514103
	.df	0.941544
	.df	-0.941544
	.df	0.514103
	.df	0.146730
	.df	-0.740951
	.df	0.998795
	.df	-0.803208
	.df	0.242980
	.df	0.427555
	.df	-0.903989
	.df	0.970031
	.df	-0.595699
	.df	-0.049068
	.df	0.671559
	.df	-0.989177
	.df	0.857729
	.df	-0.336890
	.df	0.290285
	.df	-0.773010
	.df	0.995185
	.df	-0.881921
	.df	0.471397
	.df	0.098017
	.df	-0.634393
	.df	0.956940
	.df	-0.956940
	.df	0.634393
	.df	-0.098017
	.df	-0.471397
	.df	0.881921
	.df	-0.995185
	.df	0.773010
	.df	-0.290285
	.df	-0.290285
	.df	0.773010
	.df	-0.995185
	.df	0.881921
	.df	-0.471397
	.df	-0.098017
	.df	0.634393
	.df	-0.956940
	.df	0.956940
	.df	-0.634393
	.df	0.098017
	.df	0.471397
	.df	-0.881921
	.df	0.995185
	.df	-0.773010
	.df	0.290285
	.df	0.242980
	.df	-0.671559
	.df	0.941544
	.df	-0.989177
	.df	0.803208
	.df	-0.427555
	.df	-0.049068
	.df	0.514103
	.df	-0.857729
	.df	0.998795
	.df	-0.903989
	.df	0.595699
	.df	-0.146730
	.df	-0.336890
	.df	0.740951
	.df	-0.970031
	.df	0.970031
	.df	-0.740951
	.df	0.336890
	.df	0.146730
	.df	-0.595699
	.df	0.903989
	.df	-0.998795
	.df	0.857729
	.df	-0.514103
	.df	0.049068
	.df	0.427555
	.df	-0.803208
	.df	0.989177
	.df	-0.941544
	.df	0.671559
	.df	-0.242980
	.df	0.195090
	.df	-0.555570
	.df	0.831470
	.df	-0.980785
	.df	0.980785
	.df	-0.831470
	.df	0.555570
	.df	-0.195090
	.df	-0.195090
	.df	0.555570
	.df	-0.831470
	.df	0.980785
	.df	-0.980785
	.df	0.831470
	.df	-0.555570
	.df	0.195090
	.df	0.195090
	.df	-0.555570
	.df	0.831470
	.df	-0.980785
	.df	0.980785
	.df	-0.831470
	.df	0.555570
	.df	-0.195090
	.df	-0.195090
	.df	0.555570
	.df	-0.831470
	.df	0.980785
	.df	-0.980785
	.df	0.831470
	.df	-0.555570
	.df	0.195090
	.df	0.146730
	.df	-0.427555
	.df	0.671559
	.df	-0.857729
	.df	0.970031
	.df	-0.998795
	.df	0.941544
	.df	-0.803208
	.df	0.595699
	.df	-0.336890
	.df	0.049068
	.df	0.242980
	.df	-0.514103
	.df	0.740951
	.df	-0.903989
	.df	0.989177
	.df	-0.989177
	.df	0.903989
	.df	-0.740951
	.df	0.514103
	.df	-0.242980
	.df	-0.049068
	.df	0.336890
	.df	-0.595699
	.df	0.803208
	.df	-0.941544
	.df	0.998795
	.df	-0.970031
	.df	0.857729
	.df	-0.671559
	.df	0.427555
	.df	-0.146730
	.df	0.098017
	.df	-0.290285
	.df	0.471397
	.df	-0.634393
	.df	0.773010
	.df	-0.881921
	.df	0.956940
	.df	-0.995185
	.df	0.995185
	.df	-0.956940
	.df	0.881921
	.df	-0.773010
	.df	0.634393
	.df	-0.471397
	.df	0.290285
	.df	-0.098017
	.df	-0.098017
	.df	0.290285
	.df	-0.471397
	.df	0.634393
	.df	-0.773010
	.df	0.881921
	.df	-0.956940
	.df	0.995185
	.df	-0.995185
	.df	0.956940
	.df	-0.881921
	.df	0.773010
	.df	-0.634393
	.df	0.471397
	.df	-0.290285
	.df	0.098017
	.df	0.049068
	.df	-0.146730
	.df	0.242980
	.df	-0.336890
	.df	0.427555
	.df	-0.514103
	.df	0.595699
	.df	-0.671559
	.df	0.740951
	.df	-0.803208
	.df	0.857729
	.df	-0.903989
	.df	0.941544
	.df	-0.970031
	.df	0.989177
	.df	-0.998795
	.df	0.998795
	.df	-0.989177
	.df	0.970031
	.df	-0.941544
	.df	0.903989
	.df	-0.857729
	.df	0.803208
	.df	-0.740951
	.df	0.671559
	.df	-0.595699
	.df	0.514103
	.df	-0.427555
	.df	0.336890
	.df	-0.242980
	.df	0.146730
	.df	-0.049068

	.scale	2.0
D_0
	.df	 0.000000000
	.df	 0.000442505
	.df	 0.003250122
	.df	 0.007003784
	.df	 0.031082153
	.df	 0.078628540
	.df	 0.100311279
	.df	 0.572036743
	.df	 1.144989014
	.df	-0.572036743
	.df	 0.100311279
	.df	-0.078628540
	.df	 0.031082153
	.df	-0.007003784
	.df	 0.003250122
	.df	-0.000442505

D_1_15
	.df	-0.000015259
	.df	-0.000473022
	.df	 0.003326416
	.df	-0.007919312
	.df	 0.030517578
	.df	-0.084182739
	.df	 0.090927124
	.df	-0.600219727
	.df	 1.144287109
	.df	 0.543823242
	.df	 0.108856201
	.df	 0.073059082
	.df	 0.031478882
	.df	 0.006118774
	.df	 0.003173828
	.df	 0.000396729
	.df	-0.000015259
	.df	-0.000534058
	.df	 0.003387451
	.df	-0.008865356
	.df	 0.029785156
	.df	-0.089706421
	.df	 0.080688477
	.df	-0.628295898
	.df	 1.142211914
	.df	 0.515609741
	.df	 0.116577148
	.df	 0.067520142
	.df	 0.031738281
	.df	 0.005294800
	.df	 0.003082275
	.df	 0.000366211
	.df	-0.000015259
	.df	-0.000579834
	.df	 0.003433228
	.df	-0.009841919
	.df	 0.028884888
	.df	-0.095169067
	.df	 0.069595337
	.df	-0.656219482
	.df	 1.138763428
	.df	 0.487472534
	.df	 0.123474121
	.df	 0.061996460
	.df	 0.031845093
	.df	 0.004486084
	.df	 0.002990723
	.df	 0.000320435
	.df	-0.000015259
	.df	-0.000625610
	.df	 0.003463745
	.df	-0.010848999
	.df	 0.027801514
	.df	-0.100540161
	.df	 0.057617187
	.df	-0.683914185
	.df	 1.133926392
	.df	 0.459472656
	.df	 0.129577637
	.df	 0.056533813
	.df	 0.031814575
	.df	 0.003723145
	.df	 0.002899170
	.df	 0.000289917
	.df	-0.000015259
	.df	-0.000686646
	.df	 0.003479004
	.df	-0.011886597
	.df	 0.026535034
	.df	-0.105819702
	.df	 0.044784546
	.df	-0.711318970
	.df	 1.127746582
	.df	 0.431655884
	.df	 0.134887695
	.df	 0.051132202
	.df	 0.031661987
	.df	 0.003005981
	.df	 0.002792358
	.df	 0.000259399
	.df	-0.000015259
	.df	-0.000747681
	.df	 0.003479004
	.df	-0.012939453
	.df	 0.025085449
	.df	-0.110946655
	.df	 0.031082153
	.df	-0.738372803
	.df	 1.120223999
	.df	 0.404083252
	.df	 0.139450073
	.df	 0.045837402
	.df	 0.031387329
	.df	 0.002334595
	.df	 0.002685547
	.df	 0.000244141
	.df	-0.000030518
	.df	-0.000808716
	.df	 0.003463745
	.df	-0.014022827
	.df	 0.023422241
	.df	-0.115921021
	.df	 0.016510010
	.df	-0.765029907
	.df	 1.111373901
	.df	 0.376800537
	.df	 0.143264771
	.df	 0.040634155
	.df	 0.031005859
	.df	 0.001693726
	.df	 0.002578735
	.df	 0.000213623
	.df	-0.000030518
	.df	-0.000885010
	.df	 0.003417969
	.df	-0.015121460
	.df	 0.021575928
	.df	-0.120697021
	.df	 0.001068115
	.df	-0.791213989
	.df	 1.101211548
	.df	 0.349868774
	.df	 0.146362305
	.df	 0.035552979
	.df	 0.030532837
	.df	 0.001098633
	.df	 0.002456665
	.df	 0.000198364
	.df	-0.000030518
	.df	-0.000961304
	.df	 0.003372192
	.df	-0.016235352
	.df	 0.019531250
	.df	-0.125259399
	.df	-0.015228271
	.df	-0.816864014
	.df	 1.089782715
	.df	 0.323318481
	.df	 0.148773193
	.df	 0.030609131
	.df	 0.029937744
	.df	 0.000549316
	.df	 0.002349854
	.df	 0.000167847
	.df	-0.000030518
	.df	-0.001037598
	.df	 0.003280640
	.df	-0.017349243
	.df	 0.017257690
	.df	-0.129562378
	.df	-0.032379150
	.df	-0.841949463
	.df	 1.077117920
	.df	 0.297210693
	.df	 0.150497437
	.df	 0.025817871
	.df	 0.029281616
	.df	 0.000030518
	.df	 0.002243042
	.df	 0.000152588
	.df	-0.000045776
	.df	-0.001113892
	.df	 0.003173828
	.df	-0.018463135
	.df	 0.014801025
	.df	-0.133590698
	.df	-0.050354004
	.df	-0.866363525
	.df	 1.063217163
	.df	 0.271591187
	.df	 0.151596069
	.df	 0.021179199
	.df	 0.028533936
	.df	-0.000442505
	.df	 0.002120972
	.df	 0.000137329
	.df	-0.000045776
	.df	-0.001205444
	.df	 0.003051758
	.df	-0.019577026
	.df	 0.012115479
	.df	-0.137298584
	.df	-0.069168091
	.df	-0.890090942
	.df	 1.048156738
	.df	 0.246505737
	.df	 0.152069092
	.df	 0.016708374
	.df	 0.027725220
	.df	-0.000869751
	.df	 0.002014160
	.df	 0.000122070
	.df	-0.000061035
	.df	-0.001296997
	.df	 0.002883911
	.df	-0.020690918
	.df	 0.009231567
	.df	-0.140670776
	.df	-0.088775635
	.df	-0.913055420
	.df	 1.031936646
	.df	 0.221984863
	.df	 0.151962280
	.df	 0.012420654
	.df	 0.026840210
	.df	-0.001266479
	.df	 0.001907349
	.df	 0.000106812
	.df	-0.000061035
	.df	-0.001388550
	.df	 0.002700806
	.df	-0.021789551
	.df	 0.006134033
	.df	-0.143676758
	.df	-0.109161377
	.df	-0.935195923
	.df	 1.014617920
	.df	 0.198059082
	.df	 0.151306152
	.df	 0.008316040
	.df	 0.025909424
	.df	-0.001617432
	.df	 0.001785278
	.df	 0.000106812
	.df	-0.000076294
	.df	-0.001480103
	.df	 0.002487183
	.df	-0.022857666
	.df	 0.002822876
	.df	-0.146255493
	.df	-0.130310059
	.df	-0.956481934
	.df	 0.996246338
	.df	 0.174789429
	.df	 0.150115967
	.df	 0.004394531
	.df	 0.024932861
	.df	-0.001937866
	.df	 0.001693726
	.df	 0.000091553
D_1_15_end

D_16
	.df	0.001586914
	.df	0.023910522
	.df	0.148422241
	.df	0.976852417
	.df	-0.152206421
	.df	-0.000686646
	.df	0.002227783
	.df	-0.000076294
