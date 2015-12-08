Comments = require 'comments'
Db = require 'db'
Dom = require 'dom'
Modal = require 'modal'
Obs = require 'obs'
App = require 'app'
Page = require 'page'
Server = require 'server'
Ui = require 'ui'

exports.render = ->
	Comments.disable()

	Dom.style
		background: '#f4f4f4'
		height: '100%'

	Ui.card !->
		Dom.style Box: 'middle'
		Ui.avatar
			key: App.userAvatar()
			style: marginRight: '8px'
			onTap: !-> App.showMemberInfo()
		Dom.div !->
			Dom.style Flex: true
			Dom.h2 "Hello, developer"
			Dom.div "This is an example Group App demonstrating some Happening API's."

	Ui.card !->
		Dom.h2 "Reactive dom"
		Dom.userText "Group Apps are built using Javascript or CoffeeScript. User interfaces are drawn using an abstraction upon the web DOM you know and love. It works **reactively**: changes in the data model are automatically mapped to changes in the interface."

		clientCounter = Obs.create(0)
		Dom.div !->
			# whenever clientCounter's value is changed, only this DIV is redrawn
			Ui.button "Increment me: " + clientCounter.get(), !->
				clientCounter.modify (v) -> v+1

	Ui.card !->
		Dom.h2 "Server side code"
		Dom.text "Group Apps contain both code that is run on clients (phones, tablets, web browsers) and on Happening's servers. Server side code is invoked using RPC calls from a client, using timers or subscribing to user events (eg: a user leaves a group)."
		Dom.div !->
			Ui.button "Get server time", ->
				Server.call 'getTime', (time) ->
					Modal.show "The time on the server is: #{time}"

	Ui.card !->
		Dom.h2 "Synchronized data store"
		Dom.text "A hierarchical data store is available that is automatically synchronized across all the devices of group members. You write to it from server side code."
		Dom.div !->
			Ui.button "Synchronized counter: " + Db.shared.get('counter'), !->
				Server.call 'incr'

	Ui.card !->
		Dom.h2 "Sources and documentation"
		Dom.text "Documentation can be found on the Docs GitHub repo. You can also find some Group Apps on GitHub, which use the API's described in the documentation."
		Dom.div !->
			Ui.button "Examples", !->
				App.openUrl 'https://github.com/happening'
			Ui.button "Documentation", !->
				App.openUrl 'https://github.com/happening/Docs/wiki'

	Ui.card !->
		Dom.h2 "Some examples"

		Ui.button "Event API", !->
			Page.nav !->
				Page.setTitle "Event API"
				Ui.card !->
					Dom.text "API to send push events (to users that are following your plugin)."
					Ui.button "Push group event", !->
						Server.send 'event'

		Ui.button "Http API", !->
			Page.nav !->
				Page.setTitle "Http API"
				Ui.card !->
					Dom.h2 "Outgoing"
					Dom.text "API to make HTTP requests from the Happening backend."
					Ui.button "Fetch HackerNews headlines", !->
						Server.send 'fetchHn'

					Db.shared.iterate 'hn', (article) !->
						Ui.item !->
							Dom.text article.get('title')
							Dom.onTap !->
								App.openUrl article.get('url')

				Ui.card !->
					Dom.h2 "Incoming Http"
					Dom.text "API to receive HTTP requests in the Happening backend."
					Dom.div !->
						Dom.style
							padding: '10px'
							margin: '3px 0'
							background: '#ddd'
							_userSelect: 'text' # the underscore gets replace by -webkit- or whatever else is applicable
						Dom.code "curl --data-binary 'your text' -L " + App.inboundUrl()

					Dom.div !->
						Dom.style
							padding: '10px'
							background: App.colors().bar
							color: App.colors().barText
						Dom.text Db.shared.get('http') || "<awaiting request>"

		Ui.button "Photo API", !->
			Photo = require 'photo'
			Page.nav !->
				Page.setTitle "Photo API"
				Ui.card !->
					Dom.text "API to show, upload or manipulate photos."
					Ui.bigButton "Pick photo", !->
						Photo.pick()
					if photoKey = Db.shared.get('photo')
						(require 'photoview').render
							key: photoKey

		Ui.button "Plugin API", !->
			Page.nav !->
				Page.setTitle "Plugin API"
				Ui.card !->
					Dom.text "API to get user or group context."
				Ui.list !->
					items =
						"App.agent": App.agent()
						"App.colors": App.colors()
						"App.id": App.id()
						"App.name": App.name()
						"App.title": App.title()
						"App.userAvatar": App.userAvatar()
						"App.userId": App.userId()
						"App.userIsAdmin": App.userIsAdmin()
						"App.userName": App.userName()
						"App.users": App.users.get()
						"Page.state": Page.state.get()
						"Page.width": Page.width()
						"Page.height": Page.height()
						"Page.active": Page.active()
					for name,value of items
						text = "#{name} = " + JSON.stringify(value)
						Ui.item text.replace(/,/g, ', ') # ensure some proper json wrapping on small screens

		Ui.button "Comments API", !->
			Page.nav !->
				Page.setTitle "Comments API"
				Ui.card !->
					Dom.text "API to show comments or like boxes."
				Comments.enable()

		Ui.button "Map API", !->
			Page.nav !->
				Map = require "map"
				Page.setTitle "Map API"
				Dom.style padding: "0" # Remove the padding of the main container
				Map.render # Render the map and set the defaults
					minZoom: 2
					maxZoom: 18
					zoom: 8
					latlong: "52.3,5.5"
				, (map) !-> # Render the content of the map
					location = "52.3,5.5"
					map.marker location, !-> # Render a marker, all normal Dom functions can be used inside
						Dom.style
							margin: '-9px 0 0 -25px'
							backgroundColor: '#000'
							color: "#FFF"
						Dom.div !->
							Dom.text "Marker"
							Dom.onTap
								cb: !->
									log "Short tap"
									Modal.show "short tap"
									map.setLatlong location
								longTap: !->
									log "Long tap"
									Modal.show "Long tap"
									map.setLatlong location


