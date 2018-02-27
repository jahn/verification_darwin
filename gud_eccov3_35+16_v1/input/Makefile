all: data.ptracers data.diagnostics

data.ptracers: data.ptracers.in
	../../../tools/darwin/preprocessptracers -b ../build -u $< > $@

data.diagnostics: data.diagnostics.in
	../../../tools/darwin/preprocessdiagnostics $< > $@

