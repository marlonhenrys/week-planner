import * as IDB from 'idb-keyval';
import type { Content, Card, Column } from './models'

def loadContent\Content
	const activeWeek = await IDB.get 'activeWeek'
	const entries = await IDB.entries!
	const columns = (entries.filter do([[type]]) type is 'column').map do([key, val]) val
	const cards = (entries.filter do([[type]]) type is 'card').map do([key, val]) val
	const content = {activeWeek, columns, cards}
	
	return content

def saveCard card\Card
	IDB.set ['card', card.id], card

def saveColumn column\Column
	IDB.set ['column', column.id], column

def saveManyColumns columns\Column[]
	IDB.setMany columns.map do(column) [['column', column.id], column]

def saveActiveWeek activeWeek\string
	IDB.set 'activeWeek', activeWeek

const all = { loadContent, saveCard, saveColumn, saveManyColumns, saveActiveWeek }
export default all
