class Client

  constructor: (robot) ->
    console.log process.env.GOCD_HOST
    @http = robot.http(process.env.GOCD_HOST)

module.exports = Client


