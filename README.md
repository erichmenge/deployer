# WORK IN PROGRESS (pull requests welcome)

# Deployer

Deployer handles deploying GoodGrapes into production by way of Hubot.

It was developed to run on Heroku.

After you create your Heroku app, you'll need to set some environment variables.

## Installing

* Clone the repo
* `$ heroku create`
* `$ git push heroku master`

## Requirements

* Heroku (Or make some slight modifications)
* Hubot (with http-post-say script)
* Hubot Script [https://github.com/goodgrapes/hubot/blob/master/scripts/deployer.coffee](https://github.com/goodgrapes/hubot/blob/master/scripts/deployer.coffee)

## Even though it is a Node.js app, we still need bundler for capistrano.

* `$ heroku config:add BUILDPACK_URL=https://github.com/ddollar/heroku-buildpack-multi.git`

## Other Environment Variables (all required)
* GITHUB_OWNER: the owner of the repository (organization or username)
* GITHUB_REPO: the repository you'll be cloning from for the deploy
* KNOWN_HOSTS: Since the Heroku file system doesn't persist, this will be written to the known hosts file. You'll probably need two entries, one for GitHub, one for the machine that Capistrano deploys to.
* HUBOT_ROOM: The room to send messages to via http-post-say
* HUBOT_URL: The URL to your Hubot, with trailing slash (i.e http://bot.foo.com/)
* PRIVATE_KEY: The private key needed to connect to both github and the deploy machine (again because non persistent file system)
