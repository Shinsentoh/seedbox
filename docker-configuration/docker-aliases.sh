
# ######################################################################## #
#                                                                          #
#               ------- Useful Docker Aliases --------                     #
#                                                                          #
#     # Installation :                                                     #
#     copy/paste these lines into your .bashrc or .zshrc file or just      #
#                                                                          #
#     # Usage:                                                             #
#     dc             : docker compose                                      #
#     dcu            : docker compose up -d                                #
#     dcd            : docker compose down                                 #
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
# ######################################################################## #

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
  for c in $(docker ps -q); do docker truncate $c --size 0; done
}

function dcr-fn {
	docker compose run $@
}

function dc-stack {
  local STACK="$1"
  shift

  local BASE="{{INSTALL_DIR}}"
  local FILE="$BASE/docker/$STACK/docker-compose.$STACK.yml"

  if [[ ! -f "$FILE" ]]; then
    echo "Stack '$STACK' not found"
    return 1
  fi

  docker compose \
    --env-file "$BASE/.env" \
    --env-file "$BASE/docker/$STACK/.env" \
    -f "$FILE" \
    "$@"
}

function dcu-all-fn {
    local BASE="{{INSTALL_DIR}}/docker"

    local PRIORITY_STACKS=(
        network
        media
        tools
    )

    local STACKS=()

    # stacks prioritaires si elles existent
    for stack in "${PRIORITY_STACKS[@]}"; do
        if [[ -f "$BASE/$stack/docker-compose.$stack.yml" ]]; then
            STACKS+=("$stack")
        fi
    done

    # autres dossiers
    for dir in "$BASE"/*/; do
        local stack
        stack=$(basename "$dir")

        # skip déjà ajoutés
        if [[ " ${STACKS[*]} " =~ " ${stack} " ]]; then
            continue
        fi

        # skip dossiers sans compose
        if [[ ! -f "$BASE/$stack/docker-compose.$stack.yml" ]]; then
            continue
        fi

        STACKS+=("$stack")
    done

    # lancement
    for stack in "${STACKS[@]}"; do
        echo ""
        echo "==================================="
        echo "Starting stack: $stack"
        echo "==================================="

        dcu "$stack"
    done
}

function dcu-fn {
	# OLD: docker compose $(find docker-compose.* | sed -e 's/^/-f /') up -d --remove-orphans $1
  local stack=$1
  shift
  dc-stack $stack up -d --remove-orphans "$@"
}

function dcd-fn {
	# OLD: docker compose $(find docker-compose.* | sed -e 's/^/-f /') down --remove-orphans
  local stack=$1
  shift
  dc-stack $stack down --remove-orphans "$@"
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
  dc-stack $1 $*
}

function dcb-fn {
	dc-stack $1 build --no-cache $2
}

alias dc=dc-fn
alias dcu=dcu-fn
alias dcu-all=dcu-all-fn
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
alias dcb=dcb-fn