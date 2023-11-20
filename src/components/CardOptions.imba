import State from '../State'
import type { Card } from '../models'

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

	css dialog bd:cooler2 bgc:warmer1 w:230px bxs:lg rd:lg cursor:default
		.container d:vflex g:4
		.row d:hcs g:2
		.line d:hcl g:1
		h3 m:0 c:warm7 tof:ellipsis of:hidden ws:nowrap
		input appearance:none w:1.2em h:1.2em bgc:cool3 rd:full d:hcc
			@checked bgc:indigo5
				@after c:warmer1 content:"~" fw:bold
		.btn as:flex-end rd:md c:warm1 bd:1px solid px:2 py:1 fw:bold ls:1.2 w:100%
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
		.bar bgc:green7 rd:full w:100% h:3px tween:all 1.5s ease animation:open 1.2s
		.hold
			.bar w:0% tween:all 1.5s ease

	css .open bgc:transparent rd:full bd:1px solid cyan6 c:cyan6
		@focus bgc:cyan1 olc:cyan6
		@hover bgc:cyan1

	<self>
		<dialog$dialog @keydown.esc.prevent=close>
			<.container>
				<.row>
					<h3> card.title 
					<button.close @click=close> '✖'
				<span[m:0 c:indigo6]> 'Available columns:'
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
							<button.btn.done @touch.flag('hold', '.action').hold(duration=1.3s)=done> "Mark as done"
							<.bar>

		<button$openBtn.open @click=open> "❯"
