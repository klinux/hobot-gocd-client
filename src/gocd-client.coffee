VersionService = require './services/versionservice'
PipelineService = require './services/pipelineservice'
HealthService = require './services/healthservice'
DashboardService = require './services/dashboardservice'

# Description
#   a script that makes it possible to communicate with gocd
#
# Configuration:
#   GOCD_HOST - the host adress of GOCD (example: http://127.0.0.1:8080)
#   GOCD_USER - Username to connect with GOCD
#   GOCD_PWD - Password to connect with GOCD
#
# Commands:
#   hubot gocd version - Will answer with the version of GOCD
#   hubot gocd build <pipeline> - Triggers a pipeline with the given name
#   hubot gocd list - List all pipelines
#   hubot gocd add repository name git_path - Add repository with pipeline as code
#
# Notes:
#   user is hardcoded at the moment
#
# Original Author:
#   Thomas Andolf <thomas.andolf@gmail.com>
# Changed by:
#   Kleber Rocha <klinux@gmail.com>

module.exports = (robot) ->

  robot.respond /hello/, (res) ->
    res.reply 'hello!'

  robot.hear /orly/, (res) ->
    res.send 'yarly'

  robot.respond /gocd version/i, (conversation) ->
    versionService = new VersionService(robot);
    versionService.get conversation;

  robot.respond /gocd health/i, (conversation) ->
    healthService = new HealthService(robot);
    healthService.get conversation;

  robot.respond /gocd list/i, (conversation) ->
    dashboardService = new DashboardService(robot);
    dashboardService.list(conversation);
 
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


