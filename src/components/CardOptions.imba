import State from '../State.imba'
import type { Card } from '../models.imba'
import optionIcon from '../assets/option-icon.png'

export default tag CardOptions
	card\Card
	toColumnId\string = null

	get otherAvailableColumns
		State.availableColumns.filter do $1.id isnt card.columnId

	get forToday?
		const column = State.getColumnData card.columnId
		column.status is 'current'

	def open
		$dialog.showModal!

	def close
		$dialog.close!
		$openBtn.blur!
		toColumnId = null

	def move
		if toColumnId
			State.moveCard card, toColumnId
			self.close!

	def done
		State.completeCard card
		self.close!

	css dialog bd:cooler2 bgc:warmer1 w@lt-sm:250px w@350:300px w@lg:250px bxs:lg rd:lg cursor:default
		.container d:vflex g:4
		.row d:hcs g:2
		.line d:hcl g:1
		h3 m:0 c:warm7 tof:ellipsis of:hidden ws:nowrap
		label cursor:pointer
		input appearance:none w:1.2em h:1.2em bgc:cool3 rd:full d:hcc cursor:pointer
			@checked bgc:indigo5
				@before content:'~' fw:bold c:warmer1
		.btn as:flex-end rd:md c:warm1 bd:1px solid px:2 py:1 fw:bold ls:1.2 w:100% cursor:pointer
		.move bgc:indigo6 bc:indigo6
			@hover bgc:indigo7 bc:indigo7
			@focus olc:indigo7
		.disabled pe:none o:20%
		.done bgc:green6 bc:green6
			@hover bgc:green7 bc:green7
			@focus olc:green7
		.action d:vcc g:1
			@keyframes open
				from w:0%
				to w:100%
		.bar bgc:green7 rd:full w:100% h:3px tween:all 1.3s ease animation:open 1s
		.hold
			.bar w:0% tween:all 1.3s ease

	css .open bgc:transparent rd:full bd:none d:hcc bd:1px solid transparent bgc:cooler1 p:0 rotate:90deg cursor:pointer
		.icon w:19px filter:contrast(20%)
		@focus olc:cooler4
		@hover bgc:cooler2

	<self>
		<dialog$dialog @keydown.esc.prevent=close>
			<.container>
				<.row>
					<h3> card.title 
					<button.close @click=close> '✖'
				<span[m:0 c:indigo6 fw:bold]> 'Available columns:'
				<%group>
					<form.container @submit.prevent=move>
						if otherAvailableColumns.length is 0
							<span> "There is no one :("
						else for column in otherAvailableColumns
							<.line>
								<input id=(column.id + card.id) type='radio' name='column' value=column.id bind=toColumnId>
								<label htmlFor=(column.id + card.id)> column.title
						<button.btn.move .disabled=(toColumnId is null) type='submit'> "Move it!"
					
					if forToday?
						<span [d:hcc mb:4px c:cool6]> 'or'
						<.action>
							<button.btn.done @touch.flag('hold', '.action').hold(duration=1s)=done> "Mark as done"
							<.bar>

		<button$openBtn.open @click=open> <img.icon src=optionIcon>
