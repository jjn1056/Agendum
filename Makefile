#
# makefile to help find your way around
#

NAMESPACE := Agendum
LC_NAMESPACE := $(shell echo $(NAMESPACE) | tr 'A-Z' 'a-z')
PID_FILE := /var/$(LC_NAMESPACE)_app_server.pid
STATUS_FILE := /var/$(LC_NAMESPACE)_app_server.status
WEB_SERVER_PORT := 5000
SERVER_MAX_WORKERS := 5 # set to low for development
SERVER_TIMEOUT := 900


.PHONY: help update-cpanlib update-db update-all dependencies \
        server-start server-stop server-restart stack-start stack-stop stack-restart \
        up stop restart build app-shell db-shell db-psql \
        app-update-all app-server-restart app-server-stop app-server-start app-dependencies app-prove

help:
	@echo ""
	@echo "Available commands"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

#### Maintain the CPAN libraries and the database

update-cpanlib: ## Install CPAN libs
	@echo "Installing CPAN libs..."
	@cpanm --mirror http://cpan.cpantesters.org/ --mirror-only --notest --installdeps .
	@echo "Done!"

update-db: ## Deploy Sqitch
	@echo "Running database migrations..."
	@env PGHOST=$(DB_HOST) PGPORT=$(DB_PORT) PGPASSWORD=$(POSTGRES_PASSWORD) \
	 PGUSER=$(POSTGRES_USER) PGDATABASE=$(POSTGRES_DB) sqitch deploy
	@echo "Done!"

update-all: update-cpanlib update-db ## Install CPAN libs and deploy Sqitch

#### Dependency management.  Please note that this isn't perfect since
#### Perl is a dynamic language and dependencies can be loaded at runtime.
#### The cpanfile should indicate dependencies that are not found by this
#### and need to be curated manually.

dependencies: ## List current dependencies
	@seen=""; \
	scan-perl-prereqs lib | grep -Ev '^(strict|warnings|$(NAMESPACE).*)$$'  | sort | while read -r module; do \
	  tarball=$$(cpanm --info "$$module"); \
	  proto=$$(echo "$$tarball" | perl -ne 'print "$$1:$$2" if /\/(.*)-(\d+(?:\.\d+)*)\.tar\.gz$$/'); \
	  main_module=$$(echo "$$proto" | perl -ne 'print "$$1" if /^(.+?):/' | perl -pe 's/-/::/g'); \
	  version=$$(echo "$$proto" | perl -ne 'print "$$1" if /:(.+?)$$/'); \
	  if [ -n "$$version" ] && ! echo "$$seen" | grep -q "|$$main_module|"; then \
	    seen="$$seen |$$main_module|"; \
	    echo "requires '$$main_module', '$$version';"; \
	  fi; \
	done

#### Control the application server

test: ## Run the test suite
	@echo "Done!"

server-start: ## Start the web application (current shell)
	@echo "Starting web application..."
	@start_server --port $(WEB_SERVER_PORT) --pid-file=$(PID_FILE) --status-file=$(STATUS_FILE) -- \
		perl -Ilib \
		  -I extlib/TemplateEmbeddedPerl/lib \
		  ./lib/$(NAMESPACE)/PSGI.pm run \
		    --server Starman \
			--max-workers $(SERVER_MAX_WORKERS) \
			--preload-app $(NAMESPACE) \
		    --timeout $(SERVER_TIMEOUT) \
		    --max-reqs-per-child 1000 \
		    --min-reqs-per-child 800
	@echo "Started."

server-stop: ## Stop the web application (current shell)
	@echo "Stopping web application..."
	@start_server --pid-file=$(PID_FILE) --status-file=$(STATUS_FILE) --stop
	@echo "Stopped."

server-restart: ## Restart the web application (current shell)
	@echo "Restarting web application..."
	@start_server --pid-file=$(PID_FILE) --status-file=$(STATUS_FILE) --restart
	@echo "Restarted."

#### Stack commands

stack-start: update-all server-start ## Start the stack

stack-stop: server-stop ## Stop the stack

stack-restart: update-all server-restart ## Restart the stack

#### The rest of these run on the host machine and allow 
#### you to interact with the docker containers.  Its best
#### practice to limit what actually runs on the host and
#### instead run commands inside the containers.

#### Container build and control

up: prune ## Start the docker containers
	@DOCKER_BUILDKIT=1 docker-compose up -d --build --force-recreate
	@echo "Started application. Visit http://localhost:$(WEB_SERVER_PORT)/"

stop: ## Stop the docker containers
	@docker-compose stop

restart: stop up ## Restart the docker containers

build: prune ## Rebuild the docker image
	@echo "Building the docker image..."
	@DOCKER_BUILDKIT=1 docker-compose build

prune:  ## Prune the docker system
	@echo "Pruning the docker system..."
	@docker system prune -f --volumes

#### Open shells and similar in the containers

app-shell: ## Open a shell in the app container
	@docker-compose exec app_$(LC_NAMESPACE) bash

db-shell: ## Open a shell in the db container
	@docker-compose exec db_$(LC_NAMESPACE) bash

# Open a psql shell in the container

db-psql: ## Open a psql shell in the db container
	@docker-compose exec db_$(LC_NAMESPACE) psql -U $(LC_NAMESPACE)_dbuser agendum

#### Server control

app-update-all: ## Run 'make update-all' inside the app container
	@docker-compose exec app_$(LC_NAMESPACE) make update-all

app-server-restart: ## Run 'make server-restart' inside the app container
	@docker-compose exec app_$(LC_NAMESPACE) make server-restart

app-server-stop: ## Run 'make server-stop' inside the app container
	@docker-compose exec app_$(LC_NAMESPACE) make server-stop

app-server-start: ## Run 'make server-start' inside the app container
	@docker-compose exec app_$(LC_NAMESPACE) make server-start

app-dependencies: ## Run 'make dependencies' inside the app container
	@docker-compose exec app_$(LC_NAMESPACE) make dependencies

#### Testing

prove: ## Run 'prove' inside the app container
	docker-compose exec app_$(LC_NAMESPACE) prove -lvr $(filter-out app-prove,$(MAKECMDGOALS))
