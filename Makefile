deps:
	npm install -d

build:
	mkdir -p build/js
	mkdir -p build/css
	@./node_modules/.bin/coffee -c -o build/js/ src/coffee/
	@./node_modules/.bin/uglifyjs --comments -o build/js/bootstrap-tour.min.js build/js/bootstrap-tour.js
	@./node_modules/.bin/lessc src/less/bootstrap-tour.less build/css/bootstrap-tour.css
	@./node_modules/.bin/lessc --yui-compress src/less/bootstrap-tour.less build/css/bootstrap-tour.min.css

test: build
	@./test/run.sh

clean:
	rm -rf build

.PHONY: deps build clean test
