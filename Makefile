BASE =
SITE = _site

PAGES = $(filter-out index, $(basename $(notdir $(wildcard md/*.md))))
CONTENT = $(addprefix $(SITE)/, css img index.html $(addsuffix /index.html, $(PAGES)))

PANDOC = pandoc --defaults defaults.yml --metadata base=$(abspath $(BASE))

MKDIR = mkdir -p
CP = cp -r
RM = rm -rf

all: $(CONTENT)

$(SITE)/%: %
	@echo ">> Copying $^"
	@$(MKDIR) $(@D)
	@$(CP) $^ $@

$(SITE)/%.html $(SITE)/%/index.html: md/%.md
	@echo ">> Converting $^"
	@$(MKDIR) $(@D)
	@$(PANDOC) --metadata page=$* --output $@ $^

serve:
	@python3 -m http.server --bind 127.0.0.1 --directory $(SITE)

clean:
	@$(RM) $(SITE)
