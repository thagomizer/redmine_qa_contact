require File.dirname(__FILE__) + '/../test_helper'

class QueryPatchTest < ActiveSupport::TestCase
    fixtures :projects, :enabled_modules, :users, :members, :member_roles, :roles, :trackers, :issue_statuses, :issue_categories, :enumerations, :issues, :watchers, :custom_fields, :custom_values, :versions, :queries

  def setup
    User.current = User.find(1)

    # Turn on qa_contact for project 1
    EnabledModule.create!(:project_id => 1, :name => "qa_contact")
  end

  def teardown
    User.current = nil
  end

  def create_new_issue
    u = User.current

    issue = Issue.new(:project_id => 2, :tracker_id => 1, :author_id => 3, :status_id => 1, :priority => IssuePriority.all.first, :subject => 'test_create', :qa_contact => u)
    assert issue.save
    issue
  end

  def test_qa_contact_filter_in_project_queries
    proj = Project.find(1)
    query = Query.new(:project => proj, :name => '_')
    qa_contact_filter = query.available_filters["qa_contact_id"]

    assert_not_nil qa_contact_filter

    qa_contact_ids = qa_contact_filter[:values].map{|u| u[1]}

    expected_contacts = proj.issues.collect {|i| i.qa_contact_id}.uniq
    expected_contacts = expected_contacts.select{|e| e != nil}
    expected_count = proj.assignable_users.count + expected_contacts.count

    assert_equal expected_count, qa_contact_ids.count
  end

  def test_qa_contact_filter_in_global_queries
    query = Query.new(:project => nil, :name => '_')
    qa_contact_filter = query.available_filters["qa_contact_id"]

    assert_not_nil qa_contact_filter

    qa_contact_ids = qa_contact_filter[:values].map{|u| u[1]}

    users = []
    Project.find(:all).each do |p|
      users << p.users
    end
    users = users.flatten.uniq

    assert_equal users.length, qa_contact_ids.count
  end

  def test_available_filters_includes_qa_contact
    q = Query.new
    assert q.available_filters.include? "qa_contact_id"
  end


  def find_issues_with_query(query)
    Issue.find :all,
    :include => [ :assigned_to, :status, :tracker, :project, :qa_contact ],
    :conditions => query.statement
  end

  # = (equals), ! (not_equals), !* (none), * (all)
  #
  def test_filter_qa_contact_issues
    issues = []

    2.times do
      issues << create_new_issue
    end

    query = Query.new(:name => '_', :filters => { 'qa_contact_id' => {:operator => '=', :values => ['1']}})
    result = find_issues_with_query(query)
    assert_not_nil result
    assert !result.empty?
    assert_equal issues, result.sort_by(&:id)

    query = Query.new(:name => '_', :filters => { 'qa_contact_id' => {:operator => '!', :values => ['1']}})
    result = find_issues_with_query(query)
    assert_not_nil result
    assert !result.empty?
    assert_equal Issue.count - 2, result.count

    query = Query.new(:name => '_', :filters => { 'qa_contact_id' => {:operator => '=', :values => ['3']}})
    result = find_issues_with_query(query)
    assert_not_nil result
    assert result.empty?
    assert_equal [], result.sort_by(&:id)

    query = Query.new(:name => '_', :filters => { 'qa_contact_id' => {:operator => '!', :values => ['3']}})
    result = find_issues_with_query(query)
    assert_not_nil result
    assert !result.empty?
    assert_equal Issue.count, result.count

    issues.each do |i|
      i.delete
    end
  end
end
