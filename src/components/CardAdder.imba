import State from '../State.imba'

export default tag CardAdder
	columnId\string
	content\string = ''

	get valid? do content.trim!.length > 0 and content.trim!.length <= 180

	def open
		$dialog.showModal!
		$input.focus!

	def close
		$dialog.close!
		$openBtn.blur!
		content = ''

	def save
		if valid?
			State.addCard content.trim!, columnId
			self.close!

	get placeholder
		'Learn something new, do a daily task, try a sport, discover a new hobby or anything else...'

	css dialog bd:cooler2 bgc:warmer1 w:230px bxs:lg rd:lg
		.container d:vflex g:4
		.row d:hcs
		h3 m:0 c:warm7
		label fw:bold c:warm5
		textarea rd:lg bgc:cool1 bd:1px solid cool3 px:3 py:1 resize:none ff:sans lh:1.5
			@focus olc:indigo3
		.save as:flex-end rd:md bgc:indigo6 c:warm1 bd:1px solid indigo6 px:2 py:1 fw:bold ls:1.2 w:100%
			@hover bgc:indigo7
			@focus olc:indigo7
		.disabled pe:none o:20%

	css .open bgc:transparent p:5px rd:lg bd:1px dashed cooler4 c:cooler5 w:100%
		@focus bc:cooler5 ol:clear
		@hover bgc:cooler0

	<self[w:105%]>
		<dialog$dialog @keydown.esc.prevent=close>
			<.container>
				<.row>
					<h3> 'I am going to...'
					<button.close @click=close> '✖'
				<form.container @submit.prevent=save>
					<textarea$input name='title' placeholder=placeholder rows=5 bind=content>
					<span [mt:-3 fs:xs c:gray5]> "* Describe it in up to 180 characters"
					<button.save .disabled=(not valid?) type='submit'> "That's it!"
				
		<button$openBtn.open [bgc:cool1]=$dialog.open @click=open> if $dialog.open then 'Thinking...' else 'I am going to...'