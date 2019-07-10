# hubot-gocd-client [![Build Status](https://travis-ci.org/Tandolf/hubot-gocd-client.svg?branch=master)](https://travis-ci.org/Tandolf/hubot-gocd-client)

a gocd client that lets you control gocd from hubot

See [`src/gocd-client.coffee`](src/gocd-client.coffee) for full documentation.

## Build Image
docker build -t marvin . --no-cache

## Run Image
docker run -d -p 8080:8080 -e HUBOT_SLACK_TOKEN=<token> -e GOCD_HOST=<go_url> -e GOCD_USER=<go_user> -e GOCD_PWD=<go_pwd> marvin

## Installation

In hubot project repo, run:

`npm install hubot-gocd-client --save`

Then add **hubot-gocd-client** to your `external-scripts.json`:

```json
[
  "hubot-gocd-client"
]
```

## Sample Interaction

```
user1>> hubot hello
hubot>> hello!
```

## TODO
Create module inside npm repository.
