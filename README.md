Example
=======
Example group app for Happening. Contains API demos.

Happening enables developers to create group apps that can instantly be used by anyone. It offers a group-centric, cross-platform API and allows many types of group-interaction to be modeled in less than a thousand lines of code.

Read more at https://developer.happening.im/.

Getting started
---------------
On Linux/Mac, use your Bash-compatible shell. On Windows, we recommend the Git shell that comes with [Git](http://git-scm.com/download/win).

1. Clone the example code: `git clone https://github.com/happening/Example.git`.
2. Create a **Developer console app** via https://happening.im/store/106 and clicking "Start!".
3. Deploy your app using `cd Example/; ./deploy {deployKey}`. It should instantly update in your browser / app.
4. Optionally, copy the __deploy key__ to a file (`echo 1234abcdef > .deploykey`) and use `./deploy` without arguments.

Alternatively, you can use the online editor at https://developer.happening.im.

Manifest
--------
`manifest` holds your app configuration.

- __name__ Group app name.
- __desciption__ Group app description.
- __api__ API version, use `3`.
- __icon__ Default icon, [list of available icons](https://happening.im/static/plugicons.html). Alternatively, you can bundle your own `icon.svg`.

Distribution
------------
Happening apps work in instances. A new instance is created when someone wants to use the app with another group of people. That means your (viral) app can spread autonomously throughout Happening. Your **developer console** shows all current instances. You can choose to disable re-sharing the app - useful when the app is very specific (not useful to others) or you are still testing out your app.

Another way people on Happening find apps is via the listing under Launch app. If you feel your app should be listed here, [send us a message](mailto:dev@happening.im).
