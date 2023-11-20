import Column from './components/Column'
import Checker from './components/Checker'
import State from './State'

global css body ff:sans bgc:warmer1 box-sizing:border-box
	.hidden visibility:hidden
	.close as:flex-end bd:none bgc:transparent c:rose5 @hover:rose6 fs:1xl
		@focus olc:red4

tag App
	#today = (new Date).toLocaleDateString!

	def build
		setInterval(&, 1minutes) do
			const currentDate = (new Date).toLocaleDateString!
			return if currentDate is #today
			#today = currentDate
			setup!

	def setup do State.checkHistory!

	css d:htc flw:wrap maw:1500px miw:230px g:13 p:2%

	<self>
		if State.cardsToFinish.length > 0
			<Checker>
		else
			<Column data=column> for column in State.content.columns when column.week is State.content.activeWeek

tag Loader
	def routed do await State.init!
	<self> <App>

imba.mount do <Loader route='/'>
