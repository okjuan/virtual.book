# Set up

To run this site locally, you will need to have ruby and other things installed.
Follow the instructions GitHub gives for developing GitHub Pages.

After cloning this repo, run `git config core.hooksPath git_hooks/` to set up this repo's git hooks.
You only need to do this once.

# Development

Run `bundle exec jekyll serve` to deploy this site locally.
Pass `-w` flag to enable watch mode for automatic reload.
Also pass `-I` for incremental build, but be aware that new files won't be detected.

If you get an error about some Ruby gem when running `bundle exec jekyll serve`, you may need to run `bundle install`.
If you get stuck, refer to the instructions GitHub gives for developing GitHub Pages.