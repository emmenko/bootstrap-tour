#!/bin/sh
if [ ! -x ./node_modules/.bin/phantomjs ]; then
  case $OSTYPE in
    darwin*)
      f=phantomjs-1.9.1-macosx.zip
      d="${f%.zip}"
      wget http://phantomjs.googlecode.com/files/$f
      unzip $f
      ;;
    *)
      f=phantomjs-1.9.1-linux-i686.tar.bz2
      d="${f%.tar.bz2}"
      wget http://phantomjs.googlecode.com/files/$f
      tar xf $f
      ;;
  esac
  mv "$d/bin/phantomjs" ./node_modules/.bin/
  rm -rf "$d"
  rm "$f"
fi
jq=./deps/jquery.js
if [ ! -r $jq ]; then
  wget http://code.jquery.com/jquery-1.8.3.min.js -O $jq
fi
bsjs=./deps/bootstrap.min.js
if [ ! -r $bsjs ]; then
  wget http://netdna.bootstrapcdn.com/twitter-bootstrap/2.3.2/js/bootstrap.min.js  -O $bsjs
fi
bscss=./deps/bootstrap.min.css
if [ ! -r $bscss ]; then
  wget http://netdna.bootstrapcdn.com/twitter-bootstrap/2.3.2/css/bootstrap-combined.min.css -O $bscss
fi
cd ./test
cat specs.coffee | ../node_modules/.bin/coffee -c -s > test.js
../node_modules/.bin/mocha-phantomjs -R dot test.html
