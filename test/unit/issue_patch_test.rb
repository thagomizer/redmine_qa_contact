require File.dirname(__FILE__) + '/../test_helper'

class IssuePatchTest < ActiveSupport::TestCase
    fixtures :projects, :users, :members, :member_roles, :roles,
           :trackers, :projects_trackers,
           :enabled_modules,
           :versions,
           :issue_statuses, :issue_categories, :issue_relations, :workflows,
           :enumerations,
           :issues,
           :custom_fields, :custom_fields_projects, :custom_fields_trackers, :custom_values,
           :time_entries

  def create_new_issue
    u = User.find(2)

    issue = Issue.new(:project_id => 1, :tracker_id => 1, :author_id => 3, :status_id => 1, :priority => IssuePriority.all.first, :subject => 'test_create', :qa_contact => u)
    assert issue.save
    issue
  end

  def test_create_qa_contact
    issue = create_new_issue

    assert_not_nil issue.qa_contact
    assert_equal User.find(2), issue.qa_contact
  end

  def test_update_qa_contact
    issue = create_new_issue

    assert_equal User.find(2), issue.qa_contact

    issue.qa_contact = User.find(3)
    issue.save!

    assert_equal User.find(3), issue.qa_contact
  end

  def test_category_based_assignment
    category = IssueCategory.find(1)
    category.qa_contact = User.find(3)
    category.save!

    issue = Issue.create(:project_id => 1, :tracker_id => 1, :author_id => 3, :status_id => 1, :priority => IssuePriority.all.first, :subject => 'Assignment test', :description => 'Assignment test', :category_id => 1)

    assert_equal category.assigned_to, issue.assigned_to
    assert_equal category.qa_contact, issue.qa_contact
  end
end
