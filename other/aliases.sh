#!/bin/bash

# Aliases file to be sourced and used when it might be convenient

alias all-logs="docker ps -q | xargs -P 13 -L 1 docker logs --follow"
alias dockerStopAll="docker stop $(docker ps -a -q)"
alias dockerStartAll="docker start $(docker ps -a -q)"
alias dcUp="docker-compose up -d --remove-orphans"
alias dcDown="docker-compose down --remove-orphans"
