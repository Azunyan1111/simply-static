.PHONY: zip

zip:
	rm ./simply-static.zip
	@echo "Creating ZIP file..."
	@cd ../ && zip -r ./simply-static/simply-static.zip simply-static/ --exclude=*github/* --exclude=*git/* --exclude=*idea/* --exclude=*wp-cli.phar* --exclude=*simply-static.zip* --exclude=*tmp/*
	@echo "ZIP file created successfully."

# su -s /bin/bash -c "ps aux" www-data

# TODO:このプラグイン自体が不完全なので使えない

up: zip
	docker stop some-wordpress
	docker rm -f some-wordpress
	docker stop some-mysql
	docker rm -f some-mysql
	docker run --platform=linux/arm64 --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -e MYSQL_DATABASE=wordpress -p 3306:3306 -d mysql:8.0.36
	sleep 6
	docker run --name some-wordpress --link some-mysql:mysql -p 80:80 -e WORDPRESS_DB_HOST=mysql -e WORDPRESS_DB_USER=root -e WORDPRESS_DB_PASSWORD=my-secret-pw -e WORDPRESS_DB_NAME=wordpress -d wordpress:6.5.3
	docker cp ./wp-cli.phar some-wordpress:/usr/local/bin/wp
	docker exec some-wordpress /bin/bash -c "su -s /bin/bash -c 'wp core install --url=localhost --title=Example --admin_user=admin --admin_password=passwordbdnjisadlans --admin_email=a@a.com' www-data"
	# 権限を与える
	docker exec some-wordpress /bin/bash -c "chown -R www-data:www-data /var/www/html/wp-content"
	# install theme
	docker exec some-wordpress /bin/bash -c "mkdir -p /tmp/wp-themes/"
	docker cp ./simplicity2.8.9.zip some-wordpress:/tmp/wp-themes/
	docker exec some-wordpress /bin/bash -c "su -s /bin/bash -c 'wp theme install /tmp/wp-themes/simplicity2.8.9.zip --activate' www-data"
	# copy plugin
	docker exec some-wordpress /bin/bash -c "mkdir -p /tmp/wp-plugins/"
	docker cp ./simply-static.zip some-wordpress:/tmp/wp-plugins/
	# 権限を与える /var/www/html/out/
	docker exec some-wordpress /bin/bash -c "mkdir -p /var/www/html/out/"
	docker exec some-wordpress /bin/bash -c "chown -R www-data:www-data /var/www/html/out/"
	# install plugin
	docker exec some-wordpress /bin/bash -c "su -s /bin/bash -c 'wp plugin install /tmp/wp-plugins/simply-static.zip --activate' www-data"
	docker exec some-wordpress /bin/bash -c "su -s /bin/bash -c 'wp simply init /var/www/html/out/' www-data"
	docker exec some-wordpress /bin/bash -c "su -s /bin/bash -c 'wp simply build' www-data"
	docker exec some-wordpress /bin/bash -c "su -s /bin/bash -c 'wp simply wait' www-data"
	docker cp some-wordpress:/var/www/html/out/ ./tmp


