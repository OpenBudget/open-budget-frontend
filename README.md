open-budget-frontend
====================
[![Build Status](https://travis-ci.org/OpenBudget/open-budget-frontend.svg?branch=master)](https://travis-ci.org/OpenBudget/open-budget-frontend)
[![Join the chat at https://gitter.im/OpenBudget/open-budget-frontend](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/OpenBudget/open-budget-frontend?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Contribute
----------

Check our issues [here](https://github.com/OpenBudget/open-budget-frontend/issues) or on [Huboard](https://huboard.com/OpenBudget/open-budget-frontend/#/)

Installing and running the project
---------------
You need to have git + Node version >= 5.0 and NPM >= 3 on your system  
[How to install git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)  
[How to install node](https://nodejs.org/en/download/current/)  
[Installing Node.js via package manager (better)](https://nodejs.org/en/download/package-manager/)

### When you have all the prerequirement

Checkout the project from ```https://github.com/OpenBudget/open-budget-frontend/``` and run these in the command line:

  ```bash
  cd open-budget
  npm install # Will take a while
  npm start
  ```

if you want to see what's under the hood take a look at the package.json

Build for production
------------------

```
npm run build
```
Will build the app for production, the output will be in `open-budget/dist`.

### About the build system
The build system we're using is [webpack](http://webpack.github.io/).
The less is also compiled via webpack, with single entry point at the `main.js`. (coffee/js modules dose not have thier own style dependencies declarations), and extracted using ExtractTextPlugin

### JS codebase
Our js code is ES6, transpiled using babel 6, es2015 preset.
We are following [airbnb javascript style](https://github.com/airbnb/javascript), enforced by eslint. to lint the code use: `npm run lint`
We strive to convert all the coffeescript code into ES6

###Enjoy!


