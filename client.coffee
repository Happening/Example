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
			Ui.button "New Black Card", !->
				Server.call 'getBlackCard'
		Dom.section !->
			Dom.h2 "Current black card:"
			Dom.text Db.shared.get 'blackCard'
			Dom.style background: "#000000", color: "#ffffff"
		if Plugin.userId() != Db.shared.get 'LeaderID'
			renderHand Plugin.userId()	
			Dom.section !->
				Ui.button "Send Anwser(s)", !->
					sendAnswers

		
renderHand = (ID) !->
	if !Db.shared.get 'Cards', Plugin.userId() # Player has never had cards = Never been in this plugin
		#log "Hello"
		Dom.section !->
			Dom.text "You have no Cards" + ID
		cards = Obs.create
			1: {text: "", ID, selected: 0,number:1}
			2: {text: "", ID, selected: 0,number:2}
			3: {text: "", ID, selected: 0,number:3}
			4: {text: "", ID, selected: 0,number:4}
			5: {text: "", ID, selected: 0,number:5}
		i = 1
		cards.iterate (card)  !->
			Server.call 'setCards', card.get('text'),card.get('selected'),i,Plugin.userId() #call server function to add the Card object to the personal Database
			i += 1
	
	Db.shared.observeEach 'Cards',Plugin.userId(), (card) !->
		Server.call 'getWhiteCard', card.get('number') ,ID
		if card.get('text') == ""  # kijk of de kaart undifined is
				Server.call 'setCards', Db.shared.get('whiteCardNew', card.get('number'),ID),card.get('selected'),card.get('number'),Plugin.userId()
		Dom.section !->
			Dom.text card.get('text') + " " + card.get('selected') 
			Dom.onTap !->
				Server.call 'setCards', card.get('text'),!card.get('selected'),card.get('number'),Plugin.userId()

sendAnswers = !->
	numberOfAnswers = 0
	cards = Db.personal.get 'Cards'
	for i in [0...5]
		numberOfAnswers++ if cards.get(i).selected