require 'nokogiri'

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
        doc = Nokogiri::HTML::DocumentFragment.parse(post.output)

        # Select all p elements and all p elements that have a div.paragraph ancestor
        all_p_elements = doc.css('p')
        p_elements_in_paragraph = doc.css('div.paragraph p')

        # Get all p elements that don't have a div.paragraph ancestor
        p_elements_not_in_paragraph = all_p_elements - p_elements_in_paragraph

        p_elements_not_in_paragraph.each do |p|
            # Wrap the p element in a div.paragraph element
            p.replace("<div class='paragraph'>#{p.to_html}</div>")
        end

        # Convert the modified document back into a string
        post.output = doc.to_html
    end

    def log(post_name, msg)
        if post_name == "2024-12-16-test-post.md"
            puts msg
        end
    end

    def insertHoverCards(post, site)
        post.output = post.output.gsub(/<a id="(.*?)" class="internal-site-link"(.*?)<\/a>/) do
          post_name = $1
          restOfLink = $2
          log(post.basename, 'juan test <---------------------->')
          linked_post = site.posts.docs.find { |post| File.basename(post.basename, ".md") == post_name }
          title = linked_post.data['title']

          doc = Nokogiri::HTML::DocumentFragment.parse(linked_post.output)
          # Remove 'internal-site-link' class from all a tags
          doc.css('a.internal-site-link').each do |link|
              link['class'] = link['class'].split(' ').reject { |c| c == 'internal-site-link' }.join(' ')
          end

          # Remove all .hover-card-container divs and their descendants
          doc.search('.hover-card-container').remove

          content_match = doc.to_html.match(/<main class="page-content(.*?)>(.*?)<\/main>/m)
          content = content_match ? content_match[2] : ''
          "</p><a class='hover-link' #{restOfLink}</a><div class='hover-card-container'><div class='hover-card'>#{content}</div></div><p>"
        end
    end
  end
end