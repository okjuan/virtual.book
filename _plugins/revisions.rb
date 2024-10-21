require 'git'

module Revision
  class RevisionPageGenerator < Jekyll::Generator
    safe true

    def generate(site)
      repo = Git.open('.')
      @site = site
      site.posts.docs.each do |post|
        if post['show_revisions']
          log = repo.log.path(post.path)
          commits = []
          log.each do |commit|
            commits << commit
          end
          create_revisions(post, commits)
        end
      end
    end

    def create_revisions(post, commits)
      revision_count = 0
      previous_revision = nil
      for index in (commits.length - 1).downto(1)
        git_word_diff = get_word_diff(post.path, commits[index].sha, commits[index-1].sha)

        content_diff = strip_metadata(git_word_diff)
          # Fix bug caused by custom Liquid tag name change post_url_with_hover_card -> vbook_post
          # ---
          # Liquid Exception: Liquid syntax error (line 20): Tag '{% <del>post_url_with_hover_card</del> <strong>vbook_post</strong> their mind wanders | 2021-02-01-think-invisibly %}'
          # was not properly terminated with regexp: /\%\}/ in /Users/juan/personal/github/vbook/_posts/2024-08-30-good-shower.md
          .gsub('{+vbook_post+}', 'vbook_post')
          .gsub('[-post_url_with_hover_card-]', '')

        next unless any_diff(content_diff)

        ## Replace diff tokens with Markdown & HTML formatting for deletions and insertions
        formatted_diff = content_diff
          .gsub('{+', ' <ins class="revision-insertion">').gsub('+}', '</ins> ')
          .gsub('[-', ' ~~').gsub('-]', '~~ ')

        markdown_converter = @site.find_converter_instance(Jekyll::Converters::Markdown)
        html_content = markdown_converter.convert(formatted_diff)

        doc = Nokogiri::HTML::DocumentFragment.parse(html_content)
        all_p_elements = doc.css('p')
        all_p_elements.each do |p|
            # Wrap the p element in a div.paragraph element
            p.replace("<div class='paragraph'>#{p.to_html}</div>")
        end

        rev_date = commits[index-1].date.strftime('%Y-%m-%d')
        rev = RevisionPage.new(@site, post, doc.to_html, revision_count+1, rev_date)
        @site.pages << rev
        if previous_revision
            previous_revision.data['next_rev'] = rev
            rev.data['prev_rev'] = previous_revision
        end

        revision_count += 1
        previous_revision = rev
      end
      post.data['revision_count'] = revision_count
      post.data['final_version'] = true
      post.data['prev_rev'] = previous_revision
      previous_revision.data['next_rev'] = post
    end

    def get_word_diff(file_path, commit1, commit2)
      # -U1000 sets context to 999999 lines
      command = "git diff --word-diff -U999999 #{commit1} #{commit2} -- #{file_path}"
      stdout, stderr, status = Open3.capture3(command)
      if status.success?
        stdout
      else
        raise "Error running git diff: #{stderr}"
      end
    end

    def strip_metadata(git_word_diff)
      # Remove Git metadata
      git_word_diff
        .gsub(/^diff --git.*\n/, '')
        .gsub(/^index .*\n/, '')
        .gsub(/^--- .*\n/, '')
        .gsub(/^\+\+\+ .*\n/, '')
        .gsub(/^@@ .* @@\n/, '')
        # Remove YAML frontmatter
        .gsub(/^---\n.*?\n---\n\n?/m, '')
        ## Remove HTML comments
        .gsub(/\s*<!--.*?-->/, '')
    end

    def any_diff(git_word_diff)
      git_word_diff.match?(/\{\+.*?\+\}/) || git_word_diff.match?(/\[-.*?-\]/)
    end
  end

  class RevisionPage < Jekyll::Page
    def initialize(site, current_post, content, revision_number, revision_date)
      @site = site             # the current site instance.
      @base = site.source      # path to the source directory.
      @dir  = "#{current_post.permalink}/revs/#{revision_number}" # the directory the page will reside in.
      @current_post = current_post

      @basename = "index"      # filename without the extension.
      @ext      = '.html'      # the extension.
      @name     = "index.html" # basically @basename + @ext.
      @content  = content

      # This allows accessing in *html file via `page.revision_number`, for example.
      @data = {
          'revision_number' => revision_number,
          'current_post_url' => current_post.permalink,
          'rev' => revision_number,
          'title' => "#{current_post["title"]} (rev. ##{revision_number})",
          'subtitle' => current_post['subtitle'],
          'subsubtitle' => current_post['subsubtitle'],
          'date' => current_post['date'],
          'modified_date' => revision_date,
          'show_revisions' => current_post['show_revisions'],
          'author' => current_post['author'],
          'tags' => current_post['tags'],
          'note' => current_post['note'],
          'current_post' => current_post
      }

      # Look up front matter defaults scoped to type `tags`, if given key
      # doesn't exist in the `data` hash.
      data.default_proc = proc do |_, key|
        site.frontmatter_defaults.find(relative_path, :revs, key)
      end
    end

    # Placeholders that are used in constructing page URL.
    def url_placeholders
      {
        :path       => @dir,
        :rev   => "#{@data['revision_number']}",
        :final_rev => @current_post['permalink'],
        :basename   => basename,
        :output_ext => output_ext,
      }
    end
  end
end