open-budget-frontend
====================

[![Join the chat at https://gitter.im/OpenBudget/open-budget-frontend](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/OpenBudget/open-budget-frontend?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Contribute
----------

Check our issues [here](https://github.com/OpenBudget/open-budget-frontend/issues) or on [Huboard](https://huboard.com/OpenBudget/open-budget-frontend/#/)


Install on Linux / OS X
---------------

###OSX only - Install Brew

First make sure you have npm installed, if not install it according to the instructions here: http://brew.sh/

###Install the project

Checkout the project from ```https://github.com/OpenBudget/open-budget-frontend/``` and then go into the open-budget directory and run these in the command line:

    $ cd open-budget
    $ npm install
    $ sudo npm install -g bower
    $ bower update
    $ sudo npm install -g grunt-cli
    $ grunt

Install on Windows
------------------
(tested on Windows XP SP3, Windows 7)

###Install git

If you don't already have git installed, get it at: http://git-scm.com/download/win

###Install node.js (includes npm)

Get the Windows installer from: http://nodejs.org/download/

###Fix up npm

(This section handles a known issue with npm, see https://github.com/npm/npm/issues/6106)

Open Git Bash. Run:

    $ npm

If you get an error that looks like:

    ENOENT, stat '<some directory>\npm'

Then run this command:

    $ mkdir "%APPDATA%\npm"

###Install the project

Same instructions as under OS X above (only without 'sudo').

Build for production
------------------

```
grunt build
```
Will build the app for production use in `open-budget/dist`.


```
grunt serve:dist
``` 
Will build the app for production and serve it via local web server at http://localhost:9000  
(build = minify the js bundle, minify the compiled css, revving all of the assets and update the references accordingly)
 
### About the build system
The build system we're using is [webpack](http://webpack.github.io/).
The less is also compiled via webpack, with single entry point at the `main.js`. (coffee/js modules dose not have thier own style dependencies declarations), and extracted using ExtractTextPlugin
 

###Enjoy!
