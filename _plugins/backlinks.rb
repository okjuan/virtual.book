module Jekyll
  module Backlinks
    def backlink(post_url)
      backlinks = []
      site = @context.registers[:site]
      # TODO: figure out bug that causes the-road to link to itself instead of linking to the-road-movie
      # TODO: figure out why it doens't link to both the-road AND the-road-movie
      # TODO: figure out why live-in-the-moment doesn't backlink to like-you-life
      # TODO: figure out why coordinate-metaphors doesn't backlink to four-thousand-weeks
      site.posts.docs.each do |post|
        if post&.content&.include? post_url
          if post&.url != post_url
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