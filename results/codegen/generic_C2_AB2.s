	sub	sp, sp, #128
	stp	x28, x27, [sp, #32]
	stp	x26, x25, [sp, #48]
	stp	x24, x23, [sp, #64]
	stp	x22, x21, [sp, #80]
	stp	x20, x19, [sp, #96]
	stp	x29, x30, [sp, #112]
	add	x29, sp, #112
	str	w1, [sp, #28]
	stp	x8, x0, [sp]
	ldp	x10, x1, [x29, #48]
	ldr	x8, [x20, #16]
	ldr	x8, [x8, #16]
	ldr	xzr, [x8]
	cmp	x6, #1
	b.lt	L788
	bic	x11, x6, x6, asr #63
	bic	x9, x5, x5, asr #63
	cmp	x5, #1
	b.lt	L240
	ldp	x8, x0, [x10, #8]
	ldr	x16, [x10, #32]
	ldr	x12, [x1]
	ldr	x13, [x12]
	ldr	x12, [x12, #16]
	fcmp	d1, #0.0
	b.eq	L848
	sub	x14, x16, #1
	madd	x8, x12, x14, x8
	add	x8, x13, x8, lsl #3
	sub	x13, x8, #8
	lsl	x14, x12, #3
	lsl	x15, x0, #3
	mov	x16, #2305843009213693951
	mov	w17, #1
L140:
	ldp	x8, x12, [x10, #8]
	ldr	x0, [x10, #32]
	ldr	x4, [x1]
	ldr	x6, [x4, #16]
	ldr	x4, [x4]
	add	x0, x0, x16
	madd	x8, x6, x0, x8
	add	x8, x4, x8, lsl #3
	sub	x8, x8, #8
	lsl	x0, x12, #3
	mov	x12, x13
	mov	x4, x9
L188:
	ldr	d2, [x8]
	fmul	d2, d1, d2
	str	d2, [x12]
	add	x12, x12, x15
	add	x8, x8, x0
	subs	x4, x4, #1
	b.ne	L188
	add	x8, x17, #1
	add	x13, x13, x14
	add	x16, x16, #1
	cmp	x17, x11
	mov	x17, x8
	b.ne	L140
L240:
	fcmp	d0, #0.0
	b.eq	L788
	cmp	x7, #1
	b.lt	L788
	cmp	x5, #1
	b.lt	L788
	ldr	x8, [x29, #40]
	str	x8, [sp, #16]
	ldp	x6, x14, [x29, #24]
	mov	x15, #4611686018427387903
	mov	w17, #1
	mov	x4, #2305843009213693951
	bic	x5, x7, x7, asr #63
	ldr	x7, [x29, #16]
	b	L320
L300:
	add	x8, x17, #1
	add	x15, x15, #1
	cmp	x17, x11
	mov	x17, x8
	b.eq	L788
L320:
	ldp	x20, x19, [x14, #8]
	ldr	x8, [x14, #32]
	ldr	x12, [sp, #16]
	ldr	x21, [x12]
	mov	x12, #2305843009213693950
	add	x22, x8, x12
	add	x23, x22, x17
	add	x8, x17, x4
	madd	x24, x19, x8, x20
	ldp	x8, x13, [x10, #8]
	ldr	x16, [x10, #32]
	ldr	x12, [x1]
	ldr	x0, [x12, #16]
	ldr	x12, [x12]
	ldr	x25, [x21]
	sub	x25, x25, #8
	lsl	x26, x13, #3
	ldr	w13, [sp, #28]
	tbz	w13, #0, L616
	add	x13, x16, x15
	madd	x8, x0, x13, x8
	add	x8, x12, x8, lsl #3
	sub	x8, x8, #8
	mov	x28, #2305843009213693952
	mov	w30, #1
	b	L444
L424:
	add	x12, x30, #1
	add	x28, x28, #1
	cmp	x30, x5
	mov	x30, x12
	b.eq	L300
L444:
	tbz	w2, #0, L464
	ldr	x12, [x21, #16]
	add	x13, x30, x22
	madd	x12, x12, x13, x24
	b	L480
L464:
	add	x12, x30, x4
	madd	x12, x19, x12, x20
	ldr	x13, [x21, #16]
	madd	x12, x13, x23, x12
L480:
	ldr	d1, [x25, x12, lsl #3]
	fmul	d1, d0, d1
	ldp	x16, x13, [x7, #8]
	ldr	x0, [x7, #32]
	ldr	x12, [x6]
	ldr	x27, [x12, #16]
	ldr	x12, [x12]
	madd	x13, x13, x28, x16
	lsl	x16, x27, #3
	sub	x0, x0, #1
	madd	x13, x27, x0, x13
	add	x12, x12, x13, lsl #3
	sub	x0, x12, #8
	mov	x27, x8
	mov	x12, x9
	tbz	w3, #0, L580
L544:
	ldr	d2, [x0]
	ldr	d3, [x27]
	fmadd	d2, d1, d2, d3
	str	d2, [x27]
	add	x27, x27, x26
	add	x0, x0, x16
	subs	x12, x12, #1
	b.ne	L544
	b	L424
L580:
	ldr	d2, [x0]
	ldr	d3, [x27]
	fmadd	d2, d1, d2, d3
	str	d2, [x27]
	add	x27, x27, x26
	add	x0, x0, x16
	subs	x12, x12, #1
	b.ne	L580
	b	L424
L616:
	add	x13, x16, x15
	madd	x8, x0, x13, x8
	add	x8, x12, x8, lsl #3
	sub	x27, x8, #8
	mov	x28, #2305843009213693951
	mov	w30, #1
L640:
	tbz	w2, #0, L660
	ldr	x8, [x21, #16]
	add	x12, x30, x22
	madd	x8, x8, x12, x24
	b	L676
L660:
	add	x8, x30, x4
	madd	x8, x19, x8, x20
	ldr	x12, [x21, #16]
	madd	x8, x12, x23, x8
L676:
	ldr	d1, [x25, x8, lsl #3]
	ldp	x12, x8, [x7, #8]
	ldr	x13, [x7, #32]
	ldr	x16, [x6]
	ldr	x0, [x16, #16]
	ldr	x16, [x16]
	add	x13, x13, x28
	madd	x12, x0, x13, x12
	add	x12, x16, x12, lsl #3
	fmul	d1, d0, d1
	sub	x16, x12, #8
	lsl	x0, x8, #3
	mov	x8, x27
	mov	x12, x9
L732:
	ldr	d2, [x16]
	ldr	d3, [x8]
	fmadd	d2, d1, d2, d3
	str	d2, [x8]
	add	x8, x8, x26
	add	x16, x16, x0
	subs	x12, x12, #1
	b.ne	L732
	add	x8, x30, #1
	add	x28, x28, #1
	cmp	x30, x5
	mov	x30, x8
	b.ne	L640
	b	L300
L788:
	ldp	q0, q1, [x10]
	ldp	x8, x9, [sp]
	stp	q0, q1, [x8]
	ldp	q0, q1, [x10, #32]
	stp	q0, q1, [x8, #32]
	ldr	x8, [x1]
	str	x8, [x9]
	ldp	x29, x30, [sp, #112]
	ldp	x20, x19, [sp, #96]
	ldp	x22, x21, [sp, #80]
	ldp	x24, x23, [sp, #64]
	ldp	x26, x25, [sp, #48]
	ldp	x28, x27, [sp, #32]
	add	sp, sp, #128
	ret
L848:
	and	x14, x9, #0x7ffffffffffffffc
	orr	x15, x14, #0x1
	mov	x17, #4611686018427387903
	add	x16, x16, x17
	mul	x6, x12, x16
	lsl	x16, x6, #3
	add	x16, x16, x8, lsl #3
	lsl	x17, x12, #3
	lsl	x4, x0, #5
	lsl	x12, x0, #1
	add	x8, x8, x6
	add	x19, x8, x12
	add	x12, x12, x0
	add	x12, x8, x12
	lsl	x12, x12, #3
	sub	x6, x12, #8
	lsl	x12, x19, #3
	sub	x19, x12, #8
	add	x8, x8, x0
	lsl	x8, x8, #3
	sub	x20, x8, #8
	add	x21, x9, #1
	sub	x22, x16, #8
	lsl	x23, x0, #3
	mov	w25, #1
	mov	x24, #2305843009213693951
	b	L976
L956:
	add	x8, x25, #1
	add	x13, x13, x17
	cmp	x25, x11
	mov	x25, x8
	b.eq	L240
L976:
	cmp	x5, #4
	b.ge	L992
	mov	w12, #1
	b	L1044
L992:
	mov	x8, x13
	mov	x12, x14
L1000:
	add	x0, x8, x16
	stur	xzr, [x0, #-8]
	str	xzr, [x8, x20]
	str	xzr, [x8, x19]
	str	xzr, [x8, x6]
	add	x8, x8, x4
	subs	x12, x12, #4
	b.ne	L1000
	mov	x12, x15
	cmp	x9, x14
	b.eq	L956
L1044:
	sub	x8, x21, x12
	add	x12, x12, x24
	madd	x12, x23, x12, x22
L1056:
	str	xzr, [x13, x12]
	add	x12, x12, x23
	subs	x8, x8, #1
	b.ne	L1056
	b	L956
