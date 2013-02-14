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

    express.post '/ping', (req, res) ->
      res.send 'PONG!'

module.exports = Router
