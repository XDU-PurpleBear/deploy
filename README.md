# Configuration

To set up this system, you need to build and install these application:
  * Docker
  * node.js with npm
  * python(2.7)

Some modules have been packaged in docker image form, so if you want to build those module you need to install:
  * ghc-8.2.1 with stack

All of these codes can be compiled or run in the docker images,
so if you want to use the Docker to compile the codes,
the following images might be necessary.
  * haskell:8.2
  * python:2.7
  * node:9.2

# Install

In this section there will guide you to compile, install, and initialize the system. The I take an example on Ubuntu.

## Compile

The module: pb-auth has been packaged as docker image, so you can use it directly.
This subsection does not include the guide for install compilers, because those compiler is too easy to install, and you can also use the docker.

### Source code

You can get the from your upstream service provider or from [GitHub](https://github.com/XDU-PurpleBear).

### Compile the front-end

When you fetch front-end source codes, you can compile the codes in a easy way.

First, you need to move to the root directory of codes.
The you need to run (make sure you install node.js and npm):
```bash
npm install
npm run build
```
The compiler will generate a file located in `build/bundle.js`, which should be copied in to back-end's `static` directory.

### Compile the back-end main module

The back-end source codes are written in Python, which needn't compile.

However there are some package you need to install via pip:
```bash
pip install flask psycopg2
```

### Compile the pb-auth module

When you fetch the source codes, you can compile and install this module with haskell-stack.

You should move into the root directory of database's source code, because the pb-auth belong to database.

Then run
```bash
stack install pb-auth
```
to build and copy the binary(`pb-auth`) file to `~/.local/bin`.

## Initialization

### Database

First you need create the docker containers of PostgreSQL and Redis:
```bash
docker pull postgres:latest
docker pull redis
docker run -d --name pb-db -p 5432:5432 -e POSTGRES_PASSWORD=12345qwert postgres:latest
docker run -d --name pb-redis -p 6379:6379 redis:latest
```

Then run
```bash
docker cp sql/initialization.sql PB-DB:/
docker exec pb-db psql -d postgres -U postgres -f /nitialization.sql
```
to initialize the database.
The `sql/initialization.sql` are in the database's source codes.

### pb-auth module

If you want to use docker, run:
```
docker pull qinka/pb-database:pb-auth-latest
docker run -d --name pb-auth --link pb-redis:redis -p 3000:3000 qinka/pb-database:pb-auth:latest -c "pb-auth 3000 redis 6379"
```

You just run(make sure `~/.location/bin` are in `PATH`):
```bash
pb-auth 3000 redis 6379 &
```
or
```bash
sudo nohup pb-auth 3000 redis 6379 & > /var/pb-auth/`date`.log
```

### Back-end

Copy the file compiled in front-end to back-end's static directory.
The run
```bash
python frontend.py
```

`frontend.py` is in the back-end source code.

# More

[This file](https://github.com/XDU-PurpleBear/deploy/blob/master/deploy.sh) can be an example for deployment.