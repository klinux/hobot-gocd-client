Client = require './client'
querystring = require 'querystring'

class PipelineService extends Client

  GOCD_USER = process.env.GOCD_USER
  GOCD_PWD = process.env.GOCD_PWD

  if not GOCD_USER?
    console.warn("hubot-gocd-client has no set user (GOCD_USER is empty)!")

  if not GOCD_PWD?
    console.warn("hubot-gocd-client has no set password for the gocd-user (GOCD_PWD is empty)!")

  constructor: (robot) ->
    super(robot, "/pipelines")
    @auth = 'Basic ' + new Buffer(GOCD_USER + ':' + GOCD_PWD).toString('base64')

  build: (conversation) ->
    pipeline = conversation.match[1]
    revision = conversation.match[2]
    postData = ""

    if revision
      postData = querystring.stringify({
        "materials": [
          {
            "revision": revision
          }
        ],
        "update_materials_before_scheduling": true
      });

    @http.path("/go/api/pipelines/" + pipeline + "/schedule")
    .header('Authorization', @auth)
    .header('X-GoCD-Confirm', 'true')
    .header('Accept', 'application/vnd.go.cd.v1+json')
    .header('Content-Type', 'application/json')
    .post(postData) (err, res, body) ->
      if err
        conversation.reply "Encountered an error :( #{err}"
        return
      if res.statusCode is 202
        conversation.reply 'Yes Sir, pipeline: ' + pipeline + ' has been started'
        return
      if res.statusCode is 404
        conversation.reply 'Im sorry Sir, but i couldn\'t find the pipeline ' + pipeline + ' for you, can you please check the spelling?'
        return
      if res.statusCode is 409
        conversation.reply 'Im sorry Sir, but i couldn\'t start the pipeline ' + pipeline + ' cause it\'s already running!'
        return
      else
        conversation.reply 'Im sorry Sir, something went wrong... ' + body
        return

  pause: (conversation) ->
    pipeline = conversation.match[1]
    console.log conversation.match[2]
    postData = querystring.stringify({
      'pauseCause' : conversation.match[2]
    });
    console.log postData
    @http.path("/go/api/pipelines/" + pipeline + "/pause")
    .header('Authorization', @auth)
    .header('X-GoCD-Confirm', 'true')
    .header("ContentType", "application/x-www-form-urlencoded")
    .post(postData) (err, res, body) ->
      if err
        conversation.reply "Encountered an error :( #{err}"
        return
      if res.statusCode is 200
        conversation.reply 'I paused the pipeline ' + pipeline + ' for you'
        return
      if res.statusCode is 404
        conversation.reply "Could not find pipeline " + pipeline
      else
        conversation.reply 'Im sorry Sir, something went wrong... ' + body
        return

  unpause: (conversation) ->
    pipeline = conversation.match[1]
    @http.path("/go/api/pipelines/" + pipeline + "/unpause")
    .header('Authorization', @auth).header('X-GoCD-Confirm', 'true')
    .post() (err, res, body) ->
      if err
        conversation.reply "Encountered an error :( #{err}"
        return
      if res.statusCode is 200
        conversation.reply 'I unpaused the pipeline ' + pipeline + ' for you.'
        return
      if res.statusCode is 404
        conversation.reply "Could not find pipeline " + pipeline
      else
        conversation.reply 'Im sorry Sir, something went wrong... ' + body
        return

  getStatus: (conversation) ->
    pipeline = conversation.match[1]
    conversation.reply "getting status for pipeline " + pipeline

  release: (conversation) ->
    pipeline = conversation.match[1]
    conversation.reply "releasing lock for pipeline " + pipeline

module.exports = PipelineService
