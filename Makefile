src/SUMMARY.md: README.md text/*.md
	@./generate-book.py

run: src/SUMMARY.md
	@mdbook serve --open
