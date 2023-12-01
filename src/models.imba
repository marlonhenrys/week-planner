export class Column
	id\string
	title\string
	index\number
	color\string
	limit\number
	week\string
	board\string
	canAdd\boolean
	canMoveOut\boolean
	toFill\boolean
	status\'closed'|'current'|'open'

export class Card
	id\string
	title\string
	index\number
	columnId\string
	status\'pending'|'done'|'undone'|'moved'|'discarded'

export class Content
	activeWeek\string
	selectedBoard\string
	weeks\string[]
	columns\Column[]
	cards\Card[]