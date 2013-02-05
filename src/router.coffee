class Router
  constructor: (app) ->
    express = app.express

    express.post '/deploy', (req, res) ->
      res.send(200)
      app.deploy()

    express.post '/rollback', (req, res) ->
      res.send(200)
      app.rollback()

    express.get '/status', (req, res) ->
      res.send(200)
      app.getStatus()

module.exports = Router
