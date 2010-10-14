require 'redmine'
require 'issue_patch'
require 'query_patch'
require 'issue_category_patch'

require_dependency 'qa_contact_issues_hook'

Redmine::Plugin.register :redmine_qa_contact do
  name 'Redmine Qa Contact plugin'
  author 'Aja Hammerly'
  description 'This plugin adds a QA contact field (ala bugzilla) to Redmine'
  version '0.0.2'

  project_module :qa_contact do
    permission :qa_contact, :public => true
  end
end
