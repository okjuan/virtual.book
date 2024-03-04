module Jekyll
  class HoverCardTag < Liquid::Tag

    def initialize(tag_name, input, tokens)
      super
      input_split = input.split("|")
      @text = input_split[0].strip
      @post_name = input_split[1]? input_split[1].strip : 'TODO'
    end

    def render(context)
      site = context.registers[:site]
      post = site.posts.docs.find { |p| File.basename(p.basename, ".md") == @post_name }
      if post
        stripped_content = post.content.gsub(/<\/?p>/, '').gsub(/\n\n/, '<br>')
        "<span class='hover-link'><a href='#{site.baseurl}#{post.permalink}'>#{@text}</a><span class='hover-card'><strong class='hover-card-title'>#{post.title}</strong><br>#{stripped_content}</span></span>"
      else
        puts "Post not found: @post_name=#{@post_name}"
      end
    end
  end
end

Liquid::Template.register_tag('post_url_with_hover_card', Jekyll::HoverCardTag)