# Heroku Data Package dev

## Pull a package dev docker image
```
> git checkout master
> docker pull heroku/dod-package-dev:latest .
> mkdir ../ubuntu-package-cache
> docker run -v $(realpath ../ubuntu-package-cache):/root/pbuilder/ --privileged=true -it heroku/dod-package-dev:latest pbuilder-dist precise create --debootstrapopts --variant=buildd
> docker run -v $(realpath ../ubuntu-package-cache):/root/pbuilder/ --privileged=true -it heroku/dod-package-dev:latest pbuilder-dist trusty create --debootstrapopts --variant=buildd
```

## Build a deb package
```
> git checkout 9.1
> docker run -v $(pwd):/usr/src/postgresql -v $(realpath ../ubuntu-package-cache):/root/pbuilder --privileged=true -it heroku/dod-package-dev:latest bash
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
> docker run -v $(pwd):/usr/src/postgresql -v $(realpath ../ubuntu-package-cache):/root/pbuilder --privileged=true -it heroku/dod-package-dev:latest bash
# export DEBFULLNAME='Greg Burek' DEBEMAIL='gregburek@heroku.com'
# cd /usr/src/postgresql
# dch -i -D precise
# exit
> git commit -am "Merge debian/9.1.19-1"
```
