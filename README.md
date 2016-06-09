grouper
=======
Reads in a CSV file and assigns unique ID's based on a set of matching columns.

usage
-----
There is a `Dockerfile` and a `docker-compose.yml` available to make running the app easier.  If using Docker, the `.csv` will need to be located in the current directory.

### Docker
```shell
$ docker build -t t3hpr1m3/grouper .
$ docker run --rm -it --name grouper t3hpr1m3/grouper -m field1,field2 input.csv > output.csv
```

### docker-compose
```shell
$ docker-compose run app /usr/src/app/bin/grouper -m field1,field2 input.csv > output.csv
```

### with a local ruby installation
```shell
$ bundle install
$ bin/grouper -m field1,field2 input.csv > output.csv
```

License
-------
This code is released under the [MIT License](http://www.opensource.org/licenses/MIT).
