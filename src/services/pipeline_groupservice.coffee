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
    @http.path("/go/api/dashboard")
    .header('Authorization', @auth).header('Accept', 'application/vnd.go.cd.v3+json')
    .get() (err, res, body) ->
      if err
        conversation.reply "Encountered an error :( #{err}"
        return
      if res.statusCode is 200
        response = ""
        try
          content = JSON.parse(body)
          for pipes in content.pipelines
            index = jobList.indexOf(pipes.name)
            if index == -1
              jobList.push(pipes.pipeline_groups)
              index = jobList.indexOf(pipes.name)

            if pipes.pipelines
              for pipe in pipes.pipelines
                if content.pipelines.name is pipe
                  for pipename in content.pipelines
                    pipelines-name = content.pipelines.name
            else
              pipeline-names is ""
          
            if (filter.test pipes.name)
              response += "[#{index + 1}] #{pipes.names} #{pipelines-name}\n"
          conversation.reply response
        catch error
          conversation.reply error
        return
      if res.statusCode is 404
        conversation.reply 'Im sorry Sir, but i couldn\'t find any list of pipelines'
        return
      else
        conversation.reply 'Im sorry Sir, something went wrong... ' + body
        return

module.exports = PipelineGroupService
