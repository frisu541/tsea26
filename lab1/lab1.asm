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
	push r0
	push r1

	move r0,ar0
	move r1,ar1
	push r0
	push r1

	move r0,step0
	move r1,step1
	push r0
	push r1

	move r0,bot1
	move r1,top1
	push r0
	push r1

	move r0,acr0
	move r1,mul65536 acr0
	push r0
	push r1

	move r0,guards01
	move r1,loopn
	push r0
	push r1

	move r0,loopb
	move r1,loope
	push r0
	push r1

        ;;;  FIXME - You may want to save other registers here as well.
        ;;; (Alternatively, you might want to save less registers here in order
        ;;; to improve the performance if you can get away with it somehow...)
	
	call fir_kernel

	pop r1
	pop r0
	move loope,r1
	move loopb,r0

	pop r1
	pop r0
	move loopn,r1
	move guards01,r0

	pop r1
	pop r0
	move acr0.l,r1
	move acr0.h,r0

	pop r1
	pop r0
	move top1,r1
	move bot1,r0

	pop r1
	pop r0
	move step1,r1
	move step0,r0
	
	pop r1
	pop r0
	move ar1,r1
	move ar0,r0

	pop r1
	pop r0

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
        ;;; FIXME - You need to implement the rest of this function
	in r0,0x10		; Read input sample -> r0
	set r1,0 		
	
	set step0,1		; Initiate stepsize for coefficients

	st1 (current_location),r0 ; Store sample into ringbuffer at current_location

	move acr0.l, r1 		; Initiate acr0 to zero
	move acr0.h, r1
	move guards01, r1
	
	set step1,1		; Initiate stepsize, top address and bottom address for samples
	set bot1,ringbuffer
	set top1,top_ringbuffer

	
	
	set r0,coefficients  	; Store addresses to coefficients and current location in ringbuffer to ar0 and ar1
	ld0 r1,(current_location)
	move ar0,r0
	move ar1,r1

	repeat conv_tap, 31 	; Repeat 31 taps of convolution
	convss acr0,(ar0++),(ar1++%)
conv_tap
	
	move r1, ar1
	convss acr0,(ar0++),(ar1++%) ; Tap 32 of the convolution
	st0 (current_location), r1 ; Store value of current location for next call to fir_kernel
	nop
	move r0,sat rnd acr0 ; Scaling factor? otherwise 31-16
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
coefficients
	.dw 0x000e
	.dw 0x0020
	.dw 0x003f
	.dw 0x0076
	.dw 0x00cf
	.dw 0x014e
	.dw 0x01f7
	.dw 0x02c8
	.dw 0x03bb
	.dw 0x04c5
	.dw 0x05d8
	.dw 0x06e3
	.dw 0x07d4
	.dw 0x089a
	.dw 0x0928
	.dw 0x0971
	.dw 0x0971
	.dw 0x0928
	.dw 0x089a
	.dw 0x07d4
	.dw 0x06e3
	.dw 0x05d8
	.dw 0x04c5
	.dw 0x03bb
	.dw 0x02c8
	.dw 0x01f7
	.dw 0x014e
	.dw 0x00cf
	.dw 0x0076
	.dw 0x003f
	.dw 0x0020
	.dw 0x000e

	
;;; ----------------------------------------------------------------------
;;; Stack space
;;; ----------------------------------------------------------------------
	.ram1
stackarea
	.skip 100		; Should be plenty enough for a stack in this lab!

	
#include "sanitycheck.asm"

