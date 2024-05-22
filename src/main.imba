import './app.css'
import Board from './components/Board.imba'
import Checker from './components/Checker.imba'
import State from './State.imba'

global css body ff:sans bgc:warmer1 box-sizing:border-box w:100% m:0 p:0 -webkit-tap-highlight-color:transparent
	.hidden visibility:hidden
	.close as:flex-end bd:none bgc:transparent c:rose5 @hover:rose6 fs:1xl cursor:pointer
		@focus ol:none

tag App
	#today = (new Date).toLocaleDateString!

	def build\self
		setInterval(&, 1minutes) do
			const currentDate = (new Date).toLocaleDateString!
			return if currentDate is #today
			#today = currentDate
			setup!

	def setup do State.checkHistory!

	<self>
		if State.cardsToFinish.length > 0
			<Checker>
		else
			<Board>

tag Loader
	def routed do await State.init!
	<self> <App>

imba.mount (do <Loader route='*'>), document.getElementById "app"
