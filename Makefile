COMPONENT = ./node_modules/.bin/component
KARMA = ./node_modules/karma/bin/karma
JSHINT = ./node_modules/.bin/jshint
MOCHA = ./node_modules/.bin/mocha-phantomjs
BUMP = ./node_modules/.bin/bump
MINIFY = ./node_modules/.bin/minify

build: components $(find lib/*.js)
	@${COMPONENT} build --dev

prod: components $(find lib/*.js)
	@${COMPONENT} build

components: node_modules component.json
	@${COMPONENT} install --dev

clean:
	rm -fr build components dist

node_modules:
	npm install

minify: build
	${MINIFY} build/build.js build/build.min.js

karma: build
	${KARMA} start test/karma.conf.js --no-auto-watch --single-run

lint: node_modules
	${JSHINT} lib/*.js

test: lint build
	${MOCHA} /test/runner.html

ci: test

patch:
	${BUMP} patch

minor:
	${BUMP} minor

release: test
	VERSION=`node -p "require('./component.json').version"` && \
	git changelog --tag $$VERSION && \
	git release $$VERSION

dist: prod
	mkdir -p dist
	mv build/build.js dist/ripple.js

.PHONY: clean test karma patch release prod dist
