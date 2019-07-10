FROM node:lts-slim
MAINTAINER  Marvin

WORKDIR /root
RUN npm install -g yo generator-hubot
RUN apt-get update
RUN apt-get install git vim -y

RUN useradd -ms /bin/bash marvin
ENV HOME /home/marvin

USER marvin
WORKDIR /home/marvin
RUN echo n | yo hubot --defaults
RUN npm install hubot-slack hubot-scripts https://github.com/klinux/hobot-gocd-client.git --save
RUN rm -f hubot-scripts.json

# enable plugins
RUN echo [ \"hubot-gocd-client\" ] > external-scripts.json

CMD ["/home/marvin/bin/hubot", "--name", "marvin", "-a", "slack"]

EXPOSE 8080