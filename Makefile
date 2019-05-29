LATEX = xelatex -output-directory .build
YML_FILES := $(wildcard data/*.yml)
COMMON_FILES := $(wildcard data/common/*.yml)
TEX_FILES := $(addprefix generated/,$(notdir $(YML_FILES:.yml=.tex)))
PDF_FILES := $(addprefix generated/,$(notdir $(YML_FILES:.yml=.pdf)))

ifdef OS
	RM = del /Q
	CP = copy
	FixPath = $(subst /,\,$1)
else
	ifeq ($(shell uname), Linux)
		RM = rm -f
		FixPath = $1
		CP = cp
	endif
endif

clean:
	$(RM) $(call FixPath,generated/*)

generated/%.tex: $(call FixPath,data/%.yml) latex/template.tex $(COMMON_FILES)
	@echo $(YML_FILES)
	python render.py $<
generated/%.pdf: generated/%.tex
	$(LATEX) $<
	$(LATEX) $<
	$(CP) $(call FixPath,.build/$(notdir $@)) $@

all_tex: $(TEX_FILES)

all: $(PDF_FILES)
