Client = require './client'
querystring = require 'querystring'

class PipelineGroupService extends Client

  GOCD_USER = process.env.GOCD_USER
  GOCD_PWD = process.env.GOCD_PWD

  if not GOCD_USER?
    console.warn("hubot-gocd-client has no set user (GOCD_USER is empty)!")

  if not GOCD_PWD?
    console.warn("hubot-gocd-client has no set password for the gocd-user (GOCD_PWD is empty)!")

  constructor: (robot) ->
    super(robot, "/go/api/dashboard")
    @auth = 'Basic ' + new Buffer(GOCD_USER + ':' + GOCD_PWD).toString('base64')

  list: (conversation) ->
    @http.path("/go/api/config/pipeline_groups")
    .header('Authorization', @auth)
    .get() (err, res, body) ->
      if err
        conversation.reply "Encountered an error :( #{err}"
        return
      if res.statusCode is 200
        response = ""
        try
          data = JSON.parse body
          for pipeGroup in data
            for pipe in pipeGroup.pipelines
              pipelineName = pipe.name.toUpperCase()
              response += "#{pipelineName}\n"
          conversation.reply "\n*Lista de Pipelines:*\n #{response}"
        catch error
          conversation.reply error
        return
      if res.statusCode is 404
        conversation.reply 'Desculpe-me não consegui buscar a lista de pipelines.'
        return
      else
        conversation.reply 'Desculpe-me alguma coisa deu errado... ' + body
        return

  materials: (conversation) ->
    pipeline = conversation.match[1]
    @http.path("/go/api/config/pipeline_groups")
    .header('Authorization', @auth)
    .get() (err, res, body) ->
      if err
        conversation.reply "Encountered an error :( #{err}"
        return
      if res.statusCode is 200
        response = ""
        try
          data = JSON.parse body
          if pipeline
            for pipeGroup in data
              for pipe in pipeGroup.pipelines
                if pipe.name is pipeline
                  pipelineName = pipe.name.toUpperCase()
                  for material in pipe.materials
                    fingerprint = material.fingerprint
                    description = material.description
                    type = material.type
                    response += "\n> #{pipeGroup.name}\n\t*pipeline*: #{pipelineName}\n\t*fingerprint*: #{fingerprint}\n\t*description*: \"#{description}\"\n\t*type*: #{type}"
          else
            for pipeGroup in data
              for pipe in pipeGroup.pipelines
                pipelineName = pipe.name.toUpperCase()
                for material in pipe.materials
                  fingerprint = material.fingerprint
                  description = material.description
                  type = material.type
                  response += "\n> #{pipeGroup.name}\n\t*pipeline*: #{pipelineName}\n\t*fingerprint*: #{fingerprint}\n\t*description*: \"#{description}\"\n\t*type*: #{type}"
          conversation.reply response
        catch error
          conversation.reply error
        return
      if res.statusCode is 404
        conversation.reply 'Lamento, mas não foi possível requisitar a página solicitada.'
        return
      else
        conversation.reply 'Desculme-me alguma coisa de errado... ' + body
        return

module.exports = PipelineGroupService
