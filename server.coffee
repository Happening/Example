Db = require 'db'

exports.onInstall = ->
	# set the counter to 0 on plugin installation
	Db.shared.set 'counter', 0

# exported functions prefixed with 'client_' are callable by our client code using `Server.call`
exports.client_incr = ->
	log 'hello world!' # write to the plugin's log
	Db.shared.modify 'counter', (v) -> v+1

exports.client_getTime = (cb) ->
	cb.reply new Date()

exports.onHttp = (request) ->
	# special entrypoint for the Http API: called whenever a request is made to our plugin's inbound URL
	Db.shared.set 'http', data
	request.respond 200, "Thanks for your input\n"

exports.client_fetchHn = ->
	Http = require 'http'
	Http.get
		url: 'https://news.ycombinator.com'
		name: 'hnResponse' # corresponds to exports.hnResponse below

exports.hnResponse = (data) !->
	# called when the Http API has the result for the above request
	
	re = /<a href="(http[^"]+)">([^<]+)<\/a>/g
	# regex to find urls/titles in html

	id = 1
	while id < 5 and m = re.exec(data)
		[all, url, title] = m
		log 'hn headline', title, url
		continue if url is 'http://www.ycombinator.com' # header link
		Db.shared.set 'hn', id,
			title: title
			url: url
		id++

exports.onPhoto = (info) !->
	# entrypoint when a photo is uploaded by the plugin
	log 'onPhoto', JSON.stringify(info)
	Db.shared.set 'photo', info.key

exports.client_event = !->
	# send push event to all group members
	Event = require 'event'
	Event.create
		text: "Test event"
		# sender: Plugin.userId() # prevent push (but bubble) to sender
		# for: [1, 2] # to only include group members 1 and 2
		# for: [-3] # to exclude group member 3
		# for: ['admin', 2] # to group admins and member 2

