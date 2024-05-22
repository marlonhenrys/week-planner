import CardAdder from './CardAdder.imba'
import State from '../State.imba'
import type { Card } from '../models.imba'
import closeIcon from '../assets/close-icon.png'

const titlePlaceholder = "You can change this title only on the same day it was created. Think carefully about what you want to do."
const descriptionPlaceholder = 'Describe steps, updates and reminders...'

export default tag CardEditor < CardAdder
	card\Card
	extraContent\string

	#titleEditing\boolean
	#descriptionEditing\boolean

	get validDescription?
		extraContent.trim!.length <= 600

	get createdToday?
		const createdAt = new Date(card.createdAt).toLocaleDateString!
		const today = (new Date).toLocaleDateString!
		createdAt is today

	get closed?
		card.status isnt 'pending'

	def editTitle
		#titleEditing = not #titleEditing
		content = card.title unless #titleEditing

	def editDescription
		#descriptionEditing = not #descriptionEditing
		extraContent = card.description unless #descriptionEditing

	def open
		#titleEditing = no
		#descriptionEditing = no
		content = card.title
		extraContent = card.description
		$dialog.showModal!

	def save
		if validTitle? and validDescription?
			const title = content.trim!
			const description = extraContent.trim!
			State.upsertCardInfo card, title, description
			self.close!

	def rendered\self
		$tinput.focus! if #titleEditing
		$dinput.focus! if #descriptionEditing

	css dialog
		textarea@disabled bgc:cool2 bc:cool2 c:cooler6

	css .edit-btn bgc:transparent c:sky6 bd:1px solid sky6 p:0.3 2 fw:bold rd:md fs:xxs
		&.cancel-btn c:rose6 bc:rose6

	css form .row mt:-2

	<self id=card.id>
		<dialog$dialog @keydown.esc.prevent=close>
			<.container>
				<.row>
					<h3> 'Title'
					<button.close @click=close> <img[w:14px] src=closeIcon>

				<form.container @submit.prevent=save>
					<textarea$tinput disabled=(not #titleEditing) name='title' placeholder=titlePlaceholder rows=5 bind=content>
					<.row>
						if createdToday? and not closed?
							<span [fs:xs c:gray5]> "* Describe in up to 180 characters"
							<button.edit-btn .cancel-btn=#titleEditing type='button' @click=editTitle> #titleEditing ? "Cancel" : "Edit"
						else
							<span [fs:xs c:gray5]> "* Can no longer be edited"

					<h4 [m:0 c:warm7]> "Description"
					<textarea$dinput name='extraContent' disabled=(not #descriptionEditing) placeholder=descriptionPlaceholder rows=13 bind=extraContent>
					<.row>
						unless closed?
							<span [fs:xs c:gray5]> "* Describe in up to 600 characters"
							<button.edit-btn .cancel-btn=#descriptionEditing type='button' @click=editDescription> #descriptionEditing ? "Cancel" : "Edit"
						else
							<span [fs:xs c:gray5]> "* Can no longer be edited"

					<button.save .disabled=(not validTitle?) type='submit'> "That's it!" unless closed?

		if closed?
			<div @click=open> <slot>
		else
			<button$openBtn.open [bgc:cool1]=$dialog.open @click=open> 'more details'
