import State from '../State.imba'

export default tag Checker 

	get cardsToFinishByColum
		const cardsByColumn = {}
		for card in State.cardsToFinish
			const column = State.getColumnData(card.columnId)
			const columnName = "{column.title} ({column.week})"
			cardsByColumn[columnName] = [...(cardsByColumn[columnName] or []), card] 

		return cardsByColumn

	get daysToFinish
		Object.keys(cardsToFinishByColum)

	css d:vtc h:88vh w:100% g:5
		.columns d:htc flw:wrap g:8
		.column d:vflex g:4 rd:lg bgc:violet1 p:2 bxs:sm
		.column-title m:0 c:warm6 ta:center
		.card d:hcs c:cooler6 rd:lg p:2 bd:cooler0 bgc:cooler0 w:220px bxs:sm g:5
		.content w:100% fs:md-
		button as:flex-end rd:md c:warm6 bd:1px solid fw:bold ls:1.2 p:1 w:49% bxs:sm
		.done bgc:green1 bc:green1
			@hover bgc:green2 bc:green2
			@focus olc:green2
		.missed bgc:rose1 bc:rose1
			@hover bgc:rose2 bc:rose2
			@focus olc:rose2

	<self> 
		<h2[c:warm6 ta:center]> "Let's review the previous day{daysToFinish.length > 1 ? 's' : ''}"
		<.columns> for columnTitle in daysToFinish
			<.column>
				<h3.column-title> columnTitle
				for card in cardsToFinishByColum[columnTitle]
					<[d:vflex g:1]>
						<.card [d:hcc g:2]>
							<span.content> card.title
						<[d:hcs]>
							<button.done @click=State.finishCard(card, yes)> 'Done'
							<button.missed @click=State.finishCard(card, no)> 'Missed'

imba.scheduler