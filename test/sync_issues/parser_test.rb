require 'minitest/autorun'
require 'mocha'
require 'mocha/mini_test'
require 'sync_issues'

# Test SycnIssues::Parser
class ParserTest < MiniTest::Test
  MD_CONTENT = "Markdown Content\n"

  def test_valid_file
    parser = SyncIssues::Parser.new("---\ntitle: Foo\n---\n#{MD_CONTENT}")
    assert_equal MD_CONTENT, parser.issue.content
  end

  def test_empty_content
    ['', ' ', "\n", " \n", "\n\n"].each do |content|
      begin
        SyncIssues::Parser.new("---\ntitle: Foo\n---\n#{content}")
        assert false
      rescue SyncIssues::ParseError => exc
        assert_equal 'empty markdown content', exc.message
      end
    end
  end

  def test_empty_frontmatter
    SyncIssues::Parser.new("---\n---\n#{MD_CONTENT}")
    assert false
  rescue SyncIssues::ParseError => exc
    assert_equal 'empty frontmatter', exc.message
  end

  def test_extra_frontmatter
    SyncIssues::Parser.new("---\ntitle: Foo\na: A\n---\n#{MD_CONTENT}")
    assert false
  rescue SyncIssues::ParseError => exc
    assert_equal 'unknown keyword: a', exc.message
  end

  def test_invalid_frontmatter
    SyncIssues::Parser.new("---\na: {\n---\n#{MD_CONTENT}")
    assert false
  rescue SyncIssues::ParseError => exc
    assert_equal 'invalid frontmatter', exc.message
  end

  def test_missing_frontmatter
    SyncIssues::Parser.new(MD_CONTENT)
    assert false
  rescue SyncIssues::ParseError => exc
    assert_equal 'missing frontmatter', exc.message
  end
end
