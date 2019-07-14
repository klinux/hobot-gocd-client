Client = require './client'
querystring = require 'querystring'

class ConfigRepoService extends Client

  GOCD_USER = process.env.GOCD_USER
  GOCD_PWD = process.env.GOCD_PWD

  if not GOCD_USER?
    console.warn("hubot-gocd-client has no set user (GOCD_USER is empty)!")

  if not GOCD_PWD?
    console.warn("hubot-gocd-client has no set password for the gocd-user (GOCD_PWD is empty)!")

  constructor: (robot) ->
    super(robot, "/go/api/dashboard")
    @auth = 'Basic ' + new Buffer(GOCD_USER + ':' + GOCD_PWD).toString('base64')

  list_all: (conversation) ->
    @http.path("/go/api/admin/config_repos")
    .header('Accept', 'application/vnd.go.cd.v2+json')
    .header('Authorization', @auth)
    .get() (err, res, body) ->
      if err
        conversation.reply "Encountered an error :( #{err}"
        return
      if res.statusCode is 200
        response = ""
        material = ""
        try
          data = JSON.parse body
          for config in data._embedded.config_repos
            id = config.id
            type = config.plugin_id
            repo = config.material.attributes.url
            response += "\t*id*: #{id}\n\t*repo*: \"#{repo}\"\n\t*type*: #{type}\n"
          conversation.reply "\n*Lista de Configs Repo:*\n #{response}"
        catch error
          conversation.reply error
        return
      if res.statusCode is 404
        conversation.reply 'Desculpe-me não consegui buscar a lista de config repos'
        return
      else
        conversation.reply 'Desculpe-me alguma coisa deu errado... ' + body
        return

  list: (conversation) ->
    name = conversation.match[1]
    @http.path("/go/api/admin/config_repos")
    .header('Accept', 'application/vnd.go.cd.v2+json')
    .header('Authorization', @auth)
    .get() (err, res, body) ->
      if err
        conversation.reply "Encountered an error :( #{err}"
        return
      if res.statusCode is 200
        response = ""
        material = ""
        try
          data = JSON.parse body
          for config in data._embedded.config_repos
            if config.id is name
              id = config.id
              type = config.plugin_id
              repo = config.material.attributes.url
              response += "\t*id*: #{id}\n\t*repo*: \"#{repo}\"\n\t*type*: #{type}\n"
          conversation.reply "\n*Config Repo:*\n #{response}"
        catch error
          conversation.reply error
        return
      if res.statusCode is 404
        conversation.reply 'Desculpe-me não consegui buscar a lista de config repos'
        return
      else
        conversation.reply 'Desculpe-me alguma coisa deu errado... ' + body
        return

  add: (conversation) ->
    id = conversation.match[1]
    plugin_id = conversation.match[2]
    type = conversation.match[3]
    repo = conversation.match[4]
    pattern = conversation.match[5]
    username = conversation.match[6]
    password = conversation.match[7]
    branch = conversation.match[8]

    if branch is "-"
      branch = "master"
    
    if username is "-" or password is "-"
      username = ""
      password = ""

    if plugin_id is "yaml"
      patternType = "file_pattern"
    else
      patternType = "pipeline_pattern"

    if pattern isnt "-"
      postData = JSON.stringify({
        "id": "#{id}",
        "plugin_id": "#{plugin_id}.config.plugin",
        "material": {
          "type": "#{type}",
          "attributes": {
            "url": "#{repo}",
            "username": "#{username}",
            "password": "#{password}",
            "branch": "#{branch}",
            "auto_update": true
          }
        },
        "configuration": [{
            "key": "#{patternType}",
            "value": "#{pattern}"
          }]
        });
    else
        postData = JSON.stringify({
          "id": "#{id}",
          "plugin_id": "#{plugin_id}.config.plugin",
          "material": {
            "type": "#{type}",
            "attributes": {
              "url": "#{repo}",
              "username": "#{username}",
              "password": "#{password}",
              "branch": "#{branch}",
              "auto_update": true
            }
          },
          "configuration": []
          });     
    
    @http.path("/go/api/admin/config_repos")
    .header('Accept', 'application/vnd.go.cd.v2+json')
    .header('Content-Type', 'application/json')
    .header('Authorization', @auth)
    .post(postData) (err, res, body) ->
      if err
        conversation.reply "Encountered an error :( #{err}"
        return
      if res.statusCode is 200
        response = ""
        try
          data = JSON.parse body
          id = data.id
          type = data.plugin_id
          repo = data.material.attributes.url
          response = "\t*id*: #{id}\n\t*repo*: \"#{repo}\"\n\t*type*: #{type}\n"
          conversation.reply "\n*Config Repo Created:*\n #{response}"
        catch error
          conversation.reply error
        return
      if res.statusCode is 404
        conversation.reply 'Desculpe-me não consegui buscar a lista de config repos'
        return
      else
        conversation.reply 'Desculpe-me alguma coisa deu errado... ' + body
        return

module.exports = ConfigRepoService
