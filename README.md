open-budget-frontend
====================

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
    $ patch -p0 < bootstrap-rtl.less.patch
    $ git submodule update --init
    $ grunt
    $ grunt serve
 

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

Enjoy!
