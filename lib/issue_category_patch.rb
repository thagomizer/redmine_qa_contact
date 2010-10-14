require_dependency 'issue_category'

# Patches Redmine's IssueCategories dynamically.  Adds a relationship
# IssueCategory +belongs_to+ to qa_contact
module IssueCategoryPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      belongs_to :qa_contact, :class_name => 'User', :foreign_key => 'qa_contact_id'

    end

  end

  module ClassMethods

  end

  module InstanceMethods
  end
end

# Add module to Issue
IssueCategory.send(:include, IssueCategoryPatch)

