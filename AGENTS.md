# Luke's personal website

- Keep the site entirely static and serverless. Cloudflare Pages serves the files from GitHub and redeploys when the remote repository updates.
- Keep the site buildless. The publishing scripts write local static files. Preview the changes, then commit and push the generated files to publish them.
- Run `./publish-blog-post.sh "/path/to/Post Title.md"` to generate a dated HTML post in `blogs/` and update the homepage blog links. Run `./update-blog-index.sh` after manually editing or removing posts.
- Run `./upload-photo.sh "/path/to/My Photo.jpg"` to copy the original image into `photos/` and add it to the top of the dated grid in `photos.html`. Commit both files.
- Keep UI changes deliberately minimal and reminiscent of a primitive 1990s personal homepage. Use a simple layout and skip responsive adaptations for different displays. Modern HTML, CSS, and JavaScript conventions are fine when they support that design.
