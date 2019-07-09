Client = require './client'

class HealthService extends Client

  constructor: (robot) ->
    super(robot)

  get: (conversation) ->
    @http
    .header('Accept', 'application/vnd.go.cd.v1+json; charset=utf-8')
    .path("/go/api/v1/health")
    .get() (err, res, body) ->
      if err
        conversation.reply "Encountered an error :( #{err}"
        return
      data = JSON.parse body
      if data.health is "OK"
        conversation.reply "GOCD is healthy"
      else
        conversation.reply "GOCD is down"

module.exports = HealthService
