all:
	docker compose -f docker-compose.yml up --build -d

down:
	docker compose -f docker-compose.yml down

re: down all

clean:
	docker compose -f docker-compose.yml down -v

fclean: clean
	docker system prune -af

.PHONY: all down re clean fclean