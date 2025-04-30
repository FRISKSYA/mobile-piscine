.PHONY: all clean fclean shell build restart

all:
	xhost +local:docker
	docker-compose build
	docker-compose up -d

shell:
	docker-compose exec flutter bash

clean:
	docker-compose down

fclean: clean
	docker-compose down -v --remove-orphans
	docker system prune -af --volumes

build:
	docker-compose build --no-cache

restart: clean
	docker-compose up -d