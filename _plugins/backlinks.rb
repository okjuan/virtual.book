module Jekyll
  module Backlinks
    def backlink(target_post)
      backlinks = []
      # e.g. _posts/2022-02-02-dune.md => 2022-02-02-dune
      post_file_name = File.basename(target_post.path,File.extname(target_post.path))

      # Ruby notes
      # ---
      # 1. '@' in Ruby is like `self.` in Python
      # so, @context is an instance variable (of the class)
      # (fun fact: @@context would be a class variable)
      # 2. Jekyll lets you access the site object through the @context.registers feature of Liquid
      # at @context.registers[:site]. e.g. access _config.yml using @context.registers[:site].config
      # 3. :site is a symbol, which is like a string but immutable.
      site = @context.registers[:site]

      site.posts.docs.each do |post|
        # Implementation notes
        # ---
        # file name matches when target_post is older than post and URL matches when target_post is newer
        # this is (presumably) because posts are processed in chronological order, and so half are in raw form
        # and the rest are in HTML form
        #
        # Ruby notes
        # ---
        # 1. '&' is the safe navigation operator, which is like the '?.' operator in JS
        # 2. '?' is a convention for methods that return a boolean; it doesn't actually do anything
        if post&.content&.include?(post_file_name) || post&.content&.include?(target_post.url)
          if post&.url != target_post.url
            # Ruby notes
            # ---
            # 1. '<<' is an operator that can be overriden; for arrays, it overrides the push method
            # (fun fact: for strings, it overrides the concat method)
            # 2. #{someString} is string interpolation; if it isn't a string, it will be converted to a string with an implicit to_s call
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