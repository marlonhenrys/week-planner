import type {Card as ICard} from '../models.imba'
import CardOptions from './CardOptions.imba'
import State from '../State.imba'
import trashIcon from '../assets/trash-icon.png'
import doneIcon from '../assets/done-icon.png'
import undoneIcon from '../assets/undone-icon.png'
import movedIcon from '../assets/moved-icon.png'

export default tag Card
	data\ICard
	canMove\boolean
	isNegative\boolean
	isFullColumn\boolean

	#dragging = no
	#dndBlocked = no

	get pending? do data.status is 'pending'

	def hideOptions
		self.lastElementChild.flags.add('hidden')

	def showOptions
		self.lastElementChild.flags.remove('hidden')

	def rendered do showOptions!

	def checkPointer event\PointerEvent
		#dndBlocked = event.pointerType isnt 'mouse'

	def dragStart
		if not #dndBlocked
			hideOptions!
			State.draggingCardId = data.id
			#dragging = yes

	def dragEnd
		State.draggingCardId = null
		State.hoveringCardId = null
		State.dropIndex = null
		#dragging = no

	def dragOver event\DragEvent
		return if State.draggingCardId is data.id

		const hoveringSize = self.getBoundingClientRect!
		const hoveringCenter = (hoveringSize.bottom - hoveringSize.top) / 2
		const draggedTop = event.clientY - hoveringSize.top
		const draggingCard = State.draggingCard

		return if draggingCard.columnId is data.columnId
		and ((draggingCard.index < data.index and draggedTop < hoveringCenter)
		or (draggingCard.index > data.index and draggedTop > hoveringCenter))

		State.hoveringCardId = data.id
		State.dropIndex = if draggedTop > hoveringCenter then data.index + 1 else data.index

	css d:hcs c:cooler6 rd:lg p:2 bd:$color bgc:$color w:100% bxs:sm g:5
		.content ta:start fs:md-
		.icon d:hcc

	<self [cursor:grab]=(canMove and pending?) [$color:cooler0] [bgc:gray6/30 c:warmer1]=#dragging
		draggable=(canMove and pending?)
		@dragstart=dragStart
		@pointerdown=checkPointer
		@dragover.if(not isFullColumn).prevent=dragOver
		@dragend.prevent=dragEnd>
			<span.content> data.title

			if State.draggingCard?
				css .hide-on-dragging visibility:hidden

			if isNegative
				<span.icon.hide-on-dragging> <img[w:20px] src=trashIcon>
			
			else switch data.status
				when 'pending'
					<CardOptions.hide-on-dragging card=data>
				when "done"
					<span.icon.hide-on-dragging> <img[w:20px] src=doneIcon>
				when "undone"
					<span.icon.hide-on-dragging> <img[w:20px] src=undoneIcon>
				when 'moved'
					<span.icon.hide-on-dragging> <img[w:20px] src=movedIcon>
