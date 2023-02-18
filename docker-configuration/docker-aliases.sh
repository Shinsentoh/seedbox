############################################################################
#                                                                          #
#               ------- Useful Docker Aliases --------                     #
#                                                                          #
#     # Installation :                                                     #
#     copy/paste these lines into your .bashrc or .zshrc file or just      #
#                                                                          #
#     # Usage:                                                             #
#     dc             : docker-compose                                      #
#     dcu            : docker-compose up -d                                #
#     dcd            : docker-compose down                                 #
#     dtl            : docker truncate logs                                #
#     dex <container>: execute a bash shell inside the RUNNING <container> #
#     di <container> : docker inspect <container>                          #
#     dip            : IP addresses of all running containers              #
#     dl <container> : docker logs -f <container>                          #
#     dnames         : names of all running containers                     #
#     dpsa           : docker ps -a                                        #
#     drmdi          : remove all dangling images                          #
#     dsp            : Remove all unused containers, networks,             #
#                      images (both dangling and unreferenced)             #
#                                                                          #
############################################################################

function dnames-fn {
	for ID in `docker ps | awk '{print $1}' | grep -v 'CONTAINER'`
	do
    docker inspect $ID | grep Name | head -1 | awk '{print $2}' | sed 's/,//g' | sed 's%/%%g' | sed 's/"//g'
	done
}

function dip-fn {
  echo "IP addresses of all named running containers"

  for DOC in `dnames-fn`
  do
    IP=`docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}' "$DOC"`
    OUT+=$DOC'\t'$IP'\n'
  done
  echo -e $OUT | column -t
  unset OUT
}

function dex-fn {
	docker exec -it $1 ${2:-bash}
}

function di-fn {
	docker inspect $1
}

function dl-fn {
	docker logs -f $1
}

function dtl-fn {
  sh -c 'truncate -s 0 /home/docker/containers/*/*-json.log'
}

function dcr-fn {
	docker-compose run $@
}

function dcu-fn {
	docker-compose $(find docker-compose.* | sed -e 's/^/-f /') up -d --remove-orphans
}

function dcd-fn {
	docker-compose $(find docker-compose.* | sed -e 's/^/-f /') down --remove-orphans
}

function drmdi-fn {
  imgs=$(docker images -q -f dangling=true)
  [ ! -z "$imgs" ] && docker rmi "$imgs" || echo "no dangling images."
}

# in order to do things like dex $(dlab label) sh
function dlab {
  docker ps --filter="label=$1" --format="{{.ID}}"
}

function dc-fn {
  docker-compose $*
}

alias dc=dc-fn
alias dcu=dcu-fn
alias dcd=dcd-fn
alias dtl=dtl-fn
alias dex=dex-fn
alias dip=dip-fn
alias dl=dl-fn
alias dnames=dnames-fn
alias dpsa="docker ps -a"
alias drmdi=drmdi-fn
alias drun=drun-fn
alias dsp="docker system prune --all"