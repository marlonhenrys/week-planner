import type {Card as ICard} from '../models.imba'
import Column from './Column.imba'
import State from '../State.imba'

export default tag Board

	css d:vcc g:7 pb:5
		.row d:hcc flw:wrap g:15 g@!700:6 p:4 p@!300:2 w@700:90%
		label fw:bold
		.col d:vcl g:2 maw:300px maw@lt-md:400px maw@700:250px w:100%
		select px:1 py:3 bxs:sm rd:md bd:cooler2 w:100% fs:md- bgc:cooler0
		.columns d:htc flw:wrap g:15 tween:all 2s ease

	def showColumn column\Column
		column.week is State.selectedWeek and column.board is State.selectedBoard

	def codePrompt
		const code = global.prompt 'Enter a code:'
		State.checkCode code

	<self>
		<.row>
			<.col>
				<label htmlFor='board-select' @dblclick=codePrompt> "Board:"
				<select id='board-select' bind=State.selectedBoard> for [board, label] in State.boards
					<option value=board> label

			<.col>
				<label htmlFor='week-select'> "Week:"
				<select id='week-select' bind=State.selectedWeek> for week in State.weeks
					<option value=week> week

		if State.isLoadingColumns
			<span> 'Loading...'
		else
			<.columns ease>
				<Column data=column> for column in State.content.columns when showColumn column