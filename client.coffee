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
					Server.call 'getBlackCard'
		else
			Dom.section !->
				Dom.text "Only admin can start Rounds"
	else
		Dom.section !->
			Ui.button "New Black Card", !->
				Server.call 'getBlackCard'
			Ui.button "New Round", !->
				Plugin.users.iterate (user) !->
					Server.call 'newRound', user.key()
				Server.call 'getBlackCard'
			
		Dom.section !->
			Dom.h2 "Current black card:"
			Dom.text Db.shared.get 'blackCard'
			Dom.style background: "#000000", color: "#ffffff"
		if Plugin.userId() != Db.shared.get 'LeaderID'
			renderHand Plugin.userId()	
			Ui.button "Send Anwser(s)", !->
				sendAnswers Plugin.userId()
					


		
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
			6: {text: "", ID, selected: 0,number:6}
			7: {text: "", ID, selected: 0,number:7}
			8: {text: "", ID, selected: 0,number:8}
			9: {text: "", ID, selected: 0,number:9}
			10: {text: "", ID, selected: 0,number:10}

		cards.iterate (card)  !->
			Server.call 'setCards', card.get('text'),card.get('selected'),card.get('number'),Plugin.userId() #call server function to add the Card object to the personal Database

	if !Db.shared.get 'Answer',ID, 'Answered'
		Db.shared.observeEach 'Cards',Plugin.userId(), (card) !->
			
			if card.get('text') == "" || !card.get('text')  # kijk of de kaart undifined is
				Server.call 'getWhiteCard', card.get('number') ,ID
				Server.call 'setCards', Db.shared.get('whiteCardNew', card.get('number'),ID),card.get('selected'),card.get('number'),Plugin.userId()
			renderCard card

renderCard = (card) !->
	backColor = if card.get('selected') then "#0077cf" else "#ffffff"
	textColor = if card.get('selected') then "#ffffff" else "#000000"
	prefix = ""
	prefix = "1:" if Db.shared.get('Answer',Plugin.userId(),1) == card.get('text') && prefix == ""  
	prefix = "2:" if Db.shared.get('Answer',Plugin.userId(),2) == card.get('text') && prefix == ""   
	prefix = "3:" if Db.shared.get('Answer',Plugin.userId(),3) == card.get('text') && prefix == "" 
	Dom.section !->
			Dom.text " #{prefix} " +card.get('text')
			Dom.style background: backColor, color: textColor
			Dom.onTap !->
				Server.call 'setCards', card.get('text'),!card.get('selected'),card.get('number'),Plugin.userId()
				if !card.get('selected')
					if Db.shared.get('Answer',Plugin.userId(),1) == "" || !  Db.shared.get('Answer',Plugin.userId(),1)
						Server.call 'setAnswer', Plugin.userId(), 1, card.get('text')
					else if Db.shared.get('Answer',Plugin.userId(),2) == ""|| !  Db.shared.get('Answer',Plugin.userId(),2)
						Server.call 'setAnswer', Plugin.userId(), 2, card.get('text')
					else if Db.shared.get('Answer',Plugin.userId(),3) == "" || !  Db.shared.get('Answer',Plugin.userId(),3)
						Server.call 'setAnswer', Plugin.userId(), 3, card.get('text')
					else
						Modal.show tr("Can't have more answers"), !->
				else
					if Db.shared.get('Answer',Plugin.userId(),1) == card.get('text')
						Server.call 'setAnswer', Plugin.userId(), 1, Db.shared.get('Answer',Plugin.userId(),2)
						Server.call 'setAnswer', Plugin.userId(), 2, Db.shared.get('Answer',Plugin.userId(),3)
						Server.call 'setAnswer', Plugin.userId(), 3, ""
					if Db.shared.get('Answer',Plugin.userId(),2) == card.get('text')
						Server.call 'setAnswer', Plugin.userId(), 2, Db.shared.get('Answer',Plugin.userId(),3)
						Server.call 'setAnswer', Plugin.userId(), 3, ""
					if Db.shared.get('Answer',Plugin.userId(),3) == card.get('text')
						Server.call 'setAnswer', Plugin.userId(), 3, ""
				
sendAnswers = (ID) !->
	numberOfAnswers = Db.shared.get 'numberOfCards' 
	Db.shared.observeEach 'Cards',Plugin.userId(), (card) !->
		if card.get('selected') == true      
			numberOfAnswers--  
		
	if numberOfAnswers != 0
		Modal.show tr("Wrong number of answer(s)"), !->
			if numberOfAnswers < 0
				Dom.div "You have " + numberOfAnswers *-1 + " answer to much!"
			else 
				Dom.div "You have " + numberOfAnswers + " answer to few!"
				
	else
		Db.shared.observeEach 'Cards',Plugin.userId(), (card) !->
			if card.get('selected') == true        
				Server.call 'setCards', "",card.get('selected'),card.get('number'),Plugin.userId()
		Server.call 'setAnswer', Plugin.userId(), 1, ""
		Server.call 'setAnswer', Plugin.userId(), 2, ""
		Server.call 'setAnswer', Plugin.userId(), 3, ""
		Server.call 'Answer', ID