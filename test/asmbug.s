;; It's caused by the move.b ([StackPtr]),\1 line in MACRO PullFromStackW.
;; You have discovered yet another ASM-One/Pro MACRO bug, there are MANY more!

PushToStack:	MACRO
		move.b	\1,([StackPtr])
		subq.b	#1,StackPtr+3
		ENDM

PullFromStack:	MACRO
		addq.b	#1,StackPtr+3
		move.b	([StackPtr]),\1
		ENDM

PushToStackW:	MACRO
		move.b	\1,([StackPtr])
		subq.b	#1,StackPtr+3
		lsr.w	#8,\1
		move.b	\1,([StackPtr])
		subq.b	#1,StackPtr+3
		ENDM

PullFromStackW:	MACRO
		addq.b	#1,StackPtr+3
		move.b	([StackPtr]),\1
		lsl.w	#8,\1
		addq.b	#1,StackPtr+3
		move.b	([StackPtr]),\1
	
		ENDM


start:		lea	mem,a0
.loop:		tst.w	a0
		beq.b	done
		addq.l	#1,a0
		bra.b	.loop

done:		move.l	#$100,d0
		move.l	a0,a1
		add.l	d0,a1
		move.l	a1,stackptr

		move.l	#$aabb,d1
		;PushToStackW d1

		;PullFromStackW d2		

		;move.l	#$a0,d1
		;PushToStack d1

		;move.l	#$b0,d1
		;PushToStack d1


		;PullFromStack d2
		;PullFromStack d3

		rts

StackPtr:	dc.l	0


mem:		blk.b	64*1024*2,0
