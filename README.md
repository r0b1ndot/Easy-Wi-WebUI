# Easy-Wi-WebUI
A Docker container with [Easy Wi](https://easy-wi.com/) WebUI.  
Downloads the newest version of the WebUI from https://easy-wi.com/uk/downloads/

### Build & Run
Clone the repository and build the image.
```
docker build -t easywi-image .
```
Run it..
```
docker run --name easy-wi -p 8282:80 -d easywi-image
```

### Persistent data
Mount the MySQL volume folder and/or the `html` folder.
```
docker run --name easy-wi \
  -p 8282:80 \
  -v ~/easywi-data/html:/var/www/html \
  -v ~/easywi-data/sql:/var/lib/mysql \
  --restart=always \
  -d easywi-image
```

### Using Docker Compose
Using docker compase is properly the easiest way.  
Change directory to the Easy-Wi-WebUI repository.
```
docker-compose up -d
```
Boom.. there you go.  

### MySQL Infomation
The database to use is `easywi`.  
The user is `root` and password is `easywi`.
