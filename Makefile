YML_FILES := $(wildcard data/*.yml)
COMMON_FILES := $(wildcard data/common/*.yml)
TEX_FILES := $(addprefix generated/,$(notdir $(YML_FILES:.yml=.tex)))
PDF_FILES := $(addprefix generated/,$(notdir $(YML_FILES:.yml=.pdf)))

ifdef OS
	RM = del /Q
	CP = copy
	FixPath = $(subst /,\,$1)
	LATEX = xelatex -aux-directory .build -output-directory generated
else
	ifeq ($(shell uname), Linux)
		RM = rm -f
		FixPath = $1
		CP = cp
		LATEX = xelatex -output-directory generated
    else
	    ifeq ($(shell uname), Darwin)
		    RM = rm -f
		    FixPath = $1
		    CP = cp
		    LATEX = xelatex -output-directory generated
		endif
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

all_tex: $(TEX_FILES)

all: $(PDF_FILES)
