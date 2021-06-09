;APS00000063000000630000006300000063000000630000006300000063000000630000006300000063
	IFND	_LVORawPutChar
_LVORawPutChar	EQU -516
	ENDC
	IFND	_LVORawDoFmt
_LVORawDoFmt	EQU -522
	ENDC

KPutLongLn:	; d0 = the long
	bsr.s	KPutLong
	move.l	d0,-(sp)
	move.b	#$a,d0
	bsr.s	KPutChar
	move.l	(sp)+,d0
	rts

KPutLong:	; d0 = the long
	swap	d0
	bsr.s	KPutWord
	swap	d0
	bsr.s	KPutWord
	rts

KPutWord:	; d0 = the word
	move.l	d0,-(sp)
	asr.w	#8,d0
	bsr.s	KPutChar
	move.l	(sp),d0
	bsr.s	KPutChar
	move.l	(sp)+,d0
	rts

; kprintf.a - KPrintf implementation using ROM routines
; $VER: kprintf.a 37.1 (11.5.96)
; Copyright © 1996 Michael Letowski
KPrintF:
	movem.l	a2-a3/a6,-(sp)		; Save registers
	lea.l	StuffChar(pc),a2	; a2 = put char proc
	move.l	(4).w,a3		; Remember SysBase
	move.l	a3,a6			; Use SysBase
	jsr	_LVORawDoFmt(a6)	; Jump to ROM
	movem.l	(sp)+,a2-a3/a6		; Restore registers
	rts				; Done

StuffChar:
	move.l	a3,a6			; Get SysBase
	jsr	_LVORawPutChar(a6)	; Use serial I/O to stuff chars
	rts

KPutChar:
	movem.l	d0-a6,-(sp)
	move.l	(4).w,a6
	jsr	_LVORawPutChar(a6)
	movem.l	(sp)+,d0-a6
	rts

test_debug:
	movem.l	d0-a6,-(sp)

	tst.l	(ReqToolsbase-DT,a4)
	bne.b	.reqopen
	jsr	(openreqtoolslib).l
.reqopen:
	tst.l	(ReqToolsbase-DT,a4)
	beq.b	.reqerror


	move.l	a0,-(sp)
	lea	.regsbase+4*16(pc),a0
	movem.l	d0-a7,-(a0)
	move.l	(sp)+,d0
	move.l	d0,.regsbase+4*8

	lea	regstxt+4(pc),a0
	lea	.regsbase,a1
	moveq.l	#16-1,d7
.lopje:
	move.l	(a1)+,d0
	bsr	decode
	lea	5(a0),a0
	dbf	d7,.lopje

	addq.l	#1,a0
	lea	.regsbase+8*4,a1
	moveq.l	#8-1,d7
.lopje2:
	move.l	(a1)+,a2
	bsr	decode2
	lea	6(a0),a0
	dbf	d7,.lopje2

	move.l	#1,(RequesterType).l
	lea	(_Ok_Ok.MSG).l,a2
	lea	regstxt,a1
	jsr	(ShowReqtoolsRequester).l
.reqerror
	movem.l	(sp)+,d0-a6
	rts


.regsbase:
	dcb.l	16,0


decode2:
	moveq.l	#20-1,d6
.lopje
	move.b	(a2)+,d0
	cmp.b	#' ',d0
	blo.s	.nietleesbaar
	cmp.b	#$7e,d0
	bhi.s	.nietleesbaar
	move.b	d0,(a0)+
	bra.b	.verder
.nietleesbaar:
	move.b	#'.',(a0)+
.verder
	dbf	d6,.lopje
	rts

decode:
	swap	d0
	bsr.b	.een
	swap	d0
.een:
	move	d0,-(sp)
	lsr.w	#8,d0
	bsr.b	.twee
	move	(sp)+,d0
.twee:
	move.b	d0,-(sp)
	lsr.b	#4,d0
	bsr.b	.drie
	move.b	(sp)+,d0
.drie:
	and.b	#15,d0
	add.b	#'0',d0
	cmp.b	#'9',d0
	bls.s	.dec
	addq.b	#7,d0
.dec
	move.b	d0,(a0)+
	rts

regstxt:
	dc.b	"D0: xxxxxxxx D1: xxxxxxxx",$a
	dc.b	"D2: xxxxxxxx D3: xxxxxxxx",$a
	dc.b	"D4: xxxxxxxx D5: xxxxxxxx",$a
	dc.b	"D6: xxxxxxxx D7: xxxxxxxx",$a
	dc.b	"A0: xxxxxxxx A1: xxxxxxxx",$a
	dc.b	"A2: xxxxxxxx A3: xxxxxxxx",$a
	dc.b	"A4: xxxxxxxx A5: xxxxxxxx",$a
	dc.b	"A6: xxxxxxxx sp: xxxxxxxx",$a

	dc.b	"(A0):....................",$a
	dc.b	"(A1):....................",$a
	dc.b	"(A2):....................",$a
	dc.b	"(A3):....................",$a
	dc.b	"(A4):....................",$a
	dc.b	"(A5):....................",$a
	dc.b	"(A6):....................",$a
	dc.b	"(sp):....................",$a
	dc.b	0
	even

