module Jekyll
  class HoverCards < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      Jekyll::Hooks.register :posts, :post_render do |post|
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
end