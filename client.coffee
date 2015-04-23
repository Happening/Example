Db = require 'db'
Dom = require 'dom'
Modal = require 'modal'
Obs = require 'obs'
Plugin = require 'plugin'
Page = require 'page'
Server = require 'server'
Ui = require 'ui'
{tr} = require 'i18n'
Markdown = require 'markdown'
Form = require 'form'


exports.renderSettings = !->
	Dom.div !->
		Markdown.render tr("Disclaimer: If you or anyone else in this group is offended by *anything* at all , then don't install this Group App. This Group App is not suitable for children, families, sensitive people or humanity in general.")

	if Db.shared
		if Plugin.userIsAdmin()
			Dom.h3 !->
				Ui.item !->
					Dom.text tr('(Re)Start Game')
					#Dom.onTap !->
						#Server.sync 'startgame'
				Ui.item !->
					Dom.text tr 'Advance Round'
					#Dom.onTap !->
						#Server.sync 'advanceround'			
exports.render = ->
	log 'Begin Program'
	if !Db.shared.get 'roundStarted'
		Dom.section !->
			Dom.text "Waiting...."
		if Plugin.userIsAdmin()
			Dom.section !->
				Ui.button "Start Round", !->
					Server.call 'StartRound'
		else
			Dom.section !->
				Dom.text "Only admin can start Rounds"
	else
		Dom.section !->
			Dom.text Db.shared.get 'blackCard'
		if Plugin.userId() != Db.shared.get 'LeaderID'
			renderHand Plugin.userId()	
			###Dom.section !->
				Ui->button "Send Anwser(s)", !->
					sendAnswers###

		
renderHand = (ID) !->
	#if !Db.personal.get 'Cards' # Player has never had cards = Never been in this plugin
	Dom.section !->
		Dom.text "You have no Cards"
	cards = Obs.create #create a new Card Object
		1: {text: "hoi", selected: 0}
		2: {text: "doei", selected: 1}
		3: {text: "hoi", selected: 0}
		4: {text: "doei", selected: 1}
		5: {text: "hoi", selected: 0}
	cards.iterate (card) !-> #TODO
			Dom.section ->
				Dom.text "Test: " + card.get('text')
	Server.call 'setCards', cards,Plugin.userId() #call server function to add the Card object to the personal Database
	
	cards = Db.personal(Plugin.userId()).get 'Cards'
	count = cards.count() #don't know if this works
	cards.iterate (card) !-> # Loop door de loop van aantal kaarten door
		#if card.get('text') != "" # kijk of de kaart undifined is
			#card.set ('text',Server.call 'getWhiteCard') q
			#card.set ('selected', 0)
	
	#all cards should be filled again
	cards.iterate (card) !-> #iterate through all cards again
		Dom.div !->
			Dom.text card.text
			Dom.onTap !-> #check if Card is being pressed
				card.selected = 1 #if card is being pressed select should be put on true###
			
###	
sendAnswers = !->
	numberOfAnswers = 0
	cards = Db.personal.get 'Cards'
	for i in [0...5]
		numberOfAnswers++ if cards.get(i).selected###