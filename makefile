all:
	docker compose -f srcs/docker-compose.yml up --build -d

down:
	docker compose -f srcs/docker-compose.yml down

re: down all

clean:
	docker compose -f srcs/docker-compose.yml down -v

fclean: clean
	docker system prune -af

.PHONY: all down re clean fclean