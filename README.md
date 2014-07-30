Example
=======
An example Group App for Happening.

What's Happening?
-----------------
Happening is a Group App Platform for iOS, Android and [the web](https://happening.im).

Group Apps (also called Plugins) are just Javascript or CoffeeScript. The powerful Happening environment provides you with user and group details, a synchronized data store across all clients, reactive user-interface widgets, and html/css for whatever else you may want to do. That social app you've wanted to build for ages, but didn't because it'd take you weeks? You'll finish it tonight.

Getting started
---------------
On Linux/Mac, use your Bash-compatible shell. On Windows, we recommend the Git console that comes with [Git](http://git-scm.com/download/win).

1. Clone the example code: `git clone https://github.com/happening/Example.git`.

2. Navigate to https://happening.im/dev. This will redirect you to the special "My group apps" happening, possibly after logging in.

3. Tapping the console icon next to your Group App will show the Developer Console. Copy its __upload code__ to a file: `echo 123456ab > .deploykey`.

4. Deploy your Group App using `./deploy`. It should instantaneously update in your browser / app.

Manifest
--------
`manifest` holds your app configuration.

- __name__ Group App name.
- __desciption__ Group App description.
- __api__ API version, don't use anything other than `2`
- __icon__ Default icon, [list of available icons](https://happening.im/static/plugicons.html). Alternatively, you can bundle your own `icon.svg`.

Distribution
------------
The Developer Console will also show a __share code__. Search for this code in the Group App Store of other happenings to add your new App (making it instantaneously available to all its members!).

Once added in another happening, a Group App will be upgraded within 60 minutes of you updating the version in "My group apps". Use `exports.onUpgrade` in `server.coffee` to update data store items if they change between versions. The Developer Console allows you to inspect the App's data store in these other happenings to aid debugging.

If you feel your Group App should be listed in the Group App store, [send us a message](mailto:dev@happening.im). Be sure to include the install code and a group code where we can see your App in action.
