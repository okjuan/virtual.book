module Jekyll
  module Backlinks
    def backlink(target_post)
      backlinks = []
      # e.g. _posts/2022-02-02-dune.md => 2022-02-02-dune
      post_file_name = File.basename(target_post.path,File.extname(target_post.path))
      site = @context.registers[:site]
      site.posts.docs.each do |post|
        # file name matches when target_post is older than post and URL matches when target_post is newer
        # this is (presumably) because posts are processed in chronological order, and so half are in raw form
        # and the rest are in HTML form
        if post&.content&.include?(post_file_name) || post&.content&.include?(target_post.url)
          if post&.url != target_post.url
            backlinks << "<a href=\"#{site.baseurl}#{post.url}\">#{post.data['title']}</a>"
          end
        end
      end
      if (backlinks.length > 0)
        return "Mentioned in #{backlinks.join(', ')}"
      else
        return nil
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::Backlinks)