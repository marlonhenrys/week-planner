import * as IDB from 'idb-keyval';
import type { Content, Card, Column } from './models.imba'

def loadContent\Content
	const activeWeek = await IDB.get 'activeWeek'
	const entries = await IDB.entries!
	const columns = (entries.filter do([[_, type]]) type is 'column').map do([_, val]) val
	const cards = (entries.filter do([[_, type]]) type is 'card').map do([_, val]) val
	const content = {activeWeek, columns, cards}
	
	return content

def saveCard card\Card
	IDB.set ['default', 'card', card.id], card

def saveColumn column\Column
	IDB.set ['default', 'column', column.id], column

def saveManyColumns columns\Column[]
	IDB.setMany columns.map do(column) [['default', 'column', column.id], column]

def saveActiveWeek activeWeek\string
	IDB.set 'activeWeek', activeWeek

const all = { loadContent, saveCard, saveColumn, saveManyColumns, saveActiveWeek }
export default all
