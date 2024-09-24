module Jekyll
  class InternalSiteLink < Liquid::Tag

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
        "<a id='#{@post_name}' class='internal-site-link' href='#{site.baseurl}#{post.permalink}'>#{@text}</a>"
      else
        puts "ERROR:\n\tPost not found: @post_name=#{@post_name}\nERROR\n"
      end
    end
  end
end

Liquid::Template.register_tag('vbook_post', Jekyll::InternalSiteLink)
Liquid::Template.register_tag('post_url_with_hover_card', Jekyll::InternalSiteLink)