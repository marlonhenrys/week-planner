import type { Column as IColumn} from '../models.imba'
import Column from './Column.imba'
import State from '../State.imba'

export default tag Board

	#todayOverview = no

	css d:vcc g:7 p:5
		.row d:hcc flw:wrap g:15 g@!700:6 mb:4 p@!300:2
		label fw:bold
		.col d:vcl g:2 w@lt-sm:282px w@!300:262px w@350:332px w@700:282px w@xl:282px
		select px:1 py:3 bxs:sm rd:md bd:cooler2 w:100% fs:md- bgc:cooler0
		.columns d:htc flw:wrap g:15 tween:all 2s ease
		.btn rd:full bgc:cooler2 c:cooler6 px:3 py:2 fs:sm- fw:bold bd:cooler2 as:flex-end
			@hover bxs:sm

	def showColumn column\IColumn
		column.week is State.selectedWeek and column.board is State.selectedBoard

	def codePrompt
		const code = global.prompt 'Enter a code:'
		State.checkCode code

	<self>
		<.row>
			<.col>
				<label htmlFor='board-select' @dblclick=codePrompt> "Board:"
				<select id='board-select' bind=State.selectedBoard disabled=#todayOverview> for [board, label] in State.boards
					<option key=board value=board> label

			<.col>
				<label htmlFor='week-select'> "Week:"
				<select id='week-select' bind=State.selectedWeek disabled=#todayOverview> for week in State.weeks
					<option key=week value=week> State.getWeekDateRange parseInt(week)

			<button.btn bind=#todayOverview> "Today Overview"

		if State.isLoadingColumns
			<span> 'Loading...'
		elif not #todayOverview
			<.columns ease> for column in State.content.columns when showColumn column
				<Column key=column.id data=column>
		else
			<.columns ease> for column in State.todayColumns
				const desc = State.getBoardTitle column.board
				<Column key=column.id data=column description=desc>
