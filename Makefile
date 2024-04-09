.PHONY: requirements all extract validate transform build check publish clean variables

EXT = csv

RESOURCE_NAMES := $(shell python main.py resources)
OUTPUT_FILES := $(addsuffix .csv,$(addprefix data/,$(RESOURCE_NAMES)))

all: extract validate transform build check

extract:
	Rscript scripts/extract.R

validate:
	frictionless validate datapackage.yaml

transform: $(OUTPUT_FILES)

$(OUTPUT_FILES): data/%.csv: data-raw/*.$(EXT) schemas/%.yaml scripts/transform.py datapackage.yaml
	python main.py transform $*

build: transform datapackage.json

datapackage.json: $(OUTPUT_FILES) scripts/build.py datapackage.yaml
	python main.py build

check:
	frictionless validate datapackage.json

publish:
	git add -Af datapackage.json data/*.csv data-raw/*.$(EXT)
	git commit --author="Automated <actions@users.noreply.github.com>" -m "Update data package at: $$(date +%Y-%m-%dT%H:%M:%SZ)" || exit 0
	git push

clean:
	rm -f datapackage.json data/*.csv

variables:
	@echo $(OUTPUT_FILES)
