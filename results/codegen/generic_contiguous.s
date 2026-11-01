	sub	sp, sp, #160
	stp	d9, d8, [sp, #48]
	stp	x28, x27, [sp, #64]
	stp	x26, x25, [sp, #80]
	stp	x24, x23, [sp, #96]
	stp	x22, x21, [sp, #112]
	stp	x20, x19, [sp, #128]
	stp	x29, x30, [sp, #144]
	add	x29, sp, #144
	str	w0, [sp, #16]
	ldr	x0, [x29, #24]
	ldr	x8, [x20, #16]
	ldr	x8, [x8, #16]
	ldr	xzr, [x8]
	cmp	x5, #1
	b.lt	L468
	mov	x19, x7
	fmov	d8, d0
	mov	x21, x4
	mov	x24, x2
	mov	x23, x1
	str	x6, [sp, #24]
	str	w3, [sp, #8]
	bic	x22, x5, x5, asr #63
	bic	x26, x4, x4, asr #63
	cmp	x4, #1
	str	x0, [sp, #40]
	b.lt	L440
	ldr	x27, [x0]
	ldr	x8, [x0, #16]
	fcmp	d1, #0.0
	lsl	x28, x26, #3
	lsl	x25, x8, #3
	b.eq	L408
	mov	x9, #0
	mov	x10, #0
	sub	x11, x22, #1
	madd	x11, x8, x11, x26
	add	x11, x27, x11, lsl #3
	and	x12, x26, #0x7ffffffffffffff8
	orr	x13, x12, #0x1
	add	x14, x27, #32
	add	x15, x26, #1
	sub	x16, x27, #8
	lsl	x17, x8, #61
	mov	x7, #2305843009213693952
	mov	w1, #1
	b	L228
L192:
	add	x2, x1, #1
	add	x10, x10, #1
	add	x9, x9, #8
	add	x14, x14, x25
	add	x17, x17, x8
	add	x7, x7, #1
	cmp	x1, x22
	mov	x1, x2
	b.eq	L440
L228:
	ldr	x2, [x0, #16]
	ldr	x3, [x0]
	cmp	x21, #8
	b.ge	L252
	mov	w6, #1
	b	L360
L252:
	and	x4, x8, #0x1000000000000000
	mul	x5, x10, x2
	add	x5, x3, x5, lsl #3
	add	x6, x5, x28
	cmp	x5, x11
	ccmp	x27, x6, #2, lo
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
	cmp	x26, x12
	b.eq	L192
L360:
	sub	x4, x15, x6
	add	x5, x6, x17
	add	x5, x16, x5, lsl #3
	madd	x2, x2, x7, x6
	add	x2, x3, x2, lsl #3
	sub	x2, x2, #8
L384:
	ldr	d0, [x2], #8
	fmul	d0, d1, d0
	str	d0, [x5], #8
	subs	x4, x4, #1
	b.ne	L384
	b	L192
L408:
	mov	x20, x22
L412:
	mov	x0, x27
	mov	x1, x28
	bl	0x7b4
	ldr	x0, [sp, #40]
	add	x27, x27, x25
	subs	x20, x20, #1
	b.ne	L412
L440:
	str	x22, [sp, #32]
	fcmp	d8, #0.0
	ldr	x8, [sp, #24]
	ccmp	x8, #1, #8, ne
	ccmp	x21, #1, #8, ge
	ldr	w7, [sp, #8]
	b.ge	L504
L468:
	ldp	x29, x30, [sp, #144]
	ldp	x20, x19, [sp, #128]
	ldp	x22, x21, [sp, #112]
	ldp	x24, x23, [sp, #96]
	ldp	x26, x25, [sp, #80]
	ldp	x28, x27, [sp, #64]
	ldp	d9, d8, [sp, #48]
	add	sp, sp, #160
	ret
L504:
	ldr	x6, [x29, #16]
	bic	x9, x8, x8, asr #63
	ldr	w8, [sp, #16]
	tbz	w8, #0, L1016
	mov	x10, #0
	mov	w12, #1
	mov	x11, #2305843009213693951
	b	L556
L536:
	add	x8, x12, #1
	add	x10, x10, #8
	cmp	x12, x5
	mov	x12, x8
	b.eq	L468
L556:
	ldr	x14, [x6, #16]
	add	x8, x12, x11
	mul	x15, x14, x8
	ldr	x8, [x6]
	sub	x13, x8, #8
	ldr	x8, [x0, #16]
	ldr	x17, [x0]
	tbz	w24, #0, L708
	mov	x16, #0
	madd	x17, x8, x10, x17
	mov	w4, #1
	ldr	x5, [sp, #32]
L604:
	sub	x8, x4, #1
	madd	x8, x14, x8, x12
	add	x1, x15, x4
	tst	w23, #0x1
	csel	x8, x8, x1, ne
	ldr	d0, [x13, x8, lsl #3]
	fmul	d0, d8, d0
	ldr	x1, [x19, #16]
	ldr	x8, [x19]
	add	x8, x8, x16
	lsl	x1, x1, #3
	mov	x2, x17
	mov	x3, x26
L656:
	ldr	d1, [x8]
	ldr	d2, [x2]
	fmadd	d1, d0, d1, d2
	str	d1, [x2], #8
	add	x8, x8, x1
	subs	x3, x3, #1
	b.ne	L656
	add	x8, x4, #1
	add	x16, x16, #8
	cmp	x4, x9
	mov	x4, x8
	b.ne	L604
	b	L536
L708:
	ldr	x5, [sp, #32]
	tbz	w23, #0, L916
	mov	x15, #0
	madd	x16, x8, x10, x17
	mov	w17, #1
	tbz	w7, #0, L824
L732:
	sub	x8, x17, #1
	madd	x8, x14, x8, x12
	ldr	d0, [x13, x8, lsl #3]
	fmul	d0, d8, d0
	ldr	x1, [x19, #16]
	ldr	x8, [x19]
	add	x8, x8, x15
	lsl	x3, x1, #3
	mov	x1, x16
	mov	x2, x26
L772:
	ldr	d1, [x8]
	ldr	d2, [x1]
	fmadd	d1, d0, d1, d2
	str	d1, [x1], #8
	add	x8, x8, x3
	subs	x2, x2, #1
	b.ne	L772
	add	x8, x17, #1
	add	x15, x15, #8
	cmp	x17, x9
	mov	x17, x8
	b.ne	L732
	b	L536
L824:
	sub	x8, x17, #1
	madd	x8, x14, x8, x12
	ldr	d0, [x13, x8, lsl #3]
	fmul	d0, d8, d0
	ldr	x1, [x19, #16]
	ldr	x8, [x19]
	add	x8, x8, x15
	lsl	x3, x1, #3
	mov	x1, x16
	mov	x2, x26
L864:
	ldr	d1, [x8]
	ldr	d2, [x1]
	fmadd	d1, d0, d1, d2
	str	d1, [x1], #8
	add	x8, x8, x3
	subs	x2, x2, #1
	b.ne	L864
	add	x8, x17, #1
	add	x15, x15, #8
	cmp	x17, x9
	mov	x17, x8
	b.ne	L824
	b	L536
L916:
	mov	x14, #0
	madd	x16, x8, x10, x17
	mov	w17, #1
L928:
	add	x8, x15, x17
	ldr	d0, [x13, x8, lsl #3]
	fmul	d0, d8, d0
	ldr	x1, [x19, #16]
	ldr	x8, [x19]
	add	x8, x8, x14
	lsl	x3, x1, #3
	mov	x1, x16
	mov	x2, x26
L964:
	ldr	d1, [x8]
	ldr	d2, [x1]
	fmadd	d1, d0, d1, d2
	str	d1, [x1], #8
	add	x8, x8, x3
	subs	x2, x2, #1
	b.ne	L964
	add	x8, x17, #1
	add	x14, x14, #8
	cmp	x17, x9
	mov	x17, x8
	b.ne	L928
	b	L536
L1016:
	sub	x11, x26, #1
	lsl	x10, x26, #3
	lsl	x8, x11, #3
	stp	x8, x6, [sp, #16]
	and	x22, x26, #0x7ffffffffffffff8
	orr	x13, x22, #0x1
	mov	x14, #0
	mov	x15, #0
	add	x16, x26, #1
	mov	x17, #2305843009213693952
	tbz	w23, #0, L1444
	mov	w1, #1
	lsr	x8, x11, #61
	tbz	w7, #0, L1832
	str	x8, [sp, #8]
	b	L1116
L1080:
	add	x8, x1, #1
	add	x15, x15, #1
	add	x14, x14, #8
	add	x17, x17, #1
	ldp	x11, x0, [sp, #32]
	cmp	x1, x11
	mov	x1, x8
	ldr	x6, [sp, #24]
	b.eq	L468
L1116:
	mov	x2, #0
	mov	x3, #0
	ldr	x4, [x6, #16]
	ldr	x8, [x6]
	sub	x5, x8, #8
	ldr	x11, [x0, #16]
	ldr	x12, [x0]
	mul	x8, x15, x11
	add	x6, x12, x8, lsl #3
	add	x7, x6, x10
	ldr	x8, [sp, #16]
	add	x8, x6, x8
	cmp	x8, x6
	ldr	x8, [sp, #8]
	ccmp	x8, #0, #0, hs
	cset	w23, ne
	madd	x8, x11, x14, x12
	add	x8, x8, #32
	sub	x25, x12, #8
	mul	x27, x11, x17
	mov	x28, #2305843009213693952
	mov	w30, #1
	b	L1236
L1208:
	add	x11, x30, #1
	add	x3, x3, #1
	add	x2, x2, #8
	add	x28, x28, #1
	cmp	x30, x9
	mov	x30, x11
	b.eq	L1080
L1236:
	cmp	x21, #8
	cset	w12, lt
	sub	x11, x30, #1
	madd	x11, x4, x11, x1
	ldr	d0, [x5, x11, lsl #3]
	fmul	d0, d8, d0
	ldr	x11, [x19, #16]
	ldr	x0, [x19]
	orr	w12, w12, w23
	tbz	w12, #0, L1284
	mov	w24, #1
	b	L1392
L1284:
	lsl	x12, x3, #3
	madd	x12, x11, x12, x0
	add	x20, x12, x10
	cmp	x6, x20
	ccmp	x12, x7, #2, lo
	b.lo	L1388
	madd	x12, x11, x2, x0
	add	x20, x12, #32
	mov	x24, x8
	mov	x12, x22
L1324:
	ldp	q1, q2, [x20, #-32]
	ldp	q3, q4, [x20], #64
	ldp	q5, q6, [x24, #-32]
	ldp	q7, q16, [x24]
	fmla.2d	v5, v1, v0[0]
	fmla.2d	v6, v2, v0[0]
	fmla.2d	v7, v3, v0[0]
	fmla.2d	v16, v4, v0[0]
	stp	q5, q6, [x24, #-32]
	stp	q7, q16, [x24], #64
	subs	x12, x12, #8
	b.ne	L1324
	mov	x24, x13
	cmp	x26, x22
	b.eq	L1208
	b	L1392
L1388:
	mov	w24, #1
L1392:
	sub	x12, x16, x24
	add	x20, x27, x24
	add	x20, x25, x20, lsl #3
	madd	x11, x11, x28, x24
	add	x11, x0, x11, lsl #3
	sub	x11, x11, #8
L1416:
	ldr	d1, [x11], #8
	ldr	d2, [x20]
	fmadd	d1, d0, d1, d2
	str	d1, [x20], #8
	subs	x12, x12, #1
	b.ne	L1416
	b	L1208
L1444:
	mov	w2, #1
	lsr	x8, x11, #61
	str	x8, [sp, #8]
	b	L1496
L1460:
	add	x8, x2, #1
	add	x15, x15, #1
	add	x14, x14, #8
	add	x17, x17, #1
	ldp	x11, x0, [sp, #32]
	cmp	x2, x11
	mov	x2, x8
	ldr	x6, [sp, #24]
	b.eq	L468
L1496:
	mov	x3, #0
	mov	x4, #0
	ldr	x8, [x6, #16]
	mov	x11, #2305843009213693951
	add	x11, x2, x11
	mul	x5, x8, x11
	ldr	x8, [x6]
	sub	x6, x8, #8
	ldr	x8, [x0, #16]
	ldr	x11, [x0]
	mul	x12, x15, x8
	add	x7, x11, x12, lsl #3
	add	x23, x7, x10
	ldr	x12, [sp, #16]
	add	x12, x7, x12
	cmp	x12, x7
	ldr	x12, [sp, #8]
	ccmp	x12, #0, #0, hs
	cset	w24, ne
	madd	x12, x8, x14, x11
	add	x25, x12, #32
	sub	x27, x11, #8
	mul	x28, x8, x17
	mov	x30, #2305843009213693952
	mov	w1, #1
	b	L1628
L1600:
	add	x8, x1, #1
	add	x4, x4, #1
	add	x3, x3, #8
	add	x30, x30, #1
	cmp	x1, x9
	mov	x1, x8
	b.eq	L1460
L1628:
	cmp	x21, #8
	cset	w8, lt
	add	x11, x5, x1
	ldr	d0, [x6, x11, lsl #3]
	fmul	d0, d8, d0
	ldr	x11, [x19, #16]
	ldr	x0, [x19]
	orr	w8, w8, w24
	tbz	w8, #0, L1672
	mov	w20, #1
	b	L1780
L1672:
	lsl	x8, x4, #3
	madd	x8, x11, x8, x0
	add	x12, x8, x10
	cmp	x7, x12
	ccmp	x8, x23, #2, lo
	b.lo	L1776
	madd	x8, x11, x3, x0
	add	x20, x8, #32
	mov	x8, x25
	mov	x12, x22
L1712:
	ldp	q1, q2, [x20, #-32]
	ldp	q3, q4, [x20], #64
	ldp	q5, q6, [x8, #-32]
	ldp	q7, q16, [x8]
	fmla.2d	v5, v1, v0[0]
	fmla.2d	v6, v2, v0[0]
	fmla.2d	v7, v3, v0[0]
	fmla.2d	v16, v4, v0[0]
	stp	q5, q6, [x8, #-32]
	stp	q7, q16, [x8], #64
	subs	x12, x12, #8
	b.ne	L1712
	mov	x20, x13
	cmp	x26, x22
	b.eq	L1600
	b	L1780
L1776:
	mov	w20, #1
L1780:
	sub	x8, x16, x20
	add	x12, x28, x20
	add	x12, x27, x12, lsl #3
	madd	x11, x11, x30, x20
	add	x11, x0, x11, lsl #3
	sub	x11, x11, #8
L1804:
	ldr	d1, [x11], #8
	ldr	d2, [x12]
	fmadd	d1, d0, d1, d2
	str	d1, [x12], #8
	subs	x8, x8, #1
	b.ne	L1804
	b	L1600
L1832:
	str	x8, [sp, #8]
	b	L1876
L1840:
	add	x8, x1, #1
	add	x15, x15, #1
	add	x14, x14, #8
	add	x17, x17, #1
	ldp	x11, x0, [sp, #32]
	cmp	x1, x11
	mov	x1, x8
	ldr	x6, [sp, #24]
	b.eq	L468
L1876:
	mov	x2, #0
	mov	x3, #0
	ldr	x4, [x6, #16]
	ldr	x8, [x6]
	sub	x5, x8, #8
	ldr	x8, [x0, #16]
	ldr	x11, [x0]
	mul	x12, x15, x8
	add	x6, x11, x12, lsl #3
	add	x7, x6, x10
	ldr	x12, [sp, #16]
	add	x12, x6, x12
	cmp	x12, x6
	ldr	x12, [sp, #8]
	ccmp	x12, #0, #0, hs
	cset	w23, ne
	madd	x12, x8, x14, x11
	add	x24, x12, #32
	sub	x25, x11, #8
	mul	x27, x8, x17
	mov	x28, #2305843009213693952
	mov	w30, #1
	b	L1996
L1968:
	add	x8, x30, #1
	add	x3, x3, #1
	add	x2, x2, #8
	add	x28, x28, #1
	cmp	x30, x9
	mov	x30, x8
	b.eq	L1840
L1996:
	cmp	x21, #8
	cset	w8, lt
	sub	x11, x30, #1
	madd	x11, x4, x11, x1
	ldr	d0, [x5, x11, lsl #3]
	fmul	d0, d8, d0
	ldr	x11, [x19, #16]
	ldr	x0, [x19]
	orr	w8, w8, w23
	tbz	w8, #0, L2044
	mov	w20, #1
	b	L2152
L2044:
	lsl	x8, x3, #3
	madd	x8, x11, x8, x0
	add	x12, x8, x10
	cmp	x6, x12
	ccmp	x8, x7, #2, lo
	b.lo	L2148
	madd	x8, x11, x2, x0
	add	x20, x8, #32
	mov	x8, x24
	mov	x12, x22
L2084:
	ldp	q1, q2, [x20, #-32]
	ldp	q3, q4, [x20], #64
	ldp	q5, q6, [x8, #-32]
	ldp	q7, q16, [x8]
	fmla.2d	v5, v1, v0[0]
	fmla.2d	v6, v2, v0[0]
	fmla.2d	v7, v3, v0[0]
	fmla.2d	v16, v4, v0[0]
	stp	q5, q6, [x8, #-32]
	stp	q7, q16, [x8], #64
	subs	x12, x12, #8
	b.ne	L2084
	mov	x20, x13
	cmp	x26, x22
	b.eq	L1968
	b	L2152
L2148:
	mov	w20, #1
L2152:
	sub	x8, x16, x20
	add	x12, x27, x20
	add	x12, x25, x12, lsl #3
	madd	x11, x11, x28, x20
	add	x11, x0, x11, lsl #3
	sub	x11, x11, #8
L2176:
	ldr	d1, [x11], #8
	ldr	d2, [x12]
	fmadd	d1, d0, d1, d2
	str	d1, [x12], #8
	subs	x8, x8, #1
	b.ne	L2176
	b	L1968
