COFFEE = $(shell find . -name "*.coffee")
JS = $(COFFEE:.coffee=.js)

all: $(JS)

%.js: %.coffee
	coffee -c --stdio < $< > $@

clean:
	rm -f $(JS)

.PHONY: clean