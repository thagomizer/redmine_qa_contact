require File.dirname(__FILE__) + '/../test_helper'
require 'issues_controller'

# Re-raise errors caught by the controller.
class IssuesController; def rescue_action(e) raise e end; end

class IssuesControllerTest < ActionController::TestCase
    fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_trackers,
           :time_entries,
           :journals,
           :journal_details,
           :queries

  def create_new_issue
    u = User.find(2)

    issue = Issue.new(:project_id => 1, :tracker_id => 1, :author_id => 3, :status_id => 1, :priority => IssuePriority.all.first, :subject => 'test_create', :qa_contact => u)
    assert issue.save
    issue
  end


  def setup
    @controller = IssuesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil

    # Turn on the qa_contact module
    EnabledModule.create(:project_id => 1, :name => "qa_contact")
  end

  def test_show_has_qa_contact
    issue = create_new_issue
    username = User.find(2).name(:firstname_lastname)

    @request.session[:user_id] = 2
    get :show, :id => issue.id
    assert_response :success

    assert_match /QA contact/, @response.body
    assert_match /#{username}/, @response.body

    # If no qa_contact it shouldn't error
    issue.qa_contact = nil
    issue.save!

    get :show, :id => issue.id
    assert_response :success

    assert_match /QA contact/, @response.body
  end

  def test_show_has_qa_contact_if_enabled
    issue = create_new_issue
    username = User.find(2).name(:firstname_lastname)

    @request.session[:user_id] = 2
    get :show, :id => issue.id
    assert_response :success

    assert_match /QA contact/, @response.body
    assert_match /#{username}/, @response.body

    # If no qa_contact it shouldn't error
    issue.qa_contact = nil
    issue.save!

    get :show, :id => issue.id
    assert_response :success

    assert_match /QA contact/, @response.body
  end

  def test_new_does_not_have_qa_contact_if_disabled
    username = User.find(2).name(:firstname_lastname)

    @request.session[:user_id] = 2
    get :new, :project_id => 2
    assert_response :success

    assert_no_match /QA contact/, @response.body
  end

  def test_new_does_not_have_qa_contact_if_disabled
    username = User.find(2).name(:firstname_lastname)

    @request.session[:user_id] = 2
    get :new, :project_id => 2
    assert_response :success

    assert_no_match /QA contact/, @response.body
  end

  def test_edit_has_qa_contact_if_enabled
    issue = create_new_issue
    username = User.find(2).name(:firstname_lastname)

    @request.session[:user_id] = 2
    get :edit, :id => issue.id
    assert_response :success

    assert_match /QA contact/, @response.body
    assert_match /#{username}/, @response.body
  end

  def test_edit_has_qa_contact_if_enabled
    issue = create_new_issue
    issue.project_id = 2
    issue.save!

    username = User.find(2).name(:firstname_lastname)

    @request.session[:user_id] = 2
    get :edit, :id => issue.id
    assert_response :success

    assert_no_match /QA contact/, @response.body
  end

  def test_set_qa_contact_on_create
    @request.session[:user_id] = 2
    assert_difference 'Issue.count', 1 do
      post :create, :project_id => 1,
                    :issue     => { :tracker_id    => '3',
                                    :status_id     => '2',
                                    :subject       => 'This is the new issue',
                                    :description   => 'This is the description',
                                    :priority_id   => '5',
                                    :qa_contact_id => '3'}
    end

    new_issue = Issue.find_by_subject("This is the new issue")
    assert_not_nil new_issue
    assert_equal User.find(3), new_issue.qa_contact
  end

  def test_edit_qa_contact
    issue = Issue.find(1)
    assert_equal nil, issue.qa_contact_id
    @request.session[:user_id] = 2

    put :update, :id => 1, :issue => {:qa_contact_id => 3}
    assert_redirected_to :action => 'show', :id => '1'

    issue.reload
    assert_equal User.find(3), issue.qa_contact

    put :update, :id => 1, :issue => {:qa_contact_id => 1}
    assert_redirected_to :action => 'show', :id => '1'

    issue.reload
    assert_equal User.find(1), issue.qa_contact
  end

  def test_bulk_edit_qa_contact
    u = User.find(User.count)
    assert_not_nil u

    @request.session[:user_id] = 2

    post :bulk_update, :ids   => [1, 2],
                       :notes => 'Bulk editing',
                       :qa_contact_id => u.id

    assert_response 302

    # Verify both issues were updated
    assert_equal [u.id, u.id], Issue.find_all_by_id([1, 2]).collect {|i| i.qa_contact_id}

  end
end
