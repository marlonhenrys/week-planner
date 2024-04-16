import * as IDB from 'idb-keyval';
import type { Content, Card, Column } from './models.imba'

def loadContent\Promise<Content>
	const activeWeek\string = await IDB.get 'activeWeek'
	const selectedBoard\string = await IDB.get 'selectedBoard'
	const entries = await IDB.entries!
	const weeks\Set<string> = new Set
	const weeksSample\Set<string> = new Set

	const columnEntries = (entries.filter do(entry\[string[], Column]) entry[0].length is 3)
	const columns\Column[] = columnEntries.map do $1[1]
	const columnIds = columns.map do $1.id

	columnEntries.forEach do weeks.add $1[0][0]

	(Array.from(weeks).map(do parseInt $1).sort!.slice 0, 5).forEach do weeksSample.add $1.toString!

	const cards\Card[] = (entries.filter do([_, val]) columnIds.includes val.columnId).map do([_, val]) val

	const content = {activeWeek, selectedBoard, weeks: weeksSample, columns, cards}

	return content

def loadWeekContent\Promise<[Column[], Card[]]> requestedWeek\string
	const entries = await IDB.entries!
	const columns = (entries.filter do(entry\[string[], Column]) entry[0][0] is requestedWeek).map do([_, val]) val
	const columnIds = columns.map do $1.id
	const cards = (entries.filter do([_, val]) columnIds.includes val.columnId).map do([_, val]) val

	return [columns, cards]

def saveCard card\Card
	IDB.set [card.id], card

def saveColumn column\Column
	IDB.set [column.week, column.board, column.id], column

def saveManyColumns columns\Column[]
	IDB.setMany columns.map do(column) [[column.week, column.board, column.id], column]

def saveActiveWeek activeWeek\string
	IDB.set 'activeWeek', activeWeek

def saveSelectedBoard selectedBoard\string
	IDB.set 'selectedBoard', selectedBoard

def resetAll
	IDB.clear!

const all = 
	{	loadContent, 
		loadWeekContent,
		saveCard, 
		saveColumn, 
		saveManyColumns, 
		saveActiveWeek, 
		saveSelectedBoard, 
		resetAll 
	}

export default all
