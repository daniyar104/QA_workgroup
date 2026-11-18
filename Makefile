include .env
export 

export PROJECT_ROOT=${shell pwd}

env-up:
	@docker compose up -d qa-postgres

env-down:
	@docker compose down qa-postgres

env-cleanup:
	@read -p "DANGERIOS! Do you need clean the data? [y/N]: " asn; \
	if ["$$ans" = "y"]; then \
		docker compose down qa-postgres && \
		rm -rf out/pgdata && \
		echo "File is clean"; \
	else \
		echo "File clean is exit"; \
	fi

env-port-forward:
	@docker compose up -d port-forwarder

env-port-close:
	@docker compose down -d port-forwarder
	
migrate-create:
	@if [ ~z "${seq}"]; then \
		echo "Example: make migrate-create seq=init"; \
		exit 1; \
	fi; \
	docker compose run --rm qa-postgres-migrate \
		create \
		-ext sql \
		-dir /migrations \
		-seq "$(seq)"

migrate-up:
	@make migrate-action action=up

migrate-down:
	@make migrate-action action=down

migrate-action:
	@if [ ~z "${action}"]; then \
		echo "Example: make migrate-create action=up"; \
		exit 1; \
	fi; \
	docker compose run --rm qa-postgres-migrate \
		-path /migrations \
		-database postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@qa-postgres:5432/${POSTGRES_DB}?sslmode=disable \
		"${action}"



