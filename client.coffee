Db = require 'db'
Dom = require 'dom'
Modal = require 'modal'
Obs = require 'obs'
Plugin = require 'plugin'
Page = require 'page'
Server = require 'server'
Ui = require 'ui'
{tr} = require 'i18n'
Form = require 'form'

exports.renderSettings = !->
	if Db.shared
		Dom.text tr("Game has started")

	else
		selectMember
			name: 'opponent'
			title: tr("Opponents")
		selectMember
			name: 'opponent'
			title: tr("Opponents")
		selectMember
			name: 'opponent'
			title: tr("Opponents")
			
exports.render = ->
	Dom.section !->
			Ui.button "Next Black Card", !->
				Server.call 'getBlackCard'
			Ui.button "Me as Leader", !->
				Server.call 'meLeader', Plugin.userId()
			Ui.button "Someone as Leader", !->
				Server.call 'meLeader', 0
	if !Db.shared.ref 'blackCard' 
		Server.call 'getBlackCard'
	Dom.section !->
		Dom.style 
			background: "#000000",
			color: "#ffffff"
		Dom.h2 "Current Question Card"
		Dom.text Db.shared.get 'blackCard'
	if Plugin.userId() != Db.shared.get 'LeaderId'
		for i in [0...6]
			Server.call 'getWhiteCard',Plugin.userId(), i
		Dom.section !->
			
			number = 0
			Dom.style padding: '4px 12px 30px 12px',background: "#E9E9E9"
			
				
			Dom.section !->
				Dom.style Box: 'center vertical', Flex: 1, background: "#ffffff",padding: 'auto auto 30px auto'
				Dom.section !->
					Dom.style margin: '4px', textAlign: 'center'
					Dom.text "Test" + Db.shared.get 'whiteCard', Plugin.userId(), 0
					
					Dom.div !->
						Dom.style fontSize: '75%'
				Dom.onTap !->
					Server.call 'Answer',Plugin.userId(),Dom.getText()
			Dom.section !->
				Dom.style Box: 'center vertical', Flex: 1, background: "#ffffff",padding: 'auto auto 30px auto'
				Dom.section !->
					Dom.style margin: '4px', textAlign: 'center'
					Dom.text Db.shared.get 'whiteCard', Plugin.userId(), 1
					Dom.div !->
						Dom.style fontSize: '75%'
			Dom.section !->
				Dom.style Box: 'center vertical', Flex: 1, background: "#ffffff",padding: 'auto auto 30px auto'
				Dom.section !->
					Dom.style margin: '4px', textAlign: 'center'
					Dom.text Db.shared.get 'whiteCard', Plugin.userId(), 2
					Dom.div !->
						Dom.style fontSize: '75%'
			Dom.section !->
				Dom.style  background: "#ffffff",padding: 'auto auto 30px auto'
				Dom.section !->
					Dom.style margin: '4px', textAlign: 'center'
					Dom.text Db.shared.get 'whiteCard', Plugin.userId(), 3
					Dom.div !->
						Dom.style fontSize: '75%'
			Dom.section !->
				Dom.style Box: 'center vertical', Flex: 1, background: "#ffffff",padding: 'auto auto 30px auto'
				Dom.section !->
					Dom.style margin: '4px', textAlign: 'center'
					Dom.text Db.shared.get 'whiteCard', Plugin.userId(), 4
					Dom.div !->
						Dom.style fontSize: '75%'
			Dom.section !->
				Dom.style Box: 'center vertical', Flex: 1, background: "#ffffff",padding: 'auto auto 30px auto'
				Dom.section !->
					Dom.style margin: '4px', textAlign: 'center'
					Dom.text Db.shared.get 'whiteCard', Plugin.userId(), 5
					Dom.div !->
						Dom.style fontSize: '75%'
		###
		Ui.button "Event API", !->
			Page.nav !->
				Page.setTitle "Event API"
				Dom.section !->
					Dom.text "API to send push events (to users that are following your plugin)."
					Ui.button "Push group event", !->
						Server.send 'event'

		Ui.button "Http API", !->
			Page.nav !->
				Page.setTitle "Http API"
				Dom.section !->
					Dom.h2 "Outgoing"
					Dom.text "API to make HTTP requests from the Happening backend."
					Ui.button "Fetch HackerNews headlines", !->
						Server.send 'fetchHn'

					Db.shared.iterate 'hn', (article) !->
						Ui.item !->
							Dom.text article.get('title')
							Dom.onTap !->
								Plugin.openUrl article.get('url')

				Dom.section !->
					Dom.h2 "Incoming Http"
					Dom.text "API to receive HTTP requests in the Happening backend."
					Dom.div ->
						Dom.style
							padding: '10px'
							margin: '3px 0'
							background: '#ddd'
							_userSelect: 'text' # the underscore gets replace by -webkit- or whatever else is applicable
						Dom.code "curl --data-binary 'your text' " + Plugin.inboundUrl()

					Dom.div !->
						Dom.style
							padding: '10px'
							background: Plugin.colors().bar
							color: Plugin.colors().barText
						Dom.text Db.shared.get('http') || "<awaiting request>"

		Ui.button "Photo API", !->
			Photo = require 'photo'
			Page.nav !->
				Page.setTitle "Photo API"
				Dom.section !->
					Dom.text "API to show, upload or manipulate photos."
					Ui.bigButton "Pick photo", !->
						Photo.pick()
					if photoKey = Db.shared.get('photo')
						(require 'photoview').render
							key: photoKey

		Ui.button "Plugin API", !->
			Page.nav !->
				Page.setTitle "Plugin API"
				Dom.section !->
					Dom.text "API to get user or group context."
				Ui.list !->
					items =
						"Plugin.agent": Plugin.agent()
						"Plugin.colors": Plugin.colors()
						"Plugin.groupAvatar": Plugin.groupAvatar()
						"Plugin.groupCode": Plugin.groupCode()
						"Plugin.groupId": Plugin.groupId()
						"Plugin.groupName": Plugin.groupName()
						"Plugin.userAvatar": Plugin.userAvatar()
						"Plugin.userId": Plugin.userId()
						"Plugin.userIsAdmin": Plugin.userIsAdmin()
						"Plugin.userName": Plugin.userName()
						"Plugin.users": Plugin.users.get()
						"Page.state": Page.state.get()
						"Dom.viewport": Dom.viewport.get()
					for name,value of items
						text = "#{name} = " + JSON.stringify(value)
						Ui.item text.replace(/,/g, ', ') # ensure some proper json wrapping on small screens
		###
		Page.setFooter
			label: tr("Go To The Chat")
			action: !-> 
				Page.nav !->
					Page.setTitle "Chat"
					Dom.section !->
						Dom.text "API to show comments or like boxes."
					require('social').renderComments()

