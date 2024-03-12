module Jekyll
  class HoverCards < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
        # runs when entire site has been rendered, but before any files are written.
        # this prevents issues where linked_post.content for newer posts are still raw Markdown
        Jekyll::Hooks.register :site, :post_render do |site|
            site.posts.docs.each do |post|
                preserveParagraphs(post)
            end
            site.posts.docs.each do |post|
                insertHoverCards(post, site)
            end
        end
    end

    def preserveParagraphs(post)
        post.output = post.output.gsub(/<p>(.*?)<\/p>/m, '<div class="paragraph"><p>\1</p></div>')
    end

    def insertHoverCards(post, site)
        post.output = post.output.gsub(/<a id="(.*?)" class="internal-site-link"(.*?)<\/a>/) do
          id = $1
          linked_post = site.posts.docs.find { |post| post.id == id }
          title = linked_post.data['title']
          content = linked_post.content
          "</p><a class='hover-link' #{$2}</a><div class='hover-card-container'><div class='hover-card'><strong class='hover-card-title'>#{title}</strong><br>#{content}</div></div><p>"
        end
    end
  end
end