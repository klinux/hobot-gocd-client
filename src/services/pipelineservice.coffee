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
    fingerprint = conversation.match[2]
    revision = conversation.match[3]
    postData = ""

    if revision
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
        conversation.reply 'Desculpe-me alguma coisa deu errado... ' + body
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
        conversation.reply 'Desculpe-me alguma coisa deu errado... ' + body
        return

  getStatus: (conversation) ->
    pipeline = conversation.match[1]
    @http.path("/go/api/pipelines/" + pipeline + "/status")
    .header('Authorization', @auth)
    .get() (err, res, body) ->
      if err
        conversation.reply "Encountered an error :( #{err}"
        return
      if res.statusCode is 200
        status = ""
        try
          data = JSON.parse body

          paused = data.paused
          schedulable = data.schedulable
          locked = data.locked

          if paused
            status = "Pausado por: #{data.pausedBy}, motivo: #{data.pauseCause}"
            
          if not schedulable and not locked
            status = "O pipeline esta em execução."

          if locked
            status = "O pipeline esta bloqueado."

          if not locked and not paused and schedulable
            status = "O pipeline esta pronto para ser executado."

          conversation.reply "\n*Pipeline Status:*\n #{status}"
        catch error
          conversation.reply error
        return
      if res.statusCode is 404
        conversation.reply 'Desculpe-me não consegui buscar os status do pipeline'
        return
        
      else
        conversation.reply 'Desculpe-me alguma coisa deu errado... ' + body
        return

  release: (conversation) ->
    pipeline = conversation.match[1]
    @http.path("/go/api/pipelines/" + pipeline + "/unlock")
    .header('Accept', 'application/vnd.go.cd.v1+json')
    .header('Authorization', @auth)
    .header('X-GoCD-Confirm', 'true')
    .post() (err, res, body) ->
      if err
        conversation.reply "Encountered an error :( #{err}"
        return
      if res.statusCode is 200
        conversation.reply 'O ' + pipeline + ' foi desbloqueado para você.'
        return
      if res.statusCode is 404
        conversation.reply "Não foi possível encontrar o pipeline: " + pipeline
      else
        conversation.reply 'Desculpe-me alguma coisa deu errado... ' + body
        return

module.exports = PipelineService
