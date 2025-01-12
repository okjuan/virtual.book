---
modified_date: 2025-01-12
layout: post
title: building vbook
permalink: /building-vbook
tags: journal coding design
---

I built two new features in the spirit of the **dynamic** attribute of {% vbook_post virtual books | 2023-08-11-virtual-book %}.
<!--more-->

Firstly, I added modified dates to all posts and a way to sort them by post date or modified date.
This discourages me from treating posts like static pieces and instead encourages me to edit, rework, and reimagine them.
I didn't want to be responsible for manually updating the modified date of a post, so I automated it.

For my first attempt at implementing it, I put together a plugin written in Ruby (mostly written by GitHub Copilot) that found the most recent commit's date for each post by looking through the Git history.
It worked, but it also slowed down my local build a lot.
I found a much better solution: set up a git pre-commit hook that updates the `modified_date` in a post's frontmatter when a change is committed to it.
To implement sorting, I had to use JavaScript.
Working on a static website has made me appreciate how much is possible without JavaScript and what isn't.

More challenging to implement and more exciting to complete was a feature I'm calling Revisions, which shows past edits of select posts.
This one was even more important to automate.
Manually creating a revision for every new post would be a ponderous task that would deincentivize me from making changes.
Automatically generated revisions, on the other hand, excite me to make changes.
I want to see how posts change over time and how the converge to "final" form.

So, the main task was to plug into the Jekyll build to generate new pages that represent the difference between every pair of sequential commits in a post's Git history.
Once I had that, I just had to do some minor coding in HTML and Liquid to add links in a post's metadata to link to its revisions.

After I figured out how to get the full Git word diff between two commits (the `git` gem's API apparently doesn't expose this part of Git's functionality), most of the trouble had to do with formatting: stripping Git diff metadata, replacing diff markers with markdown formatting, transforming Markdown to HTML, and styling the HTML.
After I finally got it working locally, I pushed it up to GitHub to kick off the build and publish job.
But after the GitHub Actions finished, the site didn't look any different!

It took me a while to figure out why the GitHub Pages build was passing but not generating any revisions.
I figured the `git` gem wasn't being installed since it isn't in the list of packages supported by GitHub Pages.
It seemed like the plugin wasn't running at all.
Only after I added print statements to it did I realize that it _was_ running, but only finding a single commit.
Finally, I fixed it by setting the `fetch-depth` of the `checkout` action to a pseudoinfinite number so that the full Git history would get processed.

I set it up so I can easily enable or disable revisions for a post by setting `show_revisions` in its frontmatter.
So far, I've enabled revisions for {% vbook_post what makes a good shower? | 2024-08-30-good-shower %}, {% vbook_post how to think invisibly | 2021-02-01-think-invisibly %}, and {% vbook_post how to tell a story #3 | 2024-08-12-tell-a-story-3 %}.
