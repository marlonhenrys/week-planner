import State from '../State.imba'
import closeIcon from '../assets/close-icon.png'

const titlePlaceholder = 'Learn something new, do a daily task, try a sport, discover a new hobby or anything else...'

export default tag CardAdder
	columnId\string
	content\string = ''
	
	get validTitle?
		content.trim!.length > 0 and content.trim!.length <= 180

	def open
		$dialog.showModal!
		$tinput.focus!

	def close
		$dialog.close!
		$openBtn.blur!
		content = ''

	def save
		if validTitle?
			const title = content.trim!
			State.addCard title, columnId
			self.close!

	css dialog bd:cooler2 bgc:warmer1 w@lt-sm:250px w@350:300px w@700:250px w@xl:18% bxs:lg rd:lg
		.container d:vflex g:4
		.row d:hcs
		h3 m:0 c:warm7
		label fw:bold c:warm5
		textarea rd:lg bgc:cool1 bd:1px solid cool3 px:3 py:1 resize:none ff:sans lh:1.5
			@focus olc:indigo3
		.save as:flex-end rd:md bgc:indigo6 c:warm1 bd:1px solid indigo6 px:2 py:1 fw:bold ls:1.2 w:100% cursor:pointer
			@hover bgc:indigo7
			@focus olc:indigo3
		.disabled pe:none o:20%

	css .open bgc:transparent p:5px rd:lg bd:1px dashed cooler4 c:cooler5 w:100% cursor:pointer
		@focus bc:cooler5 ol:clear
		@hover bgc:cooler0

	<self[w:105%] id=columnId>
		<dialog$dialog @keydown.esc.prevent=close>
			<.container>
				<.row>
					<h3> 'I am going to...'
					<button.close @click=close> <img[w:14px] src=closeIcon>

				<form.container @submit.prevent=save>
					<textarea$tinput name='title' placeholder=titlePlaceholder rows=5 bind=content>
					<span [fs:xs c:gray5 mt:-3]> "* Describe in up to 180 characters"

					<button.save .disabled=(not validTitle?) type='submit'> "That's it!"

		<button$openBtn.open [bgc:cool1]=$dialog.open @click=open> $dialog.open ? 'Thinking...' : 'I am going to...'
