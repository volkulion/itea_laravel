SHELL:=/bin/bash
.DEFAULT_GOAL := init
# put here commands, that have the same name as files in dir
.PHONY: run logs clean kill enter start stop restart refresh-db
# Allows to pass arguments to restart or enter command
# e.g. 'make restart public'. Comma in the end is not the typo.
ifeq (,$(filter $(firstword $(MAKECMDGOALS)), start, stop, restart, kill, logs, run, enter, generate, generation,))
  # use the rest as arguments for Goal command
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)
endif

run: create_network
	docker-compose up $(RUN_ARGS)

logs:
	docker-compose logs --follow $(RUN_ARGS)

start:
	docker-compose start $(RUN_ARGS)

stop:
	-docker-compose stop $(RUN_ARGS)

restart:
	docker-compose restart $(RUN_ARGS)

create_network:
	@docker network inspect itea-test >/dev/null 2>&1 || docker network create --attachable -d bridge --subnet 172.29.0.0/24 itea-test

daemon: create_network
	docker-compose up -d

enter:
	docker-compose exec $(RUN_ARGS) /bin/bash

clean:
	-docker system prune -f

destroy:
	-docker kill $(shell docker ps -q)
	-docker rm $(shell docker ps -a -q)
	-docker rmi -f $(shell docker images -q -f dangling=true)
	-docker rmi -f $(shell docker images -q)
	-docker volume ls -qf dangling=true | xargs docker volume rm
	-docker system prune -f

kill:
	-docker-compose kill $(RUN_ARGAS)
