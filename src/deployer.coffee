Express = require 'express'
Router  = require './router'

class Deployer
  constructor: ->
    @app    = new Express
    @router = new Router(@app)

    port = process.env.PORT || 3000

    @app.listen port
    console.log "Listening on port #{port}"

module.exports = Deployer
