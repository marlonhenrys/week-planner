import type {Content, Card, Column} from './models.imba'
import Store from './Store.imba'

def uid do (Math.random() + 1).toString(36).substring(4)

def currentWeek
	const now = new Date
	const onejan = new Date(2023, 0, 1)
	const week = Math.ceil((((now.getTime! - onejan.getTime!) / 1days) + onejan.getDay!) / 7)
	return "{week - 48}"

const boards = 
	relationship: 'family and friends'
	home: 'house and pets'
	legacy: 'work and carrer'
	future: 'study and self-development'
	personal: 'fun, health and wellness'

def weekColumns week\string, idShift\number

	Object.keys(boards).flatMap do(board, index)
		const boardKey = index + 10
		[
			{id: "{boardKey}1000", title: 'Sunday', index: 0, limit: 3, status: 'open', week, board, toFill: true, canAdd: yes, canMoveOut: yes, color: "sky1"}
			{id: "{boardKey}2000", title: "Monday", index: 1, limit: 3, status: 'open', week, board, toFill: true, canAdd: yes, canMoveOut: yes, color: "sky1"}
			{id: "{boardKey}3000", title: 'Tuesday', index: 2, limit: 3, status: 'open', week, board, toFill: true, canAdd: yes, canMoveOut: yes, color: "sky1"}
			{id: "{boardKey}4000", title: 'Wednesday', index: 3, limit: 3, status: 'open', week, board, toFill: true, canAdd: yes, canMoveOut: yes, color: "sky1"}
			{id: "{boardKey}5000", title: 'Thursday', index: 4, limit: 3, status: 'open', week, board, toFill: true, canAdd: yes, canMoveOut: yes, color: "sky1"}
			{id: "{boardKey}6000", title: 'Friday', index: 5, limit: 3, status: 'open', week, board, toFill: true, canAdd: yes, canMoveOut: yes, color: "sky1"}
			{id: "{boardKey}7000", title: 'Saturday', index: 6, limit: 3, status: 'open', week, board, toFill: true, canAdd: yes, canMoveOut: yes, color: "sky1"}
			{id: "{boardKey}8000", title: 'Next Week', index: 7, limit: 7, status: 'open', week, board, toFill: true, canAdd: yes, canMoveOut: yes, color: "lime1"}
			{id: "{boardKey}9000", title: 'To Give Up', index: 8, limit: 5, status: 'open', week, board, toFill: false, canAdd: no, canMoveOut: no, color: "fuchsia1"}
		].map do(column\Column) 
			column.id = String(parseInt(column.id) + idShift + 1)
			return column

