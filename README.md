Example
=======
An example plugin for Happening.

Deploying your plugin
---------------------
_This guide assumes you can run bash scripts (you're fine on osx or linux, although you might need to download the git, zip and curl applications. For windows I suggest downloading git for windows, which also has a nice bash console: http://git-scm.com/download/win)_

Start by cloning the example code
```git clone https://github.com/happening/Example.git```

To deploy your plugin to the "My group apps" happening, follow the instructions below.
Firstly, you'll need your "upload code".
* Go to the "My group apps" happening and click on the little "console" icon next to the app which has been created for you (or create a fresh one first by pressing the "+ Create new group app" button )
* That will open a informational window containing a script to clone and immediatly deploy your app
* The line `./deploy 1234567890` contains your "upload code", copy it to your clipboard.

Paste your upload code in the `.deploykey` file.

In case you don't want to upload certain files, edit the `.deployignore` and add each file on a new line (wildcards are supported using an asterisk *, eg. *.psd). This file already holds the _.deploykey_ file, so that your upload code won't be sent to the plugin servers.

All that's left now is running `./deploy`

The manifest file
-----------------
The manifest file holds configuration for you app. You can set things like `name`, `description` and `icon` here (a comprehensive list of all available icons will be made available shortly)

Another important setting in the manifest file is the `api` setting, if you ommit it or set it to 1 the "legacy api" will be used. Make sure you set it to 2 unless you know what you're doing.

About happening
---------------
In case you don't know what this is about: Happening is a group app for iOS and Android, that allows you to create your own plugins in minutes. To get started signup at: https://develop.happening.im

Don't worry: plugins are just Javascript (or CoffeeScript), both client-side and server-side. However, the powerful Happening environment provides you with user group details, a database that syncs to all clients, reactive user-interface widgets, and html/css for whatever else you may want to do. That social app you've wanted to build for ages, but didn't because it'd take you weeks? You'll finish it tonight.

