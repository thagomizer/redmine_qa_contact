require File.dirname(__FILE__) + '/../test_helper'

class IssueCategoryPatchTest < ActiveSupport::TestCase
  fixtures :issue_categories, :issues, :users, :projects

  def create_new_issue_category_with_qa_contact
    issue_category = IssueCategory.new(:project_id => 1, :assigned_to => User.find(2), :qa_contact => User.find(3))
    issue_category.qa_contact = User.find(1)
    issue_category

    assert_equal User.find(2), issue_category.assigned_to
    assert_equal User.find(3), issue_category.qa_contact
  end

  def create_new_issue_based_on_issue_category
    issue_category = IssueCategory.new(:project_id => 1, :assigned_to => User.find(2), :qa_contact => User.find(3))
    issue_category.qa_contact = User.find(1)
    issue_category

    assert_equal User.find(2), issue_category.assigned_to
    assert_equal User.find(3), issue_category.qa_contact

    issue = Issue.new(:project_id => 1, :category => issue_category)

    assert_equal User.find(2), issue.assigned_to
    assert_equal User.find(3), issue.qa_contact
  end
end
