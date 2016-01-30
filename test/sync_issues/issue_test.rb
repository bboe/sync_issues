require 'minitest/autorun'
require 'mocha'
require 'mocha/mini_test'
require 'sync_issues'

# Test SycnIssues::Issue
class IssueTest < MiniTest::Test
  def test_invalid_issue_blank_assignee
    ['', ' ', "\n", " \n", "\n\n"].each do |assignee|
      begin
        SyncIssues::Issue.new('Content', title: 'A title', assignee: assignee)
        assert false
      rescue SyncIssues::IssueError => exc
        assert_equal "'assignee' must not be blank", exc.message
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

  def test_invalid_issue_invalid_title
    [1, [], {}].each do |title|
      begin
        SyncIssues::Issue.new('Content', title: title)
        assert false
      rescue SyncIssues::IssueError => exc
        assert_equal "'title' must be a string", exc.message
      end
    end
  end

  def test_invalid_issue_title_is_nil
    SyncIssues::Issue.new('Content', title: nil)
    assert false
  rescue SyncIssues::IssueError => exc
    assert_equal "'title' must be provided", exc.message
  end

  def test_valid_issue_with_all_fields
    issue = SyncIssues::Issue.new('Content', title: 'A title',
                                             assignee: 'bboe')
    assert_equal 'Content', issue.content
    assert_equal 'A title', issue.title
    assert_equal 'bboe', issue.assignee
  end

  def test_valid_issue_with_only_title
    issue = SyncIssues::Issue.new('Content', title: 'A title')
    assert_equal 'Content', issue.content
    assert_equal 'A title', issue.title
    assert_equal nil, issue.assignee
  end
end
