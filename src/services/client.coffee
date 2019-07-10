class Client

  options = rejectUnauthorized: false
  constructor: (robot) ->
    console.log process.env.GOCD_HOST
    @http = robot.http(process.env.GOCD_HOST, options)

module.exports = Client


