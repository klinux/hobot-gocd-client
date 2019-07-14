VersionService = require './services/versionservice'
PipelineService = require './services/pipelineservice'
HealthService = require './services/healthservice'
PipelineGroupService = require './services/pipeline_groupservice'
ConfigRepoService = require './services/configrepo'

# Description:
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
# Author:
#   Thomas Andolf <thomas.andolf@gmail.com>
# Changed by:
#   Kleber Rocha <klinux@gmail.com>

module.exports = (robot) ->

  robot.hear /hello/, (res) ->
    res.reply 'hello!'

  robot.hear /help/, (res) ->
    res.send "\nLista de comandos:\n
    *list all pipelines*: Responde uma lista com todos os pipelines.\n
    *material*: <pipeline-name>: Responde o fingerprint dos repositório de um pipeline.\n
    *materials*: Responde o fingerprint de todos os pipelines.\n
    *config get <name>*: Responde a configuração de um config repo.\n
    *config add <name> <plugin> <type> <url> <pattern> <username> <password> <branch>*: \n
    \tAdiciona uma configuração de pipeline como código: <name>, <json|yaml> <git|svn|hg|p4|tfs> <url>\n
    \t<file_pattern> (use - para deixar em branco ou *.yaml, file.yaml), <username> (use - para deixar em branco)\n
    \t<password> (use - para deixar em branco), branch (use - para deixar em branco, default: master).\n
    *config list all*: Responde a lista de todos os configs repos.\n
    *version*: Responde a versão do GoCD.\n
    *health*: Responde se o GoCD esta saudável.\n"

  robot.hear /version/i, (conversation) ->
    versionService = new VersionService(robot);
    versionService.get conversation;

  robot.hear /health/i, (conversation) ->
    healthService = new HealthService(robot);
    healthService.get conversation;

  robot.hear /list all pipelines/i, (conversation) ->
    pipeline_groupService = new PipelineGroupService(robot);
    pipeline_groupService.list(conversation);

  robot.hear /material (.*)/i, (conversation) ->
    material_groupService = new PipelineGroupService(robot);
    material_groupService.materials(conversation);

  robot.hear /materials/i, (conversation) ->
    material_groupService = new PipelineGroupService(robot);
    material_groupService.materials(conversation);

  robot.hear /build last/i, (conversation) ->
    pipelineService = new PipelineService(robot);
    pipelineService.build(conversation);

  robot.hear /build (.*) (.*) (.*)/i, (conversation) ->
    pipelineService = new PipelineService(robot);
    pipelineService.build(conversation);

  robot.hear /config list all/i, (conversation) ->
    configRepoService = new ConfigRepoService(robot);
    configRepoService.list_all(conversation);

  robot.hear /config get (.*)/i, (conversation) ->
    configRepoService = new ConfigRepoService(robot);
    configRepoService.list(conversation);

  robot.hear /config add (.*) (yaml|json) (git|svn|hg|p4|tfs) (.*) (.*) (.*) (.*) (.*)/i, (conversation) ->
    configRepoService = new ConfigRepoService(robot);
    configRepoService.add(conversation);

  robot.hear /pause (.*)/i, (conversation) ->
    pipelineService = new PipelineService(robot);
    pipelineService.pause(conversation);

  robot.hear /unpause (.*)/i, (conversation) ->
    pipelineService = new PipelineService(robot);
    pipelineService.unpause(conversation);

  robot.hear /status (.*)/i, (conversation) ->
    pipelineService = new PipelineService(robot);
    pipelineService.getStatus(conversation);

  robot.hear /release (.*)/i, (conversation) ->
    pipelineService = new PipelineService(robot);
    pipelineService.release(conversation);


