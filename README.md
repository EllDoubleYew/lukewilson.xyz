# Luke's Homepage

A buildless static personal website inspired by the supplied 1990s homepage.

Open `index.html` in a browser, or serve this directory with any static HTTP server. No installation is required. Deploy `index.html`, `style.css`, `personalb.gif`, `luke-yearbook-v2.jpg`, and the `blogs/` directory together.

The original `personalb.gif` supplies the blue top and left border at its native size. Edit the text in `index.html` and the layout in `style.css`.

## Adding blog posts

1. Copy `blogs/embracing-the-goodweb.html` to a new `.html` filename inside `blogs/`.
2. Edit the article, document title, and the `blog-title` and `blog-date` meta tags. Use `YYYY-MM-DD` for the date. Keep `../style.css` and `../index.html` as the stylesheet and home links.
3. Run `python update-blog-index.py` (or `py update-blog-index.py` on Windows) before publishing. It can be run from any directory and uses only Python's standard library.

The script scans every HTML file directly inside `blogs/`, writes links into the marked area of `index.html`, and sorts dated posts newest first. It uses the document title when `blog-title` is omitted; undated posts appear after dated posts. Rerun it after adding, renaming, editing titles/dates, or deleting posts. If your host supports build commands, configure it to run the script on deployment for automatic updates.

The published site stays entirely static and works when opened directly from disk. Blog links work with JavaScript disabled; Toad's animation uses local JavaScript. Browsers cannot reliably enumerate a static directory, so automatic discovery happens at build time rather than on each page visit.
