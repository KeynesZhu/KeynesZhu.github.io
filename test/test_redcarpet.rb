# frozen_string_literal: true

require "helper"

class TestRedcarpet < JekyllUnitTest
  context "redcarpet" do
    setup do
      if jruby?
        then skip(
          "JRuby does not perform well with CExt, test disabled."
        )
      end

      @config = {
        "markdown"  => "redcarpet",
        "redcarpet" => {
          "extensions" => %w(smart strikethrough filter_html),
        },
      }

      @markdown = Converters::Markdown.new @config

      @sample = Jekyll::Utils.strip_heredoc(<<-EOS
        ```ruby
        puts "Hello world"
        ```
      EOS
                                           )
    end

    should "pass redcarpet options" do
      assert_equal "<h1>Some Header</h1>", @markdown.convert("# Some Header #").strip
    end

    should "pass redcarpet SmartyPants options" do
      assert_equal "<p>&ldquo;smart&rdquo;</p>", @markdown.convert('"smart"').strip
    end

    should "pass redcarpet extensions" do
      assert_equal "<p><del>deleted</del></p>", @markdown.convert("~~deleted~~").strip
    end

    should "pass redcarpet render options" do
      assert_equal "<p><strong>bad code not here</strong>: i am bad</p>",
        @markdown.convert("**bad code not here**: <script>i am bad</script>").strip
    end

    context "with pygments enabled" do
      setup do
        unless system("command", "-v", "python")
          skip "Skipping as 'python' is not available"
        end
        @markdown = Converters::Markdown.new @config.merge(
          { "highlighter" => "pygments" }
        )
      end

      should "render fenced code blocks with syntax highlighting" do
        assert_equal(
          %(<div class="highlight"><pre><code class="language-ruby" ) +
          %(data-lang="ruby"><span></span><span class="nb">puts</span> <span ) +
          %(class="s2">&quot;Hello world&quot;</span>\n</code></pre></div>),
          @markdown.convert(@sample).strip
        )
      end
    end

    context "with rouge enabled" do
      setup do
        @markdown = Converters::Markdown.new @config.merge({ "highlighter" => "rouge" })
      end

      should "render fenced code blocks with syntax highlighting" do
        assert_equal(
          %(<div class="highlight"><pre><code class="language-ruby" ) +
          %(data-lang="ruby"><span class="nb">puts</span> <span ) +
          %(class="s2">"Hello world"</span>\n</code></pre></div>),
          @markdown.convert(@sample).strip
        )
      end
    end

    context "without any highlighter" do
      setup do
        @markdown = Converters::Markdown.new @config.merge({ "highlighter" => nil })
      end

      should "render fenced code blocks without syntax highlighting" do
        assert_equal(
          %(<figure class="highlight"><pre><code class="language-ruby" ) +
          %(data-lang="ruby">puts &quot;Hello world&quot;\n</code></pre></figure>),
          @markdown.convert(@sample).strip
        )
      end
    end
  end
end
