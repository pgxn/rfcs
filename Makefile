src/SUMMARY.md: generate-book.py README.md text/*.md
	@./generate-book.py

run: src/SUMMARY.md
	@mdbook serve --open

clean: src book
	rm -rf $^