# input that handles selection of a member
selectMember = (opts) !->
	opts ||= {}
	[handleChange, initValue] = Form.makeInput opts, (v) -> 0|v

	value = Obs.create(initValue)
	Form.box !->
		Dom.style fontSize: '125%', paddingRight: '56px'
		Dom.text opts.title||tr("Selected member")
		v = value.get()
		Dom.div !->
			Dom.style color: (if v then 'inherit' else '#aaa')
			Dom.text (if v then Plugin.userName(v) else tr("Nobody"))
		if v
			Ui.avatar Plugin.userAvatar(v), !->
				Dom.style position: 'absolute', right: '6px', top: '50%', marginTop: '-20px'

		Dom.onTap !->
			Modal.show opts.selectTitle||tr("Select member"), !->
				Dom.style width: '80%'
				Dom.div !->
					Dom.style
						maxHeight: '40%'
						overflow: 'auto'
						_overflowScrolling: 'touch'
						backgroundColor: '#eee'
						margin: '-12px'

					Plugin.users.iterate (user) !->
						Ui.item !->
							Ui.avatar user.get('avatar')
							Dom.text user.get('name')

							if +user.key() is +value.get()
								Dom.style fontWeight: 'bold'

								Dom.div !->
									Dom.style
										Flex: 1
										padding: '0 10px'
										textAlign: 'right'
										fontSize: '150%'
										color: Plugin.colors().highlight
									Dom.text "✓"

							Dom.onTap !->
								handleChange user.key()
								value.set user.key()
								Modal.remove()
			, (choice) !->
				log 'choice', choice
				if choice is 'clear'
					handleChange ''
					value.set ''
			, ['cancel', tr("Cancel"), 'clear', tr("Clear")]
