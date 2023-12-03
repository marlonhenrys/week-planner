import * as IDB from 'idb-keyval';
import type { Content, Card, Column } from './models.imba'

def loadContent\Content
	const activeWeek = await IDB.get 'activeWeek'
	const selectedBoard = await IDB.get 'selectedBoard'
	const entries = await IDB.entries!
	const weeks = new Set

	const columns = (entries.filter do([key])
		return false if key.length isnt 3
		weeks.add key[0]
		return true).map do([_, val]) val

	const columnIds = columns.map do $1.id
	const cards = (entries.filter do([_, val]) columnIds.includes val.columnId).map do([_, val]) val

	const content = {activeWeek, selectedBoard, weeks, columns, cards}

	return content

def loadWeekContent requestedWeek
	const entries = await IDB.entries!
	const columns = (entries.filter do([[week]]) week is requestedWeek).map do([_, val]) val
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
