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
	if !Db.shared.get 'roundStarted'
		Dom.section !->
			Dom.text "Waiting...."
		if Plugin.userIsAdmin()
			Dom.section !->
				Ui.button "Start Round", !->
					Server.call 'StartRound',Plugin.users.count().get()
					Server.call 'getBlackCard'
		else
			Dom.section !->
				Dom.text "Only admin can start Rounds"
	else
		if Plugin.userIsAdmin()
			Dom.section !->
				Dom.h2 "Test Buttons" 
				Ui.button "New Black Card", !->
					Server.call 'getBlackCard'
				Ui.button "New Round " + Plugin.users.count().get(), !->
					Plugin.users.iterate (user) !->
						Server.call 'resetAnswers', user.key()
					Server.call 'newRound',Plugin.users.count().get()
					Server.call 'getBlackCard'
				Ui.button "Reset all", !->
					Server.call 'reset'
				Ui.button "Cancel waiting", !->
					Server.call 'stopAnswering'
				
		if Db.shared.get 'lastFilled'
			Dom.section !->
				Dom.h2 "last filled black card:"
				Dom.h3 "Answer by: " + Plugin.userName(Db.shared.get 'LastFilledBy')
				Dom.text Db.shared.get 'lastFilled'
				Dom.style background: "#0077cf", color: "#ffffff"
		Dom.section !->
			Dom.h2 "Current black card:"
			Dom.h3 "Leader is: " + Plugin.userName(Db.shared.get 'LeaderID')
			Dom.text Db.shared.get 'blackCard'
			Dom.style background: "#000000", color: "#ffffff"
		if Plugin.userId() != Db.shared.get 'LeaderID'
			renderHand Plugin.userId()	
			if !Db.shared.get 'Answer',Plugin.userId(), 'Answered'
				Ui.button "Send Anwser(s)", !->
					sendAnswers Plugin.userId()
		else
			Dom.section !->
				Dom.text "You are the Leader of this round, you'll have to select the best answer possible when the 5 minutes waiting time is over.."
			numberOfAnswers = Db.shared.get 'numberOfCards'
			Db.shared.observeEach 'Answer', (answer) !->
				if answer.get('Answered')
					Dom.section !->	
						Ui.avatar Plugin.userAvatar(answer.key()), onTap: !-> Plugin.userInfo(answer.key())
						Dom.text "Answer by: " + Plugin.userName(answer.key())
						for i in [1..numberOfAnswers]
								Ui.item Db.shared.get('Answer',answer.key(),i)
						Dom.onTap !->
							if Db.shared.get 'selectAnswer' 
								Modal.confirm  tr("Do you want to select this as your anser"), !->
									blackCard =  Db.shared.get 'blackCard'
									for i in [1..numberOfAnswers]
										if blackCard.indexOf('_') == 0
											blackCard = Db.shared.get('Answer',answer.key(),i) + blackCard.slice(1)
										else
											blackCard = blackCard.slice(0,blackCard.indexOf('_')) + " " +  Db.shared.get('Answer',answer.key(),i) + " " +  blackCard.slice(blackCard.indexOf('_'))
									Server.call 'setFinalAnswer', blackCard,answer.key()
							else 
								Modal.show "Wait for the 5 minute timer to run out"
	Page.setFooter
		label: tr("Go To The Chat")
		action: !-> 
			Page.nav !->
				Page.setTitle "Chat"

				require('social').renderComments()
										
								
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
			if !card.get('text')  # kijk of de kaart undifined is
				Server.call 'getWhiteCard', ID ,card.get('number')
				Server.call 'setCards', Db.shared.get('whiteCardNew',ID, card.get('number')),card.get('selected'),card.get('number'),Plugin.userId()
				
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
				Server.call 'setSelected', card.get('selected'),card.get('number'),Plugin.userId()	
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
				#Server.call 'getWhiteCard', ID ,card.get('number')
				Server.call 'setCards', null,false,card.get('number'),Plugin.userId()

		Server.call 'Answer', ID