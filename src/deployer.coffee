Express         = require 'express'
Router          = require './router'
ChildProcess    = require 'child_process'
HttpClient      = require 'scoped-http-client'
QueryString     = require 'querystring'
Async           = require 'async'

class Deployer
  constructor: ->
    @express    = new Express
    @router     = new Router(this)
    @status     = 'idle'

    @options =
      hubot_say:  "#{process.env.HUBOT_URL}hubot/say"
      hubot_room: process.env.HUBOT_ROOM
      repo:       process.env.GITHUB_REPO
      owner:      process.env.GITHUB_OWNER

    ChildProcess.exec 'mkdir -p .ssh && echo "$PRIVATE_KEY" > .ssh/id_rsa && echo "$KNOWN_HOSTS" > .ssh/known_hosts', @logger

    port = process.env.PORT || 3000

    @express.listen port
    console.log "Listening on port #{port}"

  success: ->
    @message "Deployed to production"
    @status = 'idle'

  fail: ->
    @status = 'idle'
    @message 'Deploy Failed'

  http: (url) ->
    HttpClient.create(url)

  message: (message) ->
    data =
      room: @options.hubot_room
      message: message

    @http(@options.hubot_say).header('Content-Type', 'application/x-www-form-urlencoded').post(QueryString.stringify(data))

  logger: (error, stdout, stderr) =>
    console.log "exec: stdout: #{stderr}"
    console.log "exec: stderr: #{stdout}"
    console.log('exec: error: ' + error) if error

  getStatus: ->
    @message "Deploy status is #{@status}"

  deploy: ->
    if @status == 'idle'
      @message "Deploying to production"
    else
      @message "Deploy already in progress"
      return false

    @status = 'deploying'
    @prepare => @capistrano('deploy')
    true

  rollback: ->
    if @status == 'idle'
      @message "Rolling back deploy"
    else
      @message "Can't rollback, deploy in progress."
      return false

    @status = 'deploying'
    @prepare => @capistrano('rollback')
    true

  prepare: (success) ->
    series = [
      Async.apply(@clone, "git@github.com:#{@options.owner}/#{@options.repo}.git"),
      @bundle
    ]
    Async.series series, (error) => if error then @fail() else success()

  clone: (url, callback) =>
    child = ChildProcess.exec "cd tmp/repo && git pull || git clone #{url} tmp/repo", @logger
    child.on 'exit', (code) => if code == 0 then callback() else callback('clone failed')

  bundle: (callback) ->
    child = ChildProcess.exec "cd tmp/repo && bundle install", @logger
    child.on 'exit', (code) => if code == 0 then callback() else callback('bundle failed')

  capistrano: (mode = 'deploy') =>
    console.log "Calling capistrano"
    if mode == "deploy"
      child = ChildProcess.exec "cd tmp/repo && bundle exec cap deploy", @logger
    else
      child = ChildProcess.exec "cd tmp/repo && bundle exec cap deploy:rollback", @logger

    child.on 'exit', (code) => if code == 0 then @success() else @fail()

module.exports = Deployer
