require 'minitest/autorun'
require 'mocha'
require 'mocha/mini_test'
require 'sync_issues'

# Test SycnIssues::Comparison
class ComparisonTest < MiniTest::Test
  def test_changed_assignees
    gh_assignee = mock
    gh_assignee.stubs(login: 'old_assignee')

    issue, github = test_stubs(assignees: ['new_assignee'],
                               gh_assignees: [gh_assignee])
    comparison = SyncIssues::Comparison.new(issue, github, sync_assignees: true)
    assert comparison.changed?
    assert_equal ['new_assignee'], comparison.assignees
    assert_equal ['assignees'], comparison.changed
  end

  def test_changed_assignees_but_do_not_sync
    issue, github = test_stubs(assignees: ['new_assignees'])
    comparison = SyncIssues::Comparison.new(issue, github,
                                            sync_assignees: false)
    assert !comparison.changed?
    assert_equal [], comparison.assignees
    assert_equal [], comparison.changed
  end

  def test_changed_assignees_to_blank
    gh_assignee = mock
    gh_assignee.stubs(login: 'old_assignee')

    issue, github = test_stubs assignees: [], gh_assignees: [gh_assignee]
    comparison = SyncIssues::Comparison.new(issue, github,
                                            sync_assignees: true)
    assert comparison.changed?
    assert_equal [], comparison.assignees
    assert_equal ['assignees'], comparison.changed
  end

  def test_changed_assignees_to_nil_but_do_not_sync
    gh_assignee = mock
    gh_assignee.stubs(login: 'old_assignee')

    issue, github = test_stubs gh_assignees: [gh_assignee]
    comparison = SyncIssues::Comparison.new(issue, github,
                                            sync_assignees: false)
    assert !comparison.changed?
    assert_equal [gh_assignee.login], comparison.assignees
    assert_equal [], comparison.changed
  end

  def test_changed_labels__do_not_update_when_previously_set
    issue, github = test_stubs(labels: ['new label'],
                               gh_labels: [{ name: 'old label' }])
    comparison = SyncIssues::Comparison.new(issue, github, reset_labels: false)
    assert !comparison.changed?
    assert_equal ['old label'], comparison.labels
    assert_equal [], comparison.changed
  end

  def test_changed_labels__update_when_previously_set_with_force__do_not_sync
    issue, github = test_stubs(labels: ['new label'],
                               gh_labels: [{ name: 'old label' }])
    comparison = SyncIssues::Comparison.new(issue, github, reset_labels: true,
                                                           sync_labels: false)
    assert !comparison.changed?
    assert_equal ['old label'], comparison.labels
    assert_equal [], comparison.changed
  end

  def test_changed_labels__update_when_previously_set_with_force
    issue, github = test_stubs(labels: ['new label'],
                               gh_labels: [{ name: 'old label' }])
    comparison = SyncIssues::Comparison.new(issue, github, reset_labels: true)
    assert comparison.changed?
    assert_equal ['new label'], comparison.labels
    assert_equal ['labels'], comparison.changed
  end

  def test_changed_labels__update_when_previously_unset
    issue, github = test_stubs(labels: ['new label'])
    [false, true].each do |reset|
      comparison = SyncIssues::Comparison.new(issue, github,
                                              reset_labels: reset)
      assert comparison.changed?
      assert_equal ['new label'], comparison.labels
      assert_equal ['labels'], comparison.changed
    end
  end

  def test_changed_labels__update_when_previously_unset__do_not_sync
    issue, github = test_stubs(labels: ['new label'])
    [false, true].each do |reset|
      comparison = SyncIssues::Comparison.new(issue, github,
                                              reset_labels: reset,
                                              sync_labels: false)
      assert !comparison.changed?
      assert_equal [], comparison.labels
      assert_equal [], comparison.changed
    end
  end

  def test_changed_labels__reset_case_only
    issue, github = test_stubs(labels: ['OLD label'],
                               gh_labels: [{ name: 'old label' }])
    comparison = SyncIssues::Comparison.new(issue, github, reset_labels: true)
    assert !comparison.changed?
    assert_equal ['old label'], comparison.labels
    assert_equal [], comparison.changed
  end

  def test_changed_labels_to_nil
    issue, github = test_stubs(labels: nil,
                               gh_labels: [{ name: 'old label' }])
    [false, true].each do |force|
      comparison = SyncIssues::Comparison.new(issue, github,
                                              reset_labels: force)
      assert !comparison.changed?
      assert_equal ['old label'], comparison.labels
      assert_equal [], comparison.changed
    end
  end

  def test_changed_title
    issue, github = test_stubs new_title: 'Something'
    comparison = SyncIssues::Comparison.new(issue, github,
                                            sync_assignees: true)
    assert comparison.changed?
    assert_equal ['title'], comparison.changed
  end

  def test_changed_body__with_assignees
    gh_assignee = mock
    gh_assignee.stubs(login: 'old_assignee')

    issue, github = test_stubs assignees: ['old_assignee'],
                               gh_assignees: [gh_assignee],
                               gh_content: 'Some other content'
    comparison = SyncIssues::Comparison.new(issue, github,
                                            sync_assignees: true)
    assert comparison.changed?
    assert_equal ['body'], comparison.changed
    assert_equal ['old_assignee'], comparison.assignees
    assert_equal issue.content, comparison.content
    assert_equal issue.title, comparison.title
  end

  def test_changed_body__without_assignees
    issue, github = test_stubs gh_content: 'Some other content'
    comparison = SyncIssues::Comparison.new(issue, github,
                                            sync_assignees: true)
    assert comparison.changed?
    assert_equal ['body'], comparison.changed
    assert_equal [], comparison.assignees
    assert_equal issue.content, comparison.content
    assert_equal issue.title, comparison.title
  end

  def test_changed_nothing__simple
    issue, github = test_stubs
    assert !SyncIssues::Comparison.new(issue, github,
                                       sync_assignees: true).changed?
  end

  def test_changed_nothing__assignee_set
    gh_assignee = mock
    gh_assignee.stubs(login: 'old_assignee')

    issue, github = test_stubs(assignees: ['old_assignee'],
                               gh_assignees: [gh_assignee])
    assert !SyncIssues::Comparison.new(issue, github,
                                       sync_assignees: true).changed?
  end

  def test_changed_nothing_but_markdown_checkbox
    issue, github = test_stubs(content: "- [ ] Some content\n",
                               gh_content: "- [x] Some content\r\n")

    comparison = SyncIssues::Comparison.new(issue, github,
                                            sync_assignees: true)
    assert !comparison.changed?
    assert_equal github.title, comparison.title
    assert_equal github.body, comparison.content
  end

  private

  def test_stubs(assignees: nil, content: 'Some content', labels: nil,
                 title: 'GitHub', new_title: nil, gh_assignees: [],
                 gh_content: 'Some content', gh_labels: [], gh_title: 'GitHub')
    issue = mock
    github = mock
    issue.stubs(assignees: assignees, content: content, labels: labels,
                title: title, new_title: new_title)
    github.stubs(assignees: gh_assignees, body: gh_content, labels: gh_labels,
                 title: gh_title)
    [issue, github]
  end
end
