all: data.ptracers

data.ptracers: data.ptracers.in
	../../../tools/darwin/preprocessptracers -mods ../code -u $< > $@
