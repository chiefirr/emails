backend_service := backend
dev-dockerfile := -f docker-compose.yml

help:
	@echo "Please use 'make <target>' - where <target> is one of the following commands."
	@echo "build-dev                to build and run a development version"
	@echo "migrations               to make migrations and run them after changing Django models"
	@echo "test                     to run tests on the backend"
	@echo "coverage                 to show tests coverage of the project"
	@echo "flush-db                 to flush project database"
	@echo "backend-bash             to connect to a running backend server via bash"
	@echo "clean                    to remove project-related docker images and volumes"

### Build & start app ###

.PHONY: build-dev
build-dev:
	docker-compose $(dev-dockerfile) build

### The following require the backend container to be up ###

.PHONY: migrations
migrations:
	docker-compose exec $(backend_service) bash -c "./manage.py makemigrations; ./manage.py migrate"

.PHONY: backend-bash
backend-bash:
	docker-compose exec $(backend_service) bash -l

### The following require the backend container to be up in development mode (production version will have no needed libraries) ###

.PHONY: test
test:
	docker-compose exec $(backend_service) bash -c "pytest"

.PHONY: coverage
coverage:
	docker-compose exec $(backend_service) bash -c "pytest --cov-config setup.cfg --cov=emails emails/core/tests/"

.PHONY: flush-db
flush-db:
	docker-compose exec $(backend_service) bash -c "./manage.py flush"

### Utilities ###

.PHONY: clean
clean:
	docker-compose down -v --rmi all --remove-orphans