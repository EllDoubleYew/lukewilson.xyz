"""Scan blogs/*.html and rebuild the static homepage links; no dependencies."""

from datetime import date
from html import escape
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import quote

ROOT = Path(__file__).resolve().parent
START = "<!-- BLOG-LIST:START -->"
END = "<!-- BLOG-LIST:END -->"


class PostMetadata(HTMLParser):
    def __init__(self):
        super().__init__()
        self.metadata = {}
        self.title_parts = []
        self.in_title = False

    def handle_starttag(self, tag, attrs):
        attributes = dict(attrs)
        if tag == "meta":
            self.metadata[attributes.get("name", "")] = attributes.get("content", "")
        if tag == "title":
            self.in_title = True

    def handle_endtag(self, tag):
        if tag == "title":
            self.in_title = False

    def handle_data(self, data):
        if self.in_title:
            self.title_parts.append(data)


def main():
    posts = []
    for path in ROOT.joinpath("blogs").iterdir():
        if not path.is_file() or path.suffix.lower() != ".html":
            continue
        parser = PostMetadata()
        parser.feed(path.read_text(encoding="utf-8"))
        title = (parser.metadata.get("blog-title") or
                 "".join(parser.title_parts).split(" | ")[0].strip() or path.stem)
        published = parser.metadata.get("blog-date", "")
        if published:
            date.fromisoformat(published)  # Fail clearly on invalid dates.
        timestamp = parser.metadata.get("blog-published", "")
        posts.append((published, timestamp, title, path.name))

    posts.sort(key=lambda post: (post[0], post[1], post[3]), reverse=True)
    lines = ['        <ul class="blog-list">']
    for published, timestamp, title, filename in posts:
        stamp = (f' <time class="post-date" datetime="{published}">'
                 f'{published}</time>') if published else ""
        lines.append(f'          <li><a href="blogs/{quote(filename, safe="")}">'
                     f'{escape(title)}</a>{stamp}</li>')
    lines.append("        </ul>" if posts else "        </ul>\n        <p>No posts yet.</p>")

    homepage = ROOT / "index.html"
    original = homepage.read_text(encoding="utf-8")
    if original.count(START) != 1 or original.count(END) != 1:
        raise ValueError("Homepage must contain exactly one pair of BLOG-LIST markers")
    before, rest = original.split(START)
    _, after = rest.split(END)
    homepage.write_text(before + START + "\n" + "\n".join(lines) + "\n        " + END + after,
                        encoding="utf-8")
    print(f"Updated homepage with {len(posts)} blog post(s).")


if __name__ == "__main__":
    main()
