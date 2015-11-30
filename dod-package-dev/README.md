# Heroku Postgres Ubuntu Packages

This repo is a fork of pgdg's debian packaging that is found at:
https://anonscm.debian.org/git/pkg-postgresql/postgresql.git

Each major postgres version has its own branch and this fork contains 9.1, 9.2,
9.3, 9.4 and 9.5 branches and tags:
```
> git branch
  9.1
  9.2
  9.3
  9.4
  9.5
* master
```

Current upstream tags correspond to released packages:

```
> git log --tags --simplify-by-decoration --pretty="format:%ci %d" | sort | tail
2015-10-06 21:28:46 +0200  (tag: debian/9.3.10-1)
2015-10-06 21:28:46 +0200  (tag: debian/9.4.5-1)
2015-10-06 21:28:47 +0200  (tag: debian/9.5.beta1-1)
2015-10-08 14:28:45 +0200  (tag: debian/9.4.5-0+deb8u1, upstream/9.4-jessie)
2015-10-08 15:14:31 +0200  (tag: debian/9.1.19-0+deb7u1, upstream/9.1-wheezy)
2015-10-08 17:13:02 +0200  (tag: debian/9.1.19-0+deb8u1, upstream/9.1-jessie)
2015-10-19 12:00:14 +0200  (tag: debian/8.4.22lts5-0+deb6u1)
2015-11-04 11:50:37 +0100  (tag: debian/8.4.22lts5-0+deb6u2, upstream/8.4-squeeze-lts)
2015-11-10 13:04:57 +0100  (tag: debian/9.5.beta2-1, origin/9.5, 9.5)
2015-11-16 16:54:33 +0100  (tag: debian/9.5.beta2-2, upstream/9.5)
```

Building the packages is handled by Travis CI https://magnum.travis-ci.com/heroku/ubuntu-postgresql
Packages are deployed to packagecloud.io https://packagecloud.io/heroku/dod

## Add upstream and get some branches
```
> git remote add upstream https://anonscm.debian.org/git/pkg-postgresql/postgresql.git
> git branch --track 9.1 origin/9.1
> git branch --track 9.2 origin/9.2
> git branch --track 9.3 origin/9.3
> git branch --track 9.4 origin/9.4
> git branch --track 9.5 origin/9.5
```

## Build a build env docker image
```
> git checkout master
> docker build -t heroku/ubuntu-postgres:latest .
> mkdir ../ubuntu-postgres-cache
> docker run -v $(realpath ../ubuntu-postgres-cache):/root/pbuilder/ --privileged=true -it heroku/ubuntu-postgres:latest pbuilder-dist precise create --debootstrapopts --variant=buildd
> docker run -v $(realpath ../ubuntu-postgres-cache):/root/pbuilder/ --privileged=true -it heroku/ubuntu-postgres:latest pbuilder-dist trusty create --debootstrapopts --variant=buildd
```

## Build a deb package
```
> git checkout 9.1
> docker run -v $(pwd):/usr/src/postgresql -v $(realpath ../ubuntu-postgres-cache):/root/pbuilder --privileged=true -it heroku/ubuntu-postgres:latest bash
# cd /usr/src/postgresql
# uscan --force-download --verbose --download-current-version
# debuild -S -uc
# pbuilder-dist precise update
# pbuilder-dist precise build ../*.dsc
# pbuilder-dist trusty update
# pbuilder-dist trusty build ../*.dsc
```

## Merge a new release
```
> git checkout 9.1
> git fetch upstream
> git log --tags --simplify-by-decoration --pretty="format:%ci %d" | sort
> git merge debian/9.1.19-1
> git checkout debian/9.1.19-1 -- debian/changelog
> docker run -v $(pwd):/usr/src/postgresql -v $(realpath ../ubuntu-postgres-cache):/root/pbuilder --privileged=true -it heroku/ubuntu-postgres:latest bash
# export DEBFULLNAME='Greg Burek' DEBEMAIL='gregburek@heroku.com'
# cd /usr/src/postgresql
# dch -i -D precise
# exit
> git commit -am "Merge debian/9.1.19-1"
```

## New custom package based off of pgdg 9.4
```
> git checkout 9.4
> git log --tags --simplify-by-decoration --pretty="format:%ci %d" | sort
> git pull --rebase debian/9.4.x-x
> docker run -v $(pwd):/usr/src/postgresql -v $(realpath ../ubuntu-postgres-cache):/root/pbuilder --privileged=true -it heroku/ubuntu-postgres:latest bash
# export DEBFULLNAME='Greg Burek' DEBEMAIL='gregburek@heroku.com'
# cd /usr/src/postgresql
# dch -i -D precise
# exit
> git commit -am "Algebraic!"
> git checkout 9.3 -- .travis.yml debian/source/options
> git commit -am "Adds .travis.yml"
> sed -i.bak 's/^ftp/https/' debian/watch
> git commit -am "Fix watch to be https"
```
