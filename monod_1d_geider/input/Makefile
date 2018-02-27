all: data.ptracers

data.ptracers: data.ptracers.in
	../../../tools/darwin/preprocessptracers -b ../build $< > $@

#data.diagnostics: mkdiags
#	./mkdiags > data.diagnostics
