Client = require './client'

class VersionService extends Client

  constructor: (robot) ->
    super(robot)

  get: (conversation) ->
    @http
    .header('Accept', 'application/vnd.go.cd.v1+json')
    .path("/go/api/version")
    .get() (err, res, body) ->
      if err
        conversation.reply "Encountered an error :( #{err}"
        return
      data = JSON.parse body
      conversation.reply data.version

module.exports = VersionService
