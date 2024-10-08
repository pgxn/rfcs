src/SUMMARY.md: generate-book.py README.md $(wildcard text/*.md)
	@./generate-book.py

run: src/SUMMARY.md
	@mdbook serve

open: src/SUMMARY.md
	@mdbook serve --open

clean: src book
	rm -rf $^
