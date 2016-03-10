require 'minitest/autorun'
require 'mocha'
require 'mocha/mini_test'
require 'sync_issues'

# Test SycnIssues::Comparison
class ComparisonTest < MiniTest::Test
  def test_changed_assignee
    gh_assignee = mock
    gh_assignee.stubs(login: 'old_assignee')

    issue, github = test_stubs(assignee: 'new_assignee',
                               gh_assignee: gh_assignee)
    comparison = SyncIssues::Comparison.new(issue, github, true)
    assert comparison.changed?
    assert_equal 'new_assignee', comparison.assignee
    assert_equal ['assignee'], comparison.changed
  end

  def test_changed_assignee_but_do_not_sync
    issue, github = test_stubs(assignee: 'new_assignee')
    comparison = SyncIssues::Comparison.new(issue, github, false)
    assert !comparison.changed?
    assert_nil comparison.assignee
    assert_equal [], comparison.changed
  end

  def test_changed_assignee_to_nil
    gh_assignee = mock
    gh_assignee.stubs(login: 'old_assignee')

    issue, github = test_stubs gh_assignee: gh_assignee
    comparison = SyncIssues::Comparison.new(issue, github, true)
    assert comparison.changed?
    assert_nil comparison.assignee
    assert_equal ['assignee'], comparison.changed
  end

  def test_changed_assignee_to_nil_but_do_not_sync
    gh_assignee = mock
    gh_assignee.stubs(login: 'old_assignee')

    issue, github = test_stubs gh_assignee: gh_assignee
    comparison = SyncIssues::Comparison.new(issue, github, false)
    assert !comparison.changed?
    assert_equal gh_assignee.login, comparison.assignee
    assert_equal [], comparison.changed
  end

  def test_changed_title
    issue, github = test_stubs new_title: 'Something'
    comparison = SyncIssues::Comparison.new(issue, github, true)
    assert comparison.changed?
    assert_equal ['title'], comparison.changed
  end

  def test_changed_body__with_assignee
    gh_assignee = mock
    gh_assignee.stubs(login: 'old_assignee')

    issue, github = test_stubs assignee: 'old_assignee',
                               gh_assignee: gh_assignee,
                               gh_content: 'Some other content'
    comparison = SyncIssues::Comparison.new(issue, github, true)
    assert comparison.changed?
    assert_equal ['body'], comparison.changed
    assert_equal 'old_assignee', comparison.assignee
    assert_equal issue.content, comparison.content
    assert_equal issue.title, comparison.title
  end

  def test_changed_body__without_assignee
    issue, github = test_stubs gh_content: 'Some other content'
    comparison = SyncIssues::Comparison.new(issue, github, true)
    assert comparison.changed?
    assert_equal ['body'], comparison.changed
    assert_nil comparison.assignee
    assert_equal issue.content, comparison.content
    assert_equal issue.title, comparison.title
  end

  def test_changed_nothing__simple
    issue, github = test_stubs
    assert !SyncIssues::Comparison.new(issue, github, true).changed?
  end

  def test_changed_nothing__assignee_set
    gh_assignee = mock
    gh_assignee.stubs(login: 'old_assignee')

    issue, github = test_stubs(assignee: 'old_assignee',
                               gh_assignee: gh_assignee)
    assert !SyncIssues::Comparison.new(issue, github, true).changed?
  end

  def test_changed_nothing_but_markdown_checkbox
    issue, github = test_stubs(content: "- [ ] Some content\n",
                               gh_content: "- [x] Some content\r\n")

    comparison = SyncIssues::Comparison.new(issue, github, true)
    assert !comparison.changed?
    assert_equal github.title, comparison.title
    assert_equal github.body, comparison.content
  end

  private

  def test_stubs(assignee: nil, content: 'Some content', title: 'GitHub',
                 new_title: nil, gh_assignee: nil, gh_content: 'Some content',
                 gh_title: 'GitHub')
    issue = mock
    github = mock
    issue.stubs(assignee: assignee, content: content, title: title,
                new_title: new_title)
    github.stubs(assignee: gh_assignee, body: gh_content, title: gh_title)
    [issue, github]
  end
end
