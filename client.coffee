Db = require 'db'
Dom = require 'dom'
Modal = require 'modal'
Obs = require 'obs'
Plugin = require 'plugin'
Page = require 'page'
Server = require 'server'
Ui = require 'ui'

exports.render = ->

	Dom.section !->
		Dom.style Box: 'middle'
		Ui.avatar Plugin.userAvatar(),
			onTap: !-> Plugin.userInfo()

		Dom.div !->
			Dom.style Flex: true
			Dom.h2 "Hello, developer"
			Dom.text "This is an example Group App demonstrating some Happening API's."

	Dom.section !->
		Dom.h2 "Reactive dom"
		Dom.userText "Group Apps are built using Javascript or CoffeeScript. User interfaces are drawn using an abstraction upon the web DOM you know and love. It works **reactively**: changes in the data model are automatically mapped to changes in the interface."

		clientCounter = Obs.create(0)
		Dom.div !->
			# whenever clientCounter's value is changed, only this DIV is redrawn
			Ui.button "Increment me: " + clientCounter.get(), !->
				clientCounter.modify (v) -> v+1

	Dom.section !->
		Dom.h2 "Server side code"
		Dom.text "Group Apps contain both code that is run on clients (phones, tablets, web browsers) and on Happening's servers. Server side code is invoked using RPC calls from a client, using timers or subscribing to user events (eg: a user leaves a group)."
		Dom.div !->
			Ui.button "Get server time", ->
				Server.call 'getTime', (time) ->
					Modal.show "The time on the server is: #{time}"

	Dom.section !->
		Dom.h2 "Synchronized data store"
		Dom.text "A hierarchical data store is available that is automatically synchronized across all the devices of group members. You write to it from server side code."
		Dom.div !->
			Ui.button "Synchronized counter: " + Db.shared.get('counter'), !->
				Server.call 'incr'

	Dom.section !->
		Dom.h2 "Use the source"
		Dom.text "We're working on writing more documentation. For now, experiment by looking at the sources of Group Apps we've made available on GitHub."
		Dom.div !->
			Ui.button "Visit github.com", !->
				Plugin.openUrl 'https://github.com/happening'

	Dom.section !->
		Dom.h2 "Some examples"

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

		Ui.button "Social API", !->
			Page.nav !->
				Page.setTitle "Social API"
				Dom.section !->
					Dom.text "API to show comments or like boxes."
				require('social').renderComments()


