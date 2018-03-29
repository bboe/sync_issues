require 'minitest/autorun'
require 'sync_issues'

# Test SycnIssues::Issue
class IssueTest < MiniTest::Test
  def test_invalid_issue_blank_assignees
    ['', ' ', "\n", " \n", "\n\n"].each do |assignee|
      begin
        SyncIssues::Issue.new('Content', title: 'A title', assignees: assignee)
        assert false
      rescue SyncIssues::IssueError => exc
        assert_equal "'assignees' must not be blank", exc.message
      end
    end
  end

  def test_invalid_issue_blank_labels
    ['', ' ', "\n", " \n", "\n\n"].each do |labels|
      begin
        SyncIssues::Issue.new('Content', title: 'A title', labels: labels)
        assert false
      rescue SyncIssues::IssueError => exc
        assert_equal "'labels' must not be blank", exc.message
      end
    end
  end

  def test_invalid_issue_blank_labels_in_array
    ['', ' ', "\n", " \n", "\n\n"].each do |label|
      begin
        SyncIssues::Issue.new('Content', title: 'A title', labels: [label])
        assert false
      rescue SyncIssues::IssueError => exc
        assert_equal "'labels[0]' must not be blank", exc.message
      end
    end
  end

  def test_invalid_issue_blank_title
    ['', ' ', "\n", " \n", "\n\n"].each do |title|
      begin
        SyncIssues::Issue.new('Content', title: title)
        assert false
      rescue SyncIssues::IssueError => exc
        assert_equal "'title' must not be blank", exc.message
      end
    end
  end

  def test_invalid_issue_invalid_label
    [1, {}].each do |label|
      begin
        SyncIssues::Issue.new('Content', title: 'Title', labels: label)
        assert false
      rescue SyncIssues::IssueError => exc
        assert_equal "'labels' must be an Array or a String", exc.message
      end
    end
  end

  def test_invalid_issue_invalid_label_in_array
    [1, {}].each do |label|
      begin
        SyncIssues::Issue.new('Content', title: 'Title',
                                         labels: ['a', 'b', label])
        assert false
      rescue SyncIssues::IssueError => exc
        assert_equal "'labels[2]' must be a String", exc.message
      end
    end
  end

  def test_invalid_issue_invalid_title
    [1, [], {}].each do |title|
      begin
        SyncIssues::Issue.new('Content', title: title)
        assert false
      rescue SyncIssues::IssueError => exc
        assert_equal "'title' must be a String", exc.message
      end
    end
  end

  def test_invalid_issue_title_is_nil
    SyncIssues::Issue.new('Content', title: nil)
    assert false
  rescue SyncIssues::IssueError => exc
    assert_equal "'title' must be provided", exc.message
  end

  def test_valid_issue_string_labels
    issue = SyncIssues::Issue.new('Content', title: 'A title',
                                             assignees: ['bboe'],
                                             labels: 'label, string')
    assert_equal 'Content', issue.content
    assert_equal 'A title', issue.title
    assert_equal ['bboe'], issue.assignees
    assert_equal ['label, string'], issue.labels
  end

  def test_valid_issue_with_all_fields
    issue = SyncIssues::Issue.new('Content', title: 'A title',
                                             assignees: 'bboe',
                                             labels: %w(a b))
    assert_equal 'Content', issue.content
    assert_equal 'A title', issue.title
    assert_equal ['bboe'], issue.assignees
    assert_equal %w(a b), issue.labels
  end

  def test_valid_issue_with_only_title
    issue = SyncIssues::Issue.new('Content', title: 'A title')
    assert_equal 'Content', issue.content
    assert_equal 'A title', issue.title
    assert_equal nil, issue.assignees
  end
end
