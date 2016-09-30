	.code
	set sp,stackarea		; We obviously need some space for the stack...
	nop
	call initfirkernel
	call initsanitycheck	; Set up random values in almost all registers

;;; ----------------------------------------------------------------------
;;; Main loop. This loop ensures that handle_sample is called 1000 times.
;;; ----------------------------------------------------------------------
	set r31,1000
loop
	call handle_sample

	add r31,-1
	jump.ne loop		

	call sanitycheck  ; Ensure no register was clobbered
	out 0x13,r0       ; Signals that we are at the end of the loop


;;; ----------------------------------------------------------------------
;;; We assume that the handle_sample signal is called with a frequency
;;; of 500 Hz from a timer interrupt. It can thus not assume anything
;;; about the contents of the registers and must also save all registers
;;; that are modified.
;;; 
;;; Once all registers are saved it calls fir_kernel to perform the actual
;;; filtering.
;;; ----------------------------------------------------------------------
handle_sample
	ret


;;; ----------------------------------------------------------------------
;;; Allocate variables used by the fir_kernel here
;;; ----------------------------------------------------------------------
	
	.ram0
current_location
	.skip 1

;;; ----------------------------------------------------------------------
;;; Initialization function for the fir kernel. Right now it only sets
;;; the current_location variable but you may want to do something more
;;; here in the lab.
;;; ----------------------------------------------------------------------
	.code
initfirkernel
	set r1,ringbuffer
	nop
	st0 (current_location),r1
	ret

;;; ----------------------------------------------------------------------
;;; This is the filter kernel. It assumes that the following registers
;;; can be changed: r0, r1, ar0, ar1, step0, step1, bot1, top1, acr0,
;;; loopn/b/e. If you need to modify other registers, change
;;; handle_sample above!
;;; ----------------------------------------------------------------------
	.code
fir_kernel
    
	in r0,0x10			; Read next input sample 
	ld0 r1,(current_location) 	; Load address to current location in ringbuffer	
	set step1,1		  	; Initiate stepsize for samples
	move ar1,r1		

	clr acr0 		; Clear acr0
	st1 (ar1), r0		; Store sample into ringbuffer
	
	set step0,1		; Initiate stepsize for coefficients
	set r0, coefficients
	
	set bot1,ringbuffer	
	set top1,top_ringbuffer

	move ar0,r0

	repeat conv_tap, 31 	; Repeat 31 taps of convolution
	convus acr0,(ar0++),(ar1++%)
conv_tap
	
	move r1, ar1
	convus acr0,(ar0++),(ar1++%) ; Tap 32 of the convolution
	st0 (current_location), r1 ; Store value of current location for next call to fir_kernel
	nop
	
	move r0,sat rnd div8 acr0 ; Scaling factor, div8 because of scaled coefficients
	nop
	
	out 0x11,r0		; Output a sample
	ret
	

;;; ----------------------------------------------------------------------
;;; Allocate space for ringbuffer. We put this in DM1 since the
;;; filter coefficients are stored in DM0 (as we only have a rom in DM0)
;;; ----------------------------------------------------------------------
	.ram1
ringbuffer
	.skip 31
top_ringbuffer			; Convenient label
	.skip 1
	

;;; ----------------------------------------------------------------------
;;; The filter coefficients should be stored here in read only memory
;;; ----------------------------------------------------------------------
	.rom0
coefficients			; Unsigned, scaled by 8
	.dw 0x00e8
	.dw 0x01f8
	.dw 0x03ee
	.dw 0x0765
	.dw 0x0ce8
	.dw 0x14dd
	.dw 0x1f6d
	.dw 0x2c7f
	.dw 0x3bae
	.dw 0x4c50
	.dw 0x5d7f
	.dw 0x6e2d
	.dw 0x7d40
	.dw 0x89a7
	.dw 0x927a
	.dw 0x9711
	.dw 0x9711
	.dw 0x927a
	.dw 0x89a7
	.dw 0x7d40
	.dw 0x6e2d
	.dw 0x5d7f
	.dw 0x4c50
	.dw 0x3bae
	.dw 0x2c7f
	.dw 0x1f6d
	.dw 0x14dd
	.dw 0x0ce8
	.dw 0x0765
	.dw 0x03ee
	.dw 0x01f8
	.dw 0x00e8
	
;;; ----------------------------------------------------------------------
;;; Stack space
;;; ----------------------------------------------------------------------
	.ram1
stackarea
	.skip 100		; Should be plenty enough for a stack in this lab!

	
#include "sanitycheck.asm"

