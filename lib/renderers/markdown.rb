# forked from https://github.com/rails/rails/blob/master/guides/rails_guides/markdown/renderer.rb
class Rusrails::Markdown
  def render(body)
    engine.render(body)
  end

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

  # Add more common shell commands
  Rouge::Lexers::Shell::BUILTINS << "|bin/rails|brew|bundle|gem|git|node|rails|rake|ruby|sqlite3|yarn"

  class Renderer < Redcarpet::Render::HTML
    attr_reader :headers

    def initialize(options = {})
      super
      @numeration = []
      @headers = []
      @hid_container = []
      @hid_hash = {}
    end

    def block_code(code, language)
      formatter = Rouge::Formatters::HTML.new
      lexer = ::Rouge::Lexer.find_fancy(lexer_language(language))
      formatted_code = formatter.format(lexer.lex(code))
      <<~HTML
        <div class="code_container">
          <pre><code class="highlight #{lexer_language(language)}">#{formatted_code}</code></pre>
        </div>
      HTML
    end

    def sanitizer
      @sanitizer ||= Rails::Html::FullSanitizer.new
    end

    def header(text, header_level)
      # Always increase the heading level by, so we can use h1, h2 heading in the document
      header_level += 1
      text.gsub!(/\A\s*\(([^\)]+)\)/, '')
      hid = sanitizer.sanitize($1 || text).parameterize

      @hid_container << hid

      if @hid_container.include? hid
        if @hid_hash[hid].present?
          @hid_hash[hid] = @hid_hash[hid] + 1
        else
          prev_count_hid_container = @hid_container.count(hid) - 1
          @hid_hash[hid] = prev_count_hid_container if prev_count_hid_container != 0
        end

        hid.concat (@hid_hash[hid].to_i + 1).to_s if @hid_hash[hid].present?
      else
        @hid_hash[hid] = @hid_container.count(hid)
      end

      if header_level > 2
        @numeration[header_level] ||= 0
        @numeration[header_level] += 1
        @numeration = @numeration[0..header_level]
        num_link = %(<a href="##{hid}">#{@numeration.compact.join('.')}.</a>)
      else
        @numeration = []
        num_link = ''
      end

      @headers << [@numeration.compact, hid, text]

      %(<h#{header_level} id='#{hid}' class='inside_page_header'>#{num_link} #{text}</h#{header_level}>)
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

    def table(header, body)
      %Q(<table class='table table-striped'>#{header}#{body}</table>)
    end

    def image(link, title, alt_text)
      %Q(<img src='#{helpers.image_url(link)}' title='#{title}' alt='#{alt_text}' class='img-polaroid' />)
    end

    private

    def helpers
      ActionController::Base.helpers
    end

    def convert_footnotes(text)
      text.gsub(/\[<sup>(\d+)\]<\/sup>/i) do
        %(<sup class="footnote" id="footnote-#{$1}-ref">) +
          %(<a href="#footnote-#{$1}">#{$1}</a></sup>)
      end
    end

    def lexer_language(code_type)
      case code_type
      when "html+erb"
        "erb"
      when "bash"
        "console"
      when nil
        "plaintext"
      else
        ::Rouge::Lexer.find(code_type) ? code_type : "plaintext"
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
end
