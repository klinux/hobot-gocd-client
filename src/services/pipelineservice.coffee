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
      @http.path("/go/api/config/pipeline_groups")
      .header('Authorization', @auth)
      .get() (err, res, body) ->
        if err
          conversation.reply "Um erro foi encontrado :( #{err}"
          return
        if res.statusCode is 200
          data = JSON.parse body
          for key, value of data
            value_parse = JSON.toString(value)
            console.log "#{key} and #{value}"
            if value is pipeline
              fingerprint = value.materials.fingerprint
              console.log fingerprint
              return fingerprint
      if fingerprint
        postData = JSON.stringify({ 
          "materials": [ 
            { 
              "fingerprint": "#{fingerprint}", 
              "revision": "#{revision}" } 
          ], 
          "update_materials_before_scheduling": true 
        });
      console.log postData

    @http.path("/go/api/pipelines/" + pipeline + "/schedule")
    .header('Authorization', @auth)
    .header('X-GoCD-Confirm', 'true')
    .header('Accept', 'application/vnd.go.cd.v1+json')
    .header('Content-Type', 'application/json')
    .post(postData) (err, res, body) ->
      if err
        conversation.reply "Um erro foi encontrado :( #{err}"
        return
      else if res.statusCode is 202
        conversation.reply 'Ok neoner, seu pipeline: ' + pipeline + ' foi inciado.'
        return
      else if res.statusCode is 404
        conversation.reply 'Lamento neoner, mas não pude achar o pipeline ' + pipeline + ' pra você, você pode confirmar este nome?'
        return
      else if res.statusCode is 409
        conversation.reply 'Lamento neoner, mas eu não pude iniciar o pipeline ' + pipeline + ' causa: ele esta sendo executado!'
        return
      else
        conversation.reply 'Desculpe-me, alguma coisa deu errado... ' + body
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
