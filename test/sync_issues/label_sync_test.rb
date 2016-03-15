require 'minitest/autorun'
require 'sync_issues'

# Test SyncIssues::LabelSync
class LabelSyncTest < MiniTest::Test
  def test_yaml_nothing_of_use
    [nil, '', 'unused: foo', 'keep_existing: flse', # typo should == true
     'keep_existing: true'].each do |yaml|
      label_sync = SyncIssues::LabelSync.new(nil, yaml)
      assert !label_sync.do_work
    end
  end

  def test_yaml_delete_only
    label_sync = SyncIssues::LabelSync.new(nil, 'keep_existing: false')
    assert label_sync.do_work
    assert !label_sync.keep_existing
    assert_equal({}, label_sync.labels)
  end

  def test_yaml_invalid
    SyncIssues::LabelSync.new(nil, 'a: b: c')
    assert false
  rescue SyncIssues::ParseError => exc
    assert_equal 'invalid label yaml file', exc.message
  end

  def test_yaml_label_color_is_a_number
    SyncIssues::LabelSync.new(nil, "labels:\n  bad: 000000")
    assert false
  rescue SyncIssues::Error => exc
    assert_equal('Label error: add quotes around numeric color values',
                 exc.message)
  end

  def test_yaml_labels_is_not_a_hash
    label_sync = SyncIssues::LabelSync.new(
      nil, "keep_existing: false\nlabels: a")
    assert label_sync.do_work
    assert !label_sync.keep_existing
    assert_equal({}, label_sync.labels)
  end

  def test_yaml_labels_only
    label_sync = SyncIssues::LabelSync.new(nil, "labels:\n  merged: '009800'")
    assert label_sync.do_work
    assert label_sync.keep_existing
    assert_equal({ 'merged' => '009800' }, label_sync.labels)
  end

  def test_yaml_nil
    label_sync = SyncIssues::LabelSync.new(nil, nil)
    assert !label_sync.do_work
    assert label_sync.keep_existing.nil?
    assert label_sync.labels.nil?
  end

  def test_yaml_valid
    label_sync = SyncIssues::LabelSync.new(
      nil, <<-YML
      keep_existing: false
      labels:
        in progress: FF00FF
        unstarted: '000088'
    YML
    )
    assert label_sync.do_work
    assert !label_sync.keep_existing
    assert_equal({ 'in progress' => 'ff00ff',
                   'unstarted' => '000088' }, label_sync.labels)
  end
end
