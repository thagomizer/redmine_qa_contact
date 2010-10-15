require File.dirname(__FILE__) + '/../test_helper'
require 'issue_categories_controller'

# Re-raise errors caught by the controller.
class IssueCategoriesController; def rescue_action(e) raise e end; end

class IssueCategoriesControllerTest < ActionController::TestCase
  fixtures :projects, :users, :members, :member_roles, :roles, :enabled_modules, :issue_categories

  def setup
    @controller = IssueCategoriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
    @request.session[:user_id] = 2

    # Turn on the qa_contact module
    EnabledModule.create!(:project_id => 1, :name => "qa_contact")
  end

  def test_get_new
    get :new, :project_id => '1'
    assert_response :success
    assert_template 'new'
    assert_match /QA contact/, @response.body
  end

  def test_post_new
    assert_difference 'IssueCategory.count' do
      post :new, :project_id => '1',
                 :category   => { :name           => 'New category',
                                  :assigned_to_id => "#{User.find(3).id}",
                                  :qa_contact_id  => "#{User.find(1).id}"}
    end
    assert_redirected_to '/projects/ecookbook/settings/categories'
    category = IssueCategory.find_by_name('New category')
    assert_not_nil category
    assert_equal User.find(1), category.qa_contact
  end

  def test_get_edit
    issue = IssueCategory.create!(:name => "Category", :qa_contact => User.find(4), :assigned_to => User.find(3), :project => Project.find(1))

    get :edit, :id => issue.id
    assert_response :success
    assert_match /QA contact/, @response.body
  end

  def test_post_edit
    assert_no_difference 'IssueCategory.count' do
      post :edit, :id => 2, :category => {:qa_contact_id => "#{User.find(4).id}"}
    end

    assert_redirected_to '/projects/ecookbook/settings/categories'
    assert_equal User.find(4), IssueCategory.find(2).qa_contact

    assert_no_difference 'IssueCategory.count' do
      post :edit, :id => 2, :category => {:qa_contact_id => "#{User.find(1).id}"}
    end

    assert_redirected_to '/projects/ecookbook/settings/categories'
    assert_equal User.find(1), IssueCategory.find(2).qa_contact
  end

  def test_project_with_qa_contact_disabled
    project = Project.find(2)

    get :new, :project_id => '2'
    assert_response :success
    assert_template 'new'
    assert_no_match /QA contact/, @response.body

    issue = IssueCategory.create!(:name => "Category", :qa_contact => User.find(4), :assigned_to => User.find(3), :project => project)

    get :edit, :id => issue.id
    assert_response :success
    assert_no_match /QA contact/, @response.body
  end
end
