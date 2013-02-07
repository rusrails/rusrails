# forked from https://github.com/lifo/docrails/blob/master/guides/rails_guides/markdown/renderer.rb

require 'redcarpet'
require 'nokogiri'

class Markdown

  class Renderer < Redcarpet::Render::HTML
    def initialize(options={})
      super
      @numeration = []
    end

    def block_code(code, language)
      <<-HTML
<div class="code_container">
<pre class="brush: #{brush_for(language)}; gutter: false; toolbar: false">
#{ERB::Util.h(code)}
</pre>
</div>
HTML
    end

    def header(text, header_level)
      # Always increase the heading level by, so we can use h1, h2 heading in the document
      header_level += 1
      @numeration[header_level] ||= 0
      @numeration[header_level] += 1
      @numeration = @numeration[0..header_level]

      %(<h#{header_level}>#{@numeration.compact.join('.')}. #{text}</h#{header_level}>)
    end

    def paragraph(text)
      if text =~ /^(TIP|IMPORTANT|CAUTION|WARNING|NOTE|INFO|TODO)[.:](.*?)/
        convert_notes(text)
      elsif text =~ /^\[<sup>(\d+)\]:<\/sup> (.+)$/
        linkback = %(<a href="#footnote-#{$1}-ref"><sup>#{$1}</sup></a>)
        %(<p class="footnote" id="footnote-#{$1}">#{linkback} #{$2}</p>)
      else
        text = convert_footnotes(text)
        "<p>#{text}</p>"
      end
    end

    def list(contents, list_type)
      if contents =~ /<dt>/
        %Q(<dl>#{contents}</dl>)
      else
        %Q(<ul>#{contents}</ul>)
      end
    end

    def list_item(text, list_type)
      if text =~ /:=/
        text.gsub(/^(.*):=(.*)$/) do |m|
          %Q(<dt>#{$1.strip}</dt><dd>#{$2.strip}</dd>)
        end
      else
        %Q(<li>#{text}</li>)
      end
    end

  private
    def convert_footnotes(text)
      text.gsub(/\[<sup>(\d+)\]<\/sup>/i) do
        %(<sup class="footnote" id="footnote-#{$1}-ref">) +
          %(<a href="#footnote-#{$1}">#{$1}</a></sup>)
      end
    end

    def brush_for(code_type)
      case code_type
        when 'ruby', 'sql', 'plain'
          code_type
        when 'erb'
          'ruby; html-script: true'
        when 'html'
          'xml' # html is understood, but there are .xml rules in the CSS
        else
          'plain'
      end
    end

    def convert_notes(body)
      # The following regexp detects special labels followed by a
      # paragraph, perhaps at the end of the document.
      #
      # It is important that we do not eat more than one newline
      # because formatting may be wrong otherwise. For example,
      # if a bulleted list follows the first item is not rendered
      # as a list item, but as a paragraph starting with a plain
      # asterisk.
      body.gsub(/^(TIP|IMPORTANT|CAUTION|WARNING|NOTE|INFO|TODO)[.:](.*?)(\n(?=\n)|\Z)/m) do |m|
        css_class = case $1
                    when 'CAUTION', 'IMPORTANT'
                      'warning'
                    when 'TIP'
                      'info'
                    else
                      $1.downcase
                    end
        %(<div class="#{css_class}"><p>#{$2.strip}</p></div>)
      end
    end
  end

  def render(body)
    engine.render(body)
  end

private
  def engine
    @engine ||= Redcarpet::Markdown.new(Renderer, {
      no_intra_emphasis: true,
      fenced_code_blocks: true,
      autolink: true,
      strikethrough: true,
      superscript: true,
      tables: true
    })
  end

end
