import State from '../State.imba'

export default tag Checker 

	get cardsToFinishByColumn
		const cardsByColumn = {}
		for card in State.cardsToFinish
			const column = State.getColumnData card.columnId
			const date = State.getColumnDate column.index, parseInt column.week
			const columnName = "{column.title} ({date})"
			cardsByColumn[columnName] = [...(cardsByColumn[columnName] or []), card] 

		return cardsByColumn

	get daysToFinish
		Object.keys(cardsToFinishByColumn)

	css d:vtc w:100% g:5
		.columns d:htc flw:wrap g:8
		.column d:vflex g:4 rd:lg bgc:violet1 p:2 bxs:sm w@lt-sm:250px w@350:300px w@700:250px w@lg:300px
		.column-title m:0 c:warm6 ta:center
		.card d:hcs c:cooler6 rd:lg p:2 bd:cooler0 bgc:cooler0 bxs:sm g:5
		.content w:100% fs:md-
		button as:flex-end rd:md c:warm6 bd:1px solid fw:bold ls:1.2 p:1 w:49% bxs:sm
		.done bgc:green1 bc:green1
			@hover bgc:green2 bc:green2
			@focus olc:green2
		.undone bgc:rose1 bc:rose1
			@hover bgc:rose2 bc:rose2
			@focus olc:rose2

	<self> 
		<h2[c:warm6 ta:center px:1]> "Let's review the previous day{daysToFinish.length > 1 ? 's' : ''}"
		<.columns> for columnTitle in daysToFinish
			<.column key=columnTitle>
				<h3.column-title> columnTitle
				for card in cardsToFinishByColumn[columnTitle]
					<%group [d:vflex g:1] key=card.id>
						<.card [d:hcc g:2]>
							<span.content> card.title
						<%options [d:hcs]>
							<button.done @click=State.finishCard(card, yes)> 'Done'
							<button.undone @click=State.finishCard(card, no)> 'Undone'
