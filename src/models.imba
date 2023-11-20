export class Column
	id\string
	title\string
	index\number
	color\string
	limit\number
	week\string
	canAdd\boolean
	canMoveOut\boolean
	toFill\boolean
	status\'closed'|'current'|'open'

export class Card
	id\string
	title\string
	index\number
	columnId\string
	status\'pending'|'done'|'missed'|'moved'

export class Content
	activeWeek\string
	columns\Column[]
	cards\Card[]