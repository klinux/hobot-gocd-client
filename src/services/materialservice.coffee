Client = require './client'

class MaterialService extends Client

  constructor: (robot) ->
    super(robot)

  get: (conversation) ->
    @http
    .header('Accept', 'application/vnd.go.cd.v1+json; charset=utf-8')
    .path("/go/api/config/materials")
    .get() (err, res, body) ->
      if err
        conversation.reply "Um erro foi encontrado :( #{err}"
        return
      data = JSON.parse(body)
      response = ""
      response += "#{data.description} #{data.fingerprint}\n"
      console.log response
      conversation.reply "Lista de Materials\n" + response

module.exports = MaterialService
