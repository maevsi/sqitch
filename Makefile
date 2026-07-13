.PHONY: init

init:
	@if [ -d node_modules ]; then echo "Already initialized."; else pnpm install; fi