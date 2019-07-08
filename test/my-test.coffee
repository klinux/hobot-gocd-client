Helper = require('hubot-test-helper')
helper = new Helper('../src/gocd-client.coffee')

Promise= require('bluebird')
co     = require('co')
expect = require('chai').expect

#describe 'version', ->
#  beforeEach ->
#    @room = helper.createRoom()
#
#  context 'user asks for version', ->
#    beforeEach ->
#      co =>
#        yield @room.user.say 'badger', 'hubot gocd version'
#        yield new Promise.delay(100)
#
#    it 'expects hubot to answer with version number', ->
#      expect(@room.messages).to.eql [
#        ['badger', 'hubot gocd version']
#        ['hubot', '@badger 16.12.0']
#      ]
#
#  afterEach ->
#    @room.destroy()
