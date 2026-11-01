	stp	x28, x27, [sp, #-96]!
	stp	x26, x25, [sp, #16]
	stp	x24, x23, [sp, #32]
	stp	x22, x21, [sp, #48]
	stp	x20, x19, [sp, #64]
	stp	x29, x30, [sp, #80]
	add	x29, sp, #80
	ldp	x10, x9, [x29, #32]
	ldr	x11, [x20, #16]
	ldr	x11, [x11, #16]
	ldr	xzr, [x11]
	cmp	x6, #1
	b.lt	L852
	bic	x11, x6, x6, asr #63
	bic	x12, x5, x5, asr #63
	cmp	x5, #1
	b.lt	L228
	ldp	x20, x22, [x10, #8]
	ldr	x6, [x10, #32]
	ldr	x13, [x9]
	ldr	x15, [x13]
	ldr	x19, [x13, #16]
	fcmp	d1, #0.0
	lsl	x13, x19, #3
	lsl	x14, x22, #3
	b.eq	L904
	sub	x16, x6, #1
	madd	x16, x19, x16, x20
	add	x15, x15, x16, lsl #3
	sub	x15, x15, #8
	mov	x16, #2305843009213693951
	mov	w17, #1
L128:
	ldp	x6, x19, [x10, #8]
	ldr	x20, [x10, #32]
	ldr	x21, [x9]
	ldr	x22, [x21, #16]
	ldr	x21, [x21]
	add	x20, x20, x16
	madd	x6, x22, x20, x6
	add	x6, x21, x6, lsl #3
	sub	x6, x6, #8
	lsl	x19, x19, #3
	mov	x20, x15
	mov	x21, x12
L176:
	ldr	d2, [x6]
	fmul	d2, d1, d2
	str	d2, [x20]
	add	x20, x20, x14
	add	x6, x6, x19
	subs	x21, x21, #1
	b.ne	L176
	add	x6, x17, #1
	add	x15, x15, x13
	add	x16, x16, #1
	cmp	x17, x11
	mov	x17, x6
	b.ne	L128
L228:
	fcmp	d0, #0.0
	b.eq	L852
	cmp	x7, #1
	b.lt	L852
	cmp	x5, #1
	b.lt	L852
	ldp	x14, x13, [x29, #16]
	mov	x15, #4611686018427387903
	mov	w17, #1
	mov	x16, #2305843009213693951
	bic	x5, x7, x7, asr #63
	b	L296
L276:
	add	x6, x17, #1
	add	x15, x15, #1
	cmp	x17, x11
	mov	x17, x6
	b.eq	L852
L296:
	ldr	x7, [x13, #16]
	add	x6, x17, x16
	mul	x19, x7, x6
	ldr	x6, [x13]
	sub	x6, x6, #8
	ldp	x21, x22, [x10, #8]
	ldr	x25, [x10, #32]
	ldr	x20, [x9]
	ldr	x24, [x20, #16]
	ldr	x23, [x20]
	tbz	w1, #0, L528
	mov	x20, #0
	add	x25, x25, x15
	madd	x21, x24, x25, x21
	add	x21, x23, x21, lsl #3
	sub	x21, x21, #8
	lsl	x22, x22, #3
	mov	w23, #1
	b	L392
L372:
	add	x24, x23, #1
	add	x20, x20, #8
	cmp	x23, x5
	mov	x23, x24
	b.eq	L276
L392:
	sub	x24, x23, #1
	madd	x24, x7, x24, x17
	add	x25, x19, x23
	tst	w2, #0x1
	csel	x24, x24, x25, ne
	ldr	d1, [x6, x24, lsl #3]
	fmul	d1, d0, d1
	ldr	x24, [x14, #16]
	ldr	x25, [x14]
	lsl	x24, x24, #3
	tbz	w3, #0, L480
	mov	x26, x21
	mov	x27, x12
L444:
	ldr	d2, [x25, x20]
	ldr	d3, [x26]
	fmadd	d2, d1, d2, d3
	str	d2, [x26]
	add	x26, x26, x22
	add	x25, x25, x24
	subs	x27, x27, #1
	b.ne	L444
	b	L372
L480:
	add	x25, x25, x20
	mov	x26, x21
	mov	x27, x12
L492:
	ldr	d2, [x25]
	ldr	d3, [x26]
	fmadd	d2, d1, d2, d3
	str	d2, [x26]
	add	x26, x26, x22
	add	x25, x25, x24
	subs	x27, x27, #1
	b.ne	L492
	b	L372
L528:
	tbz	w2, #0, L740
	mov	x19, #0
	add	x20, x25, x15
	madd	x20, x24, x20, x21
	add	x20, x23, x20, lsl #3
	sub	x20, x20, #8
	lsl	x21, x22, #3
	mov	w22, #1
	tbz	w4, #0, L652
L564:
	sub	x23, x22, #1
	madd	x23, x7, x23, x17
	ldr	d1, [x6, x23, lsl #3]
	fmul	d1, d0, d1
	ldr	x23, [x14, #16]
	ldr	x24, [x14]
	madd	x23, x23, x19, x24
	mov	x24, x20
	mov	x25, x12
L600:
	ldr	d2, [x23], #8
	ldr	d3, [x24]
	fmadd	d2, d1, d2, d3
	str	d2, [x24]
	add	x24, x24, x21
	subs	x25, x25, #1
	b.ne	L600
	add	x23, x22, #1
	add	x19, x19, #8
	cmp	x22, x5
	mov	x22, x23
	b.ne	L564
	b	L276
L652:
	sub	x23, x22, #1
	madd	x23, x7, x23, x17
	ldr	d1, [x6, x23, lsl #3]
	fmul	d1, d0, d1
	ldr	x23, [x14, #16]
	ldr	x24, [x14]
	madd	x23, x23, x19, x24
	mov	x24, x20
	mov	x25, x12
L688:
	ldr	d2, [x23], #8
	ldr	d3, [x24]
	fmadd	d2, d1, d2, d3
	str	d2, [x24]
	add	x24, x24, x21
	subs	x25, x25, #1
	b.ne	L688
	add	x23, x22, #1
	add	x19, x19, #8
	cmp	x22, x5
	mov	x22, x23
	b.ne	L652
	b	L276
L740:
	mov	x7, #0
	add	x20, x25, x15
	madd	x20, x24, x20, x21
	add	x20, x23, x20, lsl #3
	sub	x20, x20, #8
	lsl	x21, x22, #3
	mov	w22, #1
L768:
	add	x23, x19, x22
	ldr	d1, [x6, x23, lsl #3]
	fmul	d1, d0, d1
	ldr	x23, [x14, #16]
	ldr	x24, [x14]
	madd	x23, x23, x7, x24
	mov	x24, x20
	mov	x25, x12
L800:
	ldr	d2, [x23], #8
	ldr	d3, [x24]
	fmadd	d2, d1, d2, d3
	str	d2, [x24]
	add	x24, x24, x21
	subs	x25, x25, #1
	b.ne	L800
	add	x23, x22, #1
	add	x7, x7, #8
	cmp	x22, x5
	mov	x22, x23
	b.ne	L768
	b	L276
L852:
	ldp	q0, q1, [x10]
	stp	q0, q1, [x8]
	ldp	q0, q1, [x10, #32]
	stp	q0, q1, [x8, #32]
	ldr	x8, [x9]
	str	x8, [x0]
	ldp	x29, x30, [sp, #80]
	ldp	x20, x19, [sp, #64]
	ldp	x22, x21, [sp, #48]
	ldp	x24, x23, [sp, #32]
	ldp	x26, x25, [sp, #16]
	ldp	x28, x27, [sp], #96
	ret
L904:
	and	x16, x12, #0x7ffffffffffffffc
	orr	x17, x16, #0x1
	mov	x21, #4611686018427387903
	add	x6, x6, x21
	mul	x21, x19, x6
	lsl	x6, x21, #3
	add	x6, x6, x20, lsl #3
	lsl	x19, x22, #5
	lsl	x23, x22, #1
	add	x24, x20, x21
	add	x21, x24, x23
	add	x20, x23, x22
	add	x20, x24, x20
	lsl	x20, x20, #3
	sub	x20, x20, #8
	lsl	x21, x21, #3
	sub	x21, x21, #8
	add	x22, x24, x22
	lsl	x22, x22, #3
	sub	x22, x22, #8
	add	x23, x12, #1
	sub	x24, x6, #8
	mov	w26, #1
	mov	x25, #2305843009213693951
	b	L1024
L1004:
	add	x27, x26, #1
	add	x15, x15, x13
	cmp	x26, x11
	mov	x26, x27
	b.eq	L228
L1024:
	cmp	x5, #4
	b.ge	L1040
	mov	w28, #1
	b	L1092
L1040:
	mov	x27, x15
	mov	x28, x16
L1048:
	add	x30, x27, x6
	stur	xzr, [x30, #-8]
	str	xzr, [x27, x22]
	str	xzr, [x27, x21]
	str	xzr, [x27, x20]
	add	x27, x27, x19
	subs	x28, x28, #4
	b.ne	L1048
	mov	x28, x17
	cmp	x12, x16
	b.eq	L1004
L1092:
	sub	x27, x23, x28
	add	x28, x28, x25
	madd	x28, x14, x28, x24
L1104:
	str	xzr, [x15, x28]
	add	x28, x28, x14
	subs	x27, x27, #1
	b.ne	L1104
	b	L1004
