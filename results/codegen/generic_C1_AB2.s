	sub	sp, sp, #144
	stp	d9, d8, [sp, #32]
	stp	x28, x27, [sp, #48]
	stp	x26, x25, [sp, #64]
	stp	x24, x23, [sp, #80]
	stp	x22, x21, [sp, #96]
	stp	x20, x19, [sp, #112]
	stp	x29, x30, [sp, #128]
	add	x29, sp, #128
	str	w0, [sp, #20]
	ldr	x28, [x29, #40]
	ldr	x8, [x20, #16]
	ldr	x8, [x8, #16]
	ldr	xzr, [x8]
	cmp	x5, #1
	b.lt	L464
	mov	x19, x7
	fmov	d8, d0
	mov	x25, x4
	mov	x21, x2
	mov	x22, x1
	str	x6, [sp, #8]
	bic	x30, x5, x5, asr #63
	bic	x24, x4, x4, asr #63
	cmp	x4, #1
	b.lt	L444
	ldr	x26, [x28]
	ldr	x8, [x28, #16]
	fcmp	d1, #0.0
	lsl	x9, x24, #3
	str	x9, [sp, #24]
	lsl	x23, x8, #3
	b.eq	L408
	mov	x9, #0
	mov	x10, #0
	sub	x11, x30, #1
	madd	x11, x8, x11, x24
	add	x11, x26, x11, lsl #3
	and	x12, x24, #0x7ffffffffffffff8
	orr	x13, x12, #0x1
	add	x14, x26, #32
	add	x15, x24, #1
	sub	x16, x26, #8
	lsl	x17, x8, #61
	mov	x0, #2305843009213693952
	mov	w1, #1
	b	L224
L188:
	add	x2, x1, #1
	add	x10, x10, #1
	add	x9, x9, #8
	add	x14, x14, x23
	add	x17, x17, x8
	add	x0, x0, #1
	cmp	x1, x30
	mov	x1, x2
	b.eq	L444
L224:
	ldr	x2, [x28, #16]
	ldr	x3, [x28]
	cmp	x25, #8
	b.ge	L248
	mov	w6, #1
	b	L360
L248:
	and	x4, x8, #0x1000000000000000
	mul	x5, x10, x2
	add	x5, x3, x5, lsl #3
	ldr	x6, [sp, #24]
	add	x6, x5, x6
	cmp	x5, x11
	ccmp	x26, x6, #2, lo
	ccmp	x4, #0, #0, hs
	b.eq	L292
	mov	w6, #1
	b	L360
L292:
	madd	x4, x2, x9, x3
	add	x4, x4, #32
	mov	x5, x14
	mov	x6, x12
L308:
	ldp	q0, q2, [x4, #-32]
	ldp	q3, q4, [x4], #64
	fmul.2d	v0, v0, v1[0]
	fmul.2d	v2, v2, v1[0]
	fmul.2d	v3, v3, v1[0]
	fmul.2d	v4, v4, v1[0]
	stp	q0, q2, [x5, #-32]
	stp	q3, q4, [x5], #64
	subs	x6, x6, #8
	b.ne	L308
	mov	x6, x13
	cmp	x24, x12
	b.eq	L188
L360:
	sub	x4, x15, x6
	add	x5, x6, x17
	add	x5, x16, x5, lsl #3
	madd	x2, x2, x0, x6
	add	x2, x3, x2, lsl #3
	sub	x2, x2, #8
L384:
	ldr	d0, [x2], #8
	fmul	d0, d1, d0
	str	d0, [x5], #8
	subs	x4, x4, #1
	b.ne	L384
	b	L188
L408:
	mov	x20, x30
L412:
	mov	x0, x26
	ldr	x1, [sp, #24]
	mov	x27, x30
	bl	0x32c
	mov	x30, x27
	add	x26, x26, x23
	subs	x20, x20, #1
	b.ne	L412
L444:
	fcmp	d8, #0.0
	ldr	x15, [sp, #8]
	ccmp	x15, #1, #8, ne
	ccmp	x25, #1, #8, ge
	b.ge	L504
L464:
	mov	x0, x28
	ldp	x29, x30, [sp, #128]
	ldp	x20, x19, [sp, #112]
	ldp	x22, x21, [sp, #96]
	ldp	x24, x23, [sp, #80]
	ldp	x26, x25, [sp, #64]
	ldp	x28, x27, [sp, #48]
	ldp	d9, d8, [sp, #32]
	add	sp, sp, #144
	ret
L504:
	mov	x8, #0
	ldp	x13, x9, [x29, #24]
	mov	w11, #1
	mov	x10, #2305843009213693950
	mov	x12, #2305843009213693951
	ldr	x14, [x29, #16]
	bic	x15, x15, x15, asr #63
	b	L556
L536:
	add	x16, x11, #1
	add	x8, x8, #8
	cmp	x11, x30
	mov	x11, x16
	b.eq	L464
L556:
	ldp	x17, x16, [x13, #8]
	ldr	x1, [x13, #32]
	ldr	x0, [x9]
	add	x1, x1, x10
	add	x2, x1, x11
	add	x3, x11, x12
	madd	x3, x16, x3, x17
	ldr	x5, [x28, #16]
	ldr	x6, [x28]
	ldr	x4, [x0]
	sub	x4, x4, #8
	madd	x5, x5, x8, x6
	ldr	w6, [sp, #20]
	tbz	w6, #0, L808
	mov	x6, #2305843009213693952
	mov	w7, #1
	b	L644
L624:
	add	x20, x7, #1
	add	x6, x6, #1
	cmp	x7, x15
	mov	x7, x20
	b.eq	L536
L644:
	tbz	w22, #0, L664
	ldr	x20, [x0, #16]
	add	x23, x7, x1
	madd	x20, x20, x23, x3
	b	L680
L664:
	add	x20, x7, x12
	madd	x20, x16, x20, x17
	ldr	x23, [x0, #16]
	madd	x20, x23, x2, x20
L680:
	ldr	d0, [x4, x20, lsl #3]
	fmul	d0, d8, d0
	ldp	x27, x23, [x19, #8]
	ldr	x25, [x19, #32]
	ldr	x20, [x14]
	ldr	x26, [x20, #16]
	ldr	x20, [x20]
	madd	x27, x23, x6, x27
	lsl	x23, x26, #3
	sub	x25, x25, #1
	madd	x25, x26, x25, x27
	add	x20, x20, x25, lsl #3
	sub	x25, x20, #8
	mov	x26, x5
	mov	x27, x24
	tbz	w21, #0, L776
L744:
	ldr	d1, [x25]
	ldr	d2, [x26]
	fmadd	d1, d0, d1, d2
	str	d1, [x26], #8
	add	x25, x25, x23
	subs	x27, x27, #1
	b.ne	L744
	b	L624
L776:
	ldr	d1, [x25]
	ldr	d2, [x26]
	fmadd	d1, d0, d1, d2
	str	d1, [x26], #8
	add	x25, x25, x23
	subs	x27, x27, #1
	b.ne	L776
	b	L624
L808:
	mov	x6, #2305843009213693951
	mov	w7, #1
L816:
	tbz	w22, #0, L836
	ldr	x20, [x0, #16]
	add	x23, x7, x1
	madd	x20, x20, x23, x3
	b	L852
L836:
	add	x20, x7, x12
	madd	x20, x16, x20, x17
	ldr	x23, [x0, #16]
	madd	x20, x23, x2, x20
L852:
	ldr	d0, [x4, x20, lsl #3]
	ldp	x23, x20, [x19, #8]
	ldr	x25, [x19, #32]
	ldr	x26, [x14]
	ldr	x27, [x26, #16]
	ldr	x26, [x26]
	add	x25, x25, x6
	madd	x23, x27, x25, x23
	add	x23, x26, x23, lsl #3
	fmul	d0, d8, d0
	sub	x23, x23, #8
	lsl	x25, x20, #3
	mov	x26, x5
	mov	x27, x24
L908:
	ldr	d1, [x23]
	ldr	d2, [x26]
	fmadd	d1, d0, d1, d2
	str	d1, [x26], #8
	add	x23, x23, x25
	subs	x27, x27, #1
	b.ne	L908
	add	x20, x7, #1
	add	x6, x6, #1
	cmp	x7, x15
	mov	x7, x20
	b.ne	L816
	b	L536