class State
	content\Content

	draggingCardId\string = null
	hoveringCardId\string = null
	dropIndex\number = null
	cardsToFinish\Card[] = []

	#selectedWeek\string = null

	isLoadingColumns\boolean = no

	def init
		content = await Store.loadContent!
		#selectedWeek = content.activeWeek

	def addCard\void title\string, columnId\string
		return if isFullColumn columnId

		const index = getLastColumnIndex(columnId) + 1
		const card\Card = {index, title, columnId, description: null, id: uid!, status: 'pending', createdAt: Date.now!}
		
		content.cards.push card
		Store.saveCard card
	
	def moveCard\void card\Card, toColumnId\string
		return if isFullColumn(toColumnId) and card.columnId isnt toColumnId

		const column = getColumnData toColumnId

		card.columnId = toColumnId
		card.index = dropIndex or getLastColumnIndex(toColumnId) + 1
		card.status = 'discarded' if column.index is 8

		Store.saveCard card

	def upCard\void card\Card
		card.index -= 1
		Store.saveCard card

	def downCard\void card\Card
		card.index += 1
		Store.saveCard card

	def completeCard\void card\Card
		card.status = 'done'
		Store.saveCard card

	def giveUpCard\void card\Card, toColumnId\string
		card.columnId = toColumnId
		card.status = 'discarded'
		Store.saveCard card

	def upsertCardInfo\void card\Card, title\string, description\string
		card.title = title
		card.description = description
		Store.saveCard card

	get draggingCard?
		draggingCardId isnt null

	get hoveringCard?
		hoveringCardId isnt null

	get draggingCard\Card
		content.cards.find do $1.id is draggingCardId

	get hoveringCard\Card
		content.cards.find do $1.id is hoveringCardId

	get availableColumns
		content.columns.filter do $1.status isnt 'closed' and not isFullColumn($1.id) and $1.board is selectedBoard

	get weeks
		(Array.from content.weeks).sort!

	get selectedWeek
		#selectedWeek

	set selectedWeek week
		#selectedWeek = week
		const anyWeekColumn = findColumn 1, week
		unless anyWeekColumn
			isLoadingColumns = yes
			Store.loadWeekContent(week).then do([columns, cards])
				content.columns = content.columns.concat columns
				content.cards = content.cards.concat cards
				setTimeout(&, 1s) do
					isLoadingColumns = no
					imba.commit!

	get boards
		Object.entries boards

	get selectedBoard
		content.selectedBoard

	set selectedBoard board
		content.selectedBoard = board
		Store.saveSelectedBoard board

	def getColumnCards columnId\string
		const cards = content.cards.filter do $1.columnId is columnId
		cards.sort do $1.index - $2.index

	def getColumnDate dayIndex\number, weekIndex\number
		const initialDate = new Date(2023, 11, 3)
		initialDate.setDate! initialDate.getDate! + dayIndex + (weekIndex - 1) * 7
		initialDate.toLocaleDateString!

	def getWeekDateRange weekIndex\number
		"{getColumnDate 0, weekIndex} - {getColumnDate 6, weekIndex}"

	def getColumnData columnId\string
		content.columns.find do $1.id is columnId

	def getColumnLength columnId\string
		content.cards.reduce(&, 0) do(counter, c\Card) 
			if c.columnId is columnId then ++counter else counter

	def getLastColumnIndex columnId\string
		Math.max(0, ...getColumnCards(columnId).map do $1.index)

	def isFullColumn columnId\string
		const column = getColumnData columnId
		const columnLength = getColumnLength columnId
				
		columnLength is column.limit

	def getColumnSnapshot columnId\string
		const cards = getColumnCards columnId
		const initialState = {done: 0, pending: 0, undone: 0}
		cards.reduce(&, initialState) do(state, c\Card)
			{...state, [c.status]: ++state[c.status]}

	def getColumnSummary columnId\string
		const columnState = getColumnSnapshot columnId
		const columnLength = getColumnLength columnId
		
		return 'empty' if columnLength is 0

		if columnState.done is columnLength then 'completed'
		elif (columnState.done / columnLength) >= 0.5 then 'almost'
		elif (columnState.done / columnLength) >= 0.2 then 'far'
		else 'none'

	def findColumn dayIndex, weekIndex
		content.columns.find do(column\Column)
			column.index is dayIndex and column.week is weekIndex

	def findTodayColumns currentDayIndex, currentWeekIndex
		content.columns.filter do(column\Column)
			column.index is currentDayIndex and column.week is currentWeekIndex

	def distributeNextWeekColumns nextWeekColumn\Column, currentDayIndex, newWeekIndex
		const nextWeekCards = content.cards.filter do $1.columnId is nextWeekColumn.id

		nextWeekCards.forEach do(card\Card)
			if card.status isnt 'moved'
				card.status = 'moved'
				Store.saveCard card

		const sortedNextWeekCards = [...nextWeekCards].sort do $1.index - $2.index

		const unclosedCurrentColumns = content.columns.filter do 
			$1.week is newWeekIndex and $1.index >= currentDayIndex and $1.index <= 6 and $1.board is nextWeekColumn.board 
		
		const columnsToDistribute\[number, string][] = unclosedCurrentColumns.map do [$1.limit, $1.id]
		
		const currentNextWeekColumn = content.columns.find do 
			$1.week is newWeekIndex and $1.index is 7 and $1.board is nextWeekColumn.board 

		for card, index in sortedNextWeekCards
			const availableColumn = columnsToDistribute.find do([limit], idx)
				limit > 0 and idx >= (index % unclosedCurrentColumns.length)
			
			if availableColumn
				availableColumn[0] -= 1 
				addCard card.title, availableColumn[1]
			else
				addCard card.title, currentNextWeekColumn.id

	def startWeek currentDayIndex\number, newWeekIndex\string
		const previousWeekColumns = content.columns.filter do $1.week is content.activeWeek
		const previousWeekShift = parseInt previousWeekColumns[0]..id..slice(3)
		const newWeekColumns = weekColumns newWeekIndex, (previousWeekShift or 0)
		
		content.activeWeek = newWeekIndex
		Store.saveActiveWeek newWeekIndex
		selectedWeek = newWeekIndex
		content.weeks.add newWeekIndex

		selectedBoard = 'relationship' unless selectedBoard

		content.columns.push(...newWeekColumns)
		Store.saveManyColumns newWeekColumns

		const nextWeekColumns = previousWeekColumns.filter do $1.index is 7

		for column in nextWeekColumns
			distributeNextWeekColumns column, currentDayIndex, newWeekIndex

	def checkHistory		
		const currentWeekIndex = currentWeek!
		const currentDayIndex = (new Date).getDay!

		let todayColumns = findTodayColumns currentDayIndex, currentWeekIndex

		if todayColumns.length is 0
			startWeek currentDayIndex, currentWeekIndex
			todayColumns = findTodayColumns currentDayIndex, currentWeekIndex

		for column in todayColumns
			if column.status isnt 'current'
				column.status = 'current'
				Store.saveColumn column

		const previousColumns = content.columns.filter do(column\Column) 
			column.index < currentDayIndex or column.week < currentWeekIndex
		
		previousColumns.forEach do(column\Column)
			if column.status isnt 'closed'
				column.status = 'closed'
				Store.saveColumn column

		const previousDayColumnIds = (previousColumns.filter do $1.index <= 6).map do $1.id

		const followingColumns = content.columns.filter do(column\Column) 
			column.index > currentDayIndex and column.week is currentWeekIndex
		
		followingColumns.forEach do(column\Column)
			if column.status isnt 'open'
				column.status = 'open'
				Store.saveColumn column
		
		cardsToFinish = content.cards.filter do
			$1.status is 'pending' and previousDayColumnIds.includes($1.columnId)

		cardsToFinish.sort do parseInt($1.columnId) - parseInt($2.columnId)

	def finishCard card\Card, isDone\boolean
		card.status = isDone ? 'done' : 'undone'
		Store.saveCard card

		cardsToFinish = cardsToFinish.filter do $1.id isnt card.id

	def checkCode code\string
		if code is 'res3t4ll'
			await Store.resetAll!
			return global.location.reload!


const state = new State
export default state
