# Luke's Homepage

A buildless static personal website inspired by the supplied 1990s homepage.

Open `index.html` in a browser, or serve this directory with any static HTTP server. Deploy the HTML, CSS, JavaScript, GIF/JPG assets, `blogs/`, and `stamps/` together. `photos.html` is the photo gallery linked from the homepage.

The original `personalb.gif` supplies the blue top and left border at its native size. Edit the text in `index.html` and the layout in `style.css`.

## Adding blog posts

Run the publishing script in Bash from WSL. On Ubuntu or Debian, install the local tools with:

```bash
sudo apt install cmark-gfm python3
```

Write a Markdown file named after your post, such as `A Little Corner of the Internet.md`. Its filename without the extension becomes the title; the entire Markdown file becomes the body. There is no front matter to fill in, and you do not need to repeat the title as a Markdown heading.

From the site folder:

```bash
./publish-blog-post.sh "/mnt/c/path/to/A Little Corner of the Internet.md"
```

The script converts Markdown (headings, links, emphasis, lists, code, etc.) to HTML using `templates/blog-post.html`, adds today's local date and a publication timestamp, and rebuilds the homepage links with the newest post first, including posts on the same day. Output URLs look like `blogs/2026-10-14-a-little-corner-of-the-internet.html`. Existing files are preserved; publishing the same title again creates a numbered filename. The Markdown source is left untouched and is not copied into the site.

Refresh the homepage to preview the result, then commit and push as usual. This script only writes local site files; it does not deploy or run Git. Relative Markdown image/link URLs are interpreted from the generated `blogs/` page, so use paths like `../photos/my-picture.jpg` and copy any referenced assets into the site yourself.

To rebuild links after manually editing or deleting HTML posts:

```bash
./update-blog-index.sh
```

Both scripts locate the site using their own directory, so they also work when called by absolute path from elsewhere. You can edit `templates/blog-post.html` to change the layout of future posts.

The index script scans every HTML file directly inside `blogs/`, writes links into the marked area of `index.html`, and sorts dated posts newest first. It uses the document title when `blog-title` is omitted; undated posts appear after dated posts. The Bash scripts use the existing `update-blog-index.py` to generate the list.

The published site stays entirely static and works when opened directly from disk. Blog links work with JavaScript disabled; Toad's animation uses local JavaScript. Browsers cannot reliably enumerate a static directory, so the local publishing tools generate the list before you push.

## Adding photos

```bash
./upload-photo.sh "/mnt/c/path/to/My Photo.jpg"
```

The script copies the original image to `photos/` and adds it to the top of the gallery with today's local date. The grid displays the original image scaled to fit, and each image opens directly in a new tab. Commit the new image and updated `photos.html`, then push to publish them.
