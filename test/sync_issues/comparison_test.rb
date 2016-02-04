require 'minitest/autorun'
require 'mocha'
require 'mocha/mini_test'
require 'sync_issues'

# Test SycnIssues::Comparison
class ComparisonTest < MiniTest::Test
  def test_changed_title
    issue, github = test_stubs new_title: 'Something'
    comparison = SyncIssues::Comparison.new(issue, github)
    assert comparison.changed?
    assert_equal ['title'], comparison.changed
  end

  def test_changed_body
    issue, github = test_stubs gh_content: 'Some other content'
    comparison = SyncIssues::Comparison.new(issue, github)
    assert comparison.changed?
    assert_equal ['body'], comparison.changed
    assert_equal issue.title, comparison.title
    assert_equal issue.content, comparison.content
  end

  def test_changed_nothing
    issue, github = test_stubs
    assert !SyncIssues::Comparison.new(issue, github).changed?
  end

  def test_changed_nothing_but_markdown_checkbox
    issue, github = test_stubs(content: "- [ ] Some content\n",
                               gh_content: "- [x] Some content\r\n")

    comparison = SyncIssues::Comparison.new(issue, github)
    assert !comparison.changed?
    assert_equal github.title, comparison.title
    assert_equal github.body, comparison.content
  end

  private

  def test_stubs(content: 'Some content', title: 'GitHub', new_title: nil,
                 gh_content: 'Some content', gh_title: 'GitHub')
    issue = mock
    github = mock
    issue.stubs(content: content, title: title, new_title: new_title)
    github.stubs(body: gh_content, title: gh_title)
    [issue, github]
  end
end
