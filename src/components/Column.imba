import type { Column as IColumn } from '../models.imba'
import Card from './Card.imba'
import CardAdder from './CardAdder.imba'
import State from '../State.imba'

export default tag Column
	data\IColumn

	#hovering = no

	get full?
		return no if State.draggingCard..columnId is data.id and #hovering
		State.isFullColumn(data.id)

	get cards do State.getColumnCards data.id

	get status do State.getColumnSummary data.id

	get length do State.getColumnLength data.id

	get active? do data.status isnt 'closed'

	get empty? do cards.length is 0

	get draggingCardHeight do
		const draggingElement = document.getElementById(State.draggingCardId)

		return 35 if not draggingElement

		const elementRect = draggingElement.getBoundingClientRect!
		elementRect.height

	get color
		return 'indigo1' if data.status is 'current'
		return data.color if data.status is 'open'

		switch status
			when 'completed' then 'emerald1'
			when 'almost' then 'orange1'
			when 'far' then 'orange1'
			when 'none' then 'rose1'
			when 'empty' then 'cool2'
	
	get closedMessage
		return 'Amazing  🤩' if status is 'completed' and length is data.limit
			
		switch status
			when 'completed' then 'Great  😊'
			when 'almost' then 'Almost  😅'
			when 'far' then 'Okay  😐'
			when 'none' then 'My bad  ☹️'
			when 'empty' then 'Oh no  🫣'

	get lengthViewer
		if data.toFill
			"★".repeat(length) + "☆".repeat(data.limit - length)
		else
			"★".repeat(data.limit - length) + "☆".repeat(length)

	def isHoveringBefore card
		#hovering and not full? and card.id is State.hoveringCardId and State.dropIndex is card.index
	
	def isHoveringAfter card
		#hovering and not full? and card.id is State.hoveringCardId and State.dropIndex > card.index

	def dragEnter
		#hovering = yes
		const hoveringCard = State.hoveringCard
		if hoveringCard..columnId isnt data.id
			State.hoveringCardId = null
			State.dropIndex = null

	def drop
		return if not State.hoveringCard? and cards.length isnt 0

		State.dropIndex = 1 if not State.hoveringCard? and cards.length is 0

		const draggingCard = State.draggingCard
		const hoveringCard = State.hoveringCard

		const isDraggingToSameColumn = draggingCard.columnId isnt hoveringCard..columnId

		for card in State.content.cards
			const isFromOriginColumn = card.columnId is draggingCard.columnId
			const isAfterLeavingCard = card.index > draggingCard.index
			const isInThisColumn = card.columnId is data.id
			const isAfterDropIndex = card.index >= State.dropIndex

			if isInThisColumn and isAfterDropIndex
				State.downCard card
			elif isFromOriginColumn and isAfterLeavingCard and isDraggingToSameColumn
				State.upCard card

		State.moveCard draggingCard, data.id
		#hovering = no

	css d:vcc bgc:$color bc:black px:4 py:3 rd:md g:2 bxs:md w:220px tween:all 1s ease
		h2 m:0 c:warm6 cursor:default
		.drop-area d:hcc c:gray5 fw:bold m:0 w:105% bd:1px dashed gray5 rd:lg

	<self [$color:{color}] @dragenter.prevent=dragEnter
		@dragover.if(not full? and active?).prevent
		@drop.prevent=drop
		@dragend=(#hovering = no)>

		css .drop-area h:{draggingCardHeight}px

		<h2> data.title

		<span [c:gray5 mb:2]> lengthViewer

		<global @dragenter.outside=(#hovering = no)>
	
		<.drop-area key="drop-area-empty"> if active? and empty? and #hovering
		
		for card in cards
			<.drop-area key="drop-area-before"> if isHoveringBefore card
			<Card id=card.id key=card.id data=card 
				canMove=(data.canMoveOut and active?) 
				isNegative=(not data.toFill)
				isFullColumn=full?>
			<.drop-area key="drop-area-after"> if isHoveringAfter card

		if active?
			<CardAdder [visibility:hidden]=(not data.canAdd or full? or State.draggingCard?) columnId=data.id>
		else
			<span [d:hcc fs:sm h:30px c:gray5 fw:bold]> closedMessage
