VersionService = require './services/versionservice'
PipelineService = require './services/pipelineservice'

# Description
#   a script that makes it possible to communicate with gocd
#
# Configuration:
#   GOCD_HOST - the host adress of GOCD (example: http://127.0.0.1:8080)
#
# Commands:
#   hubot gocd version - Will answer with the version of GOCD
#   hubot gocd build <pipeline> - Triggers a pipeline with the given name
#
# Notes:
#   user is hardcoded at the moment
#
# Author:
#   Thomas Andolf <thomas.andolf@gmail.com>GOCD_USER = process.env.GOCD_USER

module.exports = (robot) ->

  robot.respond /hello/, (res) ->
    res.reply 'hello!'

  robot.hear /orly/, (res) ->
    res.send 'yarly'

  robot.respond /gocd version/i, (conversation) ->
    versionService = new VersionService(robot);
    versionService.get conversation;

  robot.respond /gocd build (.*)/i, (conversation) ->
    pipelineService = new PipelineService(robot);
    pipelineService.build(conversation);

  robot.respond /gocd pause (.*)/i, (conversation) ->
    pipelineService = new PipelineService(robot);
    pipelineService.pause(conversation);

  robot.respond /gocd unpause (.*)/i, (conversation) ->
    pipelineService = new PipelineService(robot);
    pipelineService.unpause(conversation);

  robot.respond /gocd status (.*)/i, (conversation) ->
    pipelineService = new PipelineService(robot);
    pipelineService.getStatus(conversation);

  robot.respond /gocd release (.*)/i, (conversation) ->
    pipelineService = new PipelineService(robot);
    pipelineService.release(conversation);


