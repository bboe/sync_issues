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
    comparison = SyncIssues::Comparison.new(issue, github, sync_assignee: true)
    assert comparison.changed?
    assert_equal 'new_assignee', comparison.assignee
    assert_equal ['assignee'], comparison.changed
  end

  def test_changed_assignee_but_do_not_sync
    issue, github = test_stubs(assignee: 'new_assignee')
    comparison = SyncIssues::Comparison.new(issue, github,
                                            sync_assignee: false)
    assert !comparison.changed?
    assert_nil comparison.assignee
    assert_equal [], comparison.changed
  end

  def test_changed_assignee_to_nil
    gh_assignee = mock
    gh_assignee.stubs(login: 'old_assignee')

    issue, github = test_stubs gh_assignee: gh_assignee
    comparison = SyncIssues::Comparison.new(issue, github, sync_assignee: true)
    assert comparison.changed?
    assert_nil comparison.assignee
    assert_equal ['assignee'], comparison.changed
  end

  def test_changed_assignee_to_nil_but_do_not_sync
    gh_assignee = mock
    gh_assignee.stubs(login: 'old_assignee')

    issue, github = test_stubs gh_assignee: gh_assignee
    comparison = SyncIssues::Comparison.new(issue, github,
                                            sync_assignee: false)
    assert !comparison.changed?
    assert_equal gh_assignee.login, comparison.assignee
    assert_equal [], comparison.changed
  end

  def test_changed_labels
    issue, github = test_stubs(labels: ['new label'],
                               gh_labels: [{ name: 'old label' }])
    comparison = SyncIssues::Comparison.new(issue, github, update_labels: true)
    assert comparison.changed?
    assert_equal ['new label'], comparison.labels
    assert_equal ['labels'], comparison.changed
  end

  def test_changed_labels_but_do_not_sync
    issue, github = test_stubs(labels: ['OLD label'])
    comparison = SyncIssues::Comparison.new(issue, github,
                                            update_labels: false)
    assert !comparison.changed?
    assert_equal [], comparison.labels
    assert_equal [], comparison.changed
  end

  def test_changed_labels_case_only
    issue, github = test_stubs(labels: ['OLD label'],
                               gh_labels: [{ name: 'old label' }])
    comparison = SyncIssues::Comparison.new(issue, github, update_labels: true)
    assert !comparison.changed?
    assert_equal ['old label'], comparison.labels
    assert_equal [], comparison.changed
  end

  def test_changed_labels_to_nil
    issue, github = test_stubs(labels: nil,
                               gh_labels: [{ name: 'old label' }])
    comparison = SyncIssues::Comparison.new(issue, github, update_labels: true)
    assert !comparison.changed?
    assert_equal ['old label'], comparison.labels
    assert_equal [], comparison.changed
  end

  def test_changed_title
    issue, github = test_stubs new_title: 'Something'
    comparison = SyncIssues::Comparison.new(issue, github, sync_assignee: true)
    assert comparison.changed?
    assert_equal ['title'], comparison.changed
  end

  def test_changed_body__with_assignee
    gh_assignee = mock
    gh_assignee.stubs(login: 'old_assignee')

    issue, github = test_stubs assignee: 'old_assignee',
                               gh_assignee: gh_assignee,
                               gh_content: 'Some other content'
    comparison = SyncIssues::Comparison.new(issue, github, sync_assignee: true)
    assert comparison.changed?
    assert_equal ['body'], comparison.changed
    assert_equal 'old_assignee', comparison.assignee
    assert_equal issue.content, comparison.content
    assert_equal issue.title, comparison.title
  end

  def test_changed_body__without_assignee
    issue, github = test_stubs gh_content: 'Some other content'
    comparison = SyncIssues::Comparison.new(issue, github, sync_assignee: true)
    assert comparison.changed?
    assert_equal ['body'], comparison.changed
    assert_nil comparison.assignee
    assert_equal issue.content, comparison.content
    assert_equal issue.title, comparison.title
  end

  def test_changed_nothing__simple
    issue, github = test_stubs
    assert !SyncIssues::Comparison.new(issue, github,
                                       sync_assignee: true).changed?
  end

  def test_changed_nothing__assignee_set
    gh_assignee = mock
    gh_assignee.stubs(login: 'old_assignee')

    issue, github = test_stubs(assignee: 'old_assignee',
                               gh_assignee: gh_assignee)
    assert !SyncIssues::Comparison.new(issue, github,
                                       sync_assignee: true).changed?
  end

  def test_changed_nothing_but_markdown_checkbox
    issue, github = test_stubs(content: "- [ ] Some content\n",
                               gh_content: "- [x] Some content\r\n")

    comparison = SyncIssues::Comparison.new(issue, github, sync_assignee: true)
    assert !comparison.changed?
    assert_equal github.title, comparison.title
    assert_equal github.body, comparison.content
  end

  private

  def test_stubs(assignee: nil, content: 'Some content', labels: nil,
                 title: 'GitHub', new_title: nil, gh_assignee: nil,
                 gh_content: 'Some content', gh_labels: [], gh_title: 'GitHub')
    issue = mock
    github = mock
    issue.stubs(assignee: assignee, content: content, labels: labels,
                title: title, new_title: new_title)
    github.stubs(assignee: gh_assignee, body: gh_content, labels: gh_labels,
                 title: gh_title)
    [issue, github]
  end
end
