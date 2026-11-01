	.section	__TEXT,__text,regular,pure_instructions
	.globl	_entry                          ; -- Begin function entry
	.p2align	2
_entry:                                 ; @entry
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #64
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	.cfi_def_cfa_offset 64
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	ldp	q0, q1, [sp, #64]
	ldr	x8, [sp, #96]
	str	x8, [sp, #32]
	stp	q0, q1, [sp]
	bl	_macro
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	add	sp, sp, #64
	ret
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function macro
_macro:                                 ; @macro
	.cfi_startproc
; %bb.0:                                ; %entry
	sub	sp, sp, #256
	.cfi_def_cfa_offset 256
	stp	d15, d14, [sp, #96]             ; 16-byte Folded Spill
	stp	d13, d12, [sp, #112]            ; 16-byte Folded Spill
	stp	d11, d10, [sp, #128]            ; 16-byte Folded Spill
	stp	d9, d8, [sp, #144]              ; 16-byte Folded Spill
	stp	x28, x27, [sp, #160]            ; 16-byte Folded Spill
	stp	x26, x25, [sp, #176]            ; 16-byte Folded Spill
	stp	x24, x23, [sp, #192]            ; 16-byte Folded Spill
	stp	x22, x21, [sp, #208]            ; 16-byte Folded Spill
	stp	x20, x19, [sp, #224]            ; 16-byte Folded Spill
	stp	x29, x30, [sp, #240]            ; 16-byte Folded Spill
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_offset b8, -104
	.cfi_offset b9, -112
	.cfi_offset b10, -120
	.cfi_offset b11, -128
	.cfi_offset b12, -136
	.cfi_offset b13, -144
	.cfi_offset b14, -152
	.cfi_offset b15, -160
	stp	x2, x0, [sp, #56]               ; 16-byte Folded Spill
	smstart	sm
	smstart	za
	cmp	x5, #1
	ccmp	x4, #1, #8, ge
	b.lt	LBB1_18
; %bb.1:                                ; %jploop.preheader
	ldp	x10, x8, [sp, #264]
	lsl	x13, x1, #4
	ldp	x9, x14, [sp, #280]
	lsl	x26, x7, #3
	ldr	x11, [sp, #256]
	ldr	x0, [sp, #64]                   ; 8-byte Reload
	lsl	x17, x1, #3
	lsl	x10, x10, #3
	ptrue	p0.d
	mov	x30, x6
	stp	x13, x14, [sp, #32]             ; 16-byte Folded Spill
	lsl	x13, x8, #3
	lsl	x8, x1, #7
	lsl	x15, x11, #3
	add	x7, x0, x1, lsl #6
	mov	x28, x3
	mov	x12, xzr
	stp	x8, x10, [sp, #16]              ; 16-byte Folded Spill
	mov	w19, #16                        ; =0x10
	mov	w20, #8                         ; =0x8
	mov	x21, #8                         ; =0x8
	mov	w10, #104                       ; =0x68
	mov	w2, #48                         ; =0x30
	mov	w11, #112                       ; =0x70
	mov	w23, #56                        ; =0x38
	mov	w16, #120                       ; =0x78
	str	x5, [sp, #48]                   ; 8-byte Spill
	b	LBB1_3
LBB1_2:                                 ; %jpend
                                        ;   in Loop: Header=BB1_3 Depth=1
	ldr	x8, [sp, #24]                   ; 8-byte Reload
	ldp	x7, x12, [sp, #80]              ; 16-byte Folded Reload
	ldr	x5, [sp, #48]                   ; 8-byte Reload
	ldr	x0, [sp, #72]                   ; 8-byte Reload
	add	x28, x28, x8
	ldr	x8, [sp, #16]                   ; 8-byte Reload
	cmp	x12, x5
	add	x0, x0, x8
	add	x7, x7, x8
	b.eq	LBB1_18
LBB1_3:                                 ; %jploop
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB1_6 Depth 2
                                        ;       Child Loop BB1_17 Depth 3
                                        ;       Child Loop BB1_9 Depth 3
                                        ;       Child Loop BB1_11 Depth 3
                                        ;       Child Loop BB1_14 Depth 3
	mov	x8, x12
	ldr	x12, [sp, #32]                  ; 8-byte Reload
	mov	x24, xzr
	str	x0, [sp, #72]                   ; 8-byte Spill
	mul	x12, x8, x12
	add	x8, x8, #1
	stp	x7, x8, [sp, #80]               ; 16-byte Folded Spill
	cmp	x8, x5
	ldr	x8, [sp, #40]                   ; 8-byte Reload
	csel	x5, x8, x19, eq
	ldp	x27, x8, [sp, #56]              ; 16-byte Folded Reload
	add	x8, x8, x12, lsl #3
	b	LBB1_6
LBB1_4:                                 ; %tstore_f
                                        ;   in Loop: Header=BB1_6 Depth=2
	add	x24, x8, x24, lsl #7
	mov	w12, wzr
	mov	w14, #72                        ; =0x48
	madd	x3, x1, x14, x24
	mov	w14, #80                        ; =0x50
	st1d	{za0v.d[w12, 0]}, p0, [x24]
	add	x6, x24, x1, lsl #6
	add	x22, x24, x1, lsl #4
	st1d	{za2v.d[w12, 0]}, p0, [x24, x21, lsl #3]
	st1d	{za1v.d[w12, 0]}, p0, [x6]
	st1d	{za3v.d[w12, 0]}, p0, [x6, x21, lsl #3]
	add	x6, x24, x1, lsl #3
	st1d	{za0v.d[w12, 1]}, p0, [x24, x1, lsl #3]
	st1d	{za2v.d[w12, 1]}, p0, [x6, x21, lsl #3]
	madd	x6, x1, x14, x24
	mov	w14, #2                         ; =0x2
	st1d	{za1v.d[w12, 1]}, p0, [x3]
	st1d	{za3v.d[w12, 1]}, p0, [x3, x21, lsl #3]
	mov	w12, #24                        ; =0x18
	mov	w3, #88                         ; =0x58
	madd	x12, x1, x12, x24
	st1d	{za0v.d[w14, 0]}, p0, [x22]
	st1d	{za2v.d[w14, 0]}, p0, [x22, x21, lsl #3]
	madd	x3, x1, x3, x24
	st1d	{za1v.d[w14, 0]}, p0, [x6]
	st1d	{za3v.d[w14, 0]}, p0, [x6, x21, lsl #3]
	mov	w14, #3                         ; =0x3
	add	x6, x24, x1, lsl #5
	st1d	{za0v.d[w14, 0]}, p0, [x12]
	st1d	{za2v.d[w14, 0]}, p0, [x12, x21, lsl #3]
	mov	w12, #96                        ; =0x60
	madd	x12, x1, x12, x24
	st1d	{za1v.d[w14, 0]}, p0, [x3]
	st1d	{za3v.d[w14, 0]}, p0, [x3, x21, lsl #3]
	mov	w14, #40                        ; =0x28
	madd	x3, x1, x14, x24
	mov	w14, #4                         ; =0x4
	st1d	{za0v.d[w14, 0]}, p0, [x6]
	st1d	{za2v.d[w14, 0]}, p0, [x6, x21, lsl #3]
	madd	x6, x1, x10, x24
	st1d	{za1v.d[w14, 0]}, p0, [x12]
	st1d	{za3v.d[w14, 0]}, p0, [x12, x21, lsl #3]
	madd	x12, x1, x2, x24
	mov	w14, #5                         ; =0x5
	st1d	{za0v.d[w14, 0]}, p0, [x3]
	st1d	{za2v.d[w14, 0]}, p0, [x3, x21, lsl #3]
	madd	x3, x1, x11, x24
	st1d	{za1v.d[w14, 0]}, p0, [x6]
	st1d	{za3v.d[w14, 0]}, p0, [x6, x21, lsl #3]
	madd	x6, x1, x23, x24
	mov	w14, #6                         ; =0x6
	st1d	{za0v.d[w14, 0]}, p0, [x12]
	st1d	{za2v.d[w14, 0]}, p0, [x12, x21, lsl #3]
	madd	x12, x1, x16, x24
	st1d	{za1v.d[w14, 0]}, p0, [x3]
	st1d	{za3v.d[w14, 0]}, p0, [x3, x21, lsl #3]
	mov	w14, #7                         ; =0x7
	st1d	{za0v.d[w14, 0]}, p0, [x6]
	st1d	{za2v.d[w14, 0]}, p0, [x6, x21, lsl #3]
	st1d	{za1v.d[w14, 0]}, p0, [x12]
	st1d	{za3v.d[w14, 0]}, p0, [x12, x21, lsl #3]
LBB1_5:                                 ; %ipend
                                        ;   in Loop: Header=BB1_6 Depth=2
	add	x27, x27, x26
	cmp	x25, x4
	add	x0, x0, #128
	add	x7, x7, #128
	mov	x24, x25
	b.eq	LBB1_2
LBB1_6:                                 ; %iploop
                                        ;   Parent Loop BB1_3 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB1_17 Depth 3
                                        ;       Child Loop BB1_9 Depth 3
                                        ;       Child Loop BB1_11 Depth 3
                                        ;       Child Loop BB1_14 Depth 3
	add	x25, x24, #1
	cmp	x25, x4
	csel	x12, x9, x19, eq
	cmp	x5, #16
	ccmp	x12, #16, #0, eq
	b.eq	LBB1_15
; %bb.7:                                ; %tile_e
                                        ;   in Loop: Header=BB1_6 Depth=2
	whilelt	p1.d, xzr, x12
	zero	{za}
	whilelt	p2.d, x20, x12
	cmp	x30, #1
	b.lt	LBB1_10
; %bb.8:                                ; %kloop_e.preheader
                                        ;   in Loop: Header=BB1_6 Depth=2
	mov	x22, x27
	mov	x3, x28
	mov	x6, x30
LBB1_9:                                 ; %kloop_e
                                        ;   Parent Loop BB1_3 Depth=1
                                        ;     Parent Loop BB1_6 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ld1d	{ z0.d }, p1/z, [x22]
	ld1d	{ z1.d }, p2/z, [x22, x21, lsl #3]
	subs	x6, x6, #1
	ldr	z2, [x3]
	ld1d	{ z3.d }, p0/z, [x3, x21, lsl #3]
	add	x3, x3, x13
	add	x22, x22, x15
	fmopa	za0.d, p0/m, p0/m, z0.d, z2.d
	fmopa	za1.d, p0/m, p0/m, z0.d, z3.d
	fmopa	za2.d, p0/m, p0/m, z1.d, z2.d
	fmopa	za3.d, p0/m, p0/m, z1.d, z3.d
	b.ne	LBB1_9
LBB1_10:                                ; %tstore_e
                                        ;   in Loop: Header=BB1_6 Depth=2
	cmp	x5, #8
	mov	x12, xzr
	mov	x6, x0
	csel	x3, x5, x20, lt
LBB1_11:                                ; %stlo
                                        ;   Parent Loop BB1_3 Depth=1
                                        ;     Parent Loop BB1_6 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	st1d	{za0v.d[w12, 0]}, p1, [x6]
	st1d	{za2v.d[w12, 0]}, p2, [x6, x21, lsl #3]
	add	x12, x12, #1
	add	x6, x6, x17
	cmp	x12, x3
	b.lt	LBB1_11
; %bb.12:                               ; %stmid
                                        ;   in Loop: Header=BB1_6 Depth=2
	cmp	x5, #9
	b.lt	LBB1_5
; %bb.13:                               ; %sthi.preheader
                                        ;   in Loop: Header=BB1_6 Depth=2
	mov	x12, x7
	mov	w3, #8                          ; =0x8
LBB1_14:                                ; %sthi
                                        ;   Parent Loop BB1_3 Depth=1
                                        ;     Parent Loop BB1_6 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	sub	w14, w3, #8
	add	x3, x3, #1
	st1d	{za1v.d[w14, 0]}, p1, [x12]
	cmp	x3, x5
	st1d	{za3v.d[w14, 0]}, p2, [x12, x21, lsl #3]
	add	x12, x12, x17
	b.lt	LBB1_14
	b	LBB1_5
LBB1_15:                                ; %tile_f
                                        ;   in Loop: Header=BB1_6 Depth=2
	cmp	x30, #1
	zero	{za}
	b.lt	LBB1_4
; %bb.16:                               ; %kloop_f.preheader
                                        ;   in Loop: Header=BB1_6 Depth=2
	mov	x22, x27
	mov	x3, x28
	mov	x6, x30
LBB1_17:                                ; %kloop_f
                                        ;   Parent Loop BB1_3 Depth=1
                                        ;     Parent Loop BB1_6 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ldr	z0, [x22]
	ld1d	{ z1.d }, p0/z, [x22, x21, lsl #3]
	subs	x6, x6, #1
	ldr	z2, [x3]
	ld1d	{ z3.d }, p0/z, [x3, x21, lsl #3]
	add	x3, x3, x13
	add	x22, x22, x15
	fmopa	za0.d, p0/m, p0/m, z0.d, z2.d
	fmopa	za1.d, p0/m, p0/m, z0.d, z3.d
	fmopa	za2.d, p0/m, p0/m, z1.d, z2.d
	fmopa	za3.d, p0/m, p0/m, z1.d, z3.d
	b.ne	LBB1_17
	b	LBB1_4
LBB1_18:                                ; %done
	smstop	za
	smstop	sm
	ldp	x29, x30, [sp, #240]            ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #224]            ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #208]            ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #192]            ; 16-byte Folded Reload
	ldp	x26, x25, [sp, #176]            ; 16-byte Folded Reload
	ldp	x28, x27, [sp, #160]            ; 16-byte Folded Reload
	ldp	d9, d8, [sp, #144]              ; 16-byte Folded Reload
	ldp	d11, d10, [sp, #128]            ; 16-byte Folded Reload
	ldp	d13, d12, [sp, #112]            ; 16-byte Folded Reload
	ldp	d15, d14, [sp, #96]             ; 16-byte Folded Reload
	add	sp, sp, #256
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	.cfi_restore b8
	.cfi_restore b9
	.cfi_restore b10
	.cfi_restore b11
	.cfi_restore b12
	.cfi_restore b13
	.cfi_restore b14
	.cfi_restore b15
	ret
	.cfi_endproc
                                        ; -- End function
.subsections_via_symbols
