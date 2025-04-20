EMBEDDED_DIR := .embedded
FULL_DIR := .full

posts := $(wildcard **/*.adoc **/*.md)
html := $(patsubst %.adoc,%.html,$(patsubst %.md,%.html,$(posts)))
embedded := $(addprefix $(EMBEDDED_DIR)/,$(html))
full := $(addprefix $(FULL_DIR)/,$(html))

.PHONY: all clean watch watch-file

all: $(full) $(embedded)

$(FULL_DIR)/%.html: %.adoc | $(FULL_DIR)
	mkdir -p $(dir $@)
	asciidoctor -D $(dir $@) $<

$(EMBEDDED_DIR)/%.html: %.adoc | $(EMBEDDED_DIR)
	mkdir -p $(dir $@)
	asciidoctor -e -D $(dir $@) $<

$(FULL_DIR)/%.html: %.md | $(FULL_DIR)
	mkdir -p $(dir $@)
	asciidoctor -D $(dir $@) $<

$(EMBEDDED_DIR)/%.html: %.md | $(EMBEDDED_DIR)
	mkdir -p $(dir $@)
	asciidoctor -e -D $(dir $@) $<

$(FULL_DIR) $(EMBEDDED_DIR):
	mkdir -p $@

clean:
	rm -rf $(FULL_DIR)
	rm -rf $(EMBEDDED_DIR)

watch:
	@echo "Watching all files for changes..."
	@while true; do make -q || make; sleep 0.5; done

watch-file:
	@if [ -z "$(file)" ]; then \
		echo "Usage: make watch-file file=posts/test.md"; \
		exit 1; \
	fi; \
	echo "Watching $(file) for changes..."; \
	while true; do \
		if [ -f "$(file)" ]; then \
			base=$${file%.*}; \
			make -q "$(EMBEDDED_DIR)/$$base.html" "$(FULL_DIR)/$$base.html" || \
			make "$(EMBEDDED_DIR)/$$base.html" "$(FULL_DIR)/$$base.html"; \
		else \
			echo "File $(file) not found"; \
			exit 1; \
		fi; \
		sleep 0.5; \
	done
