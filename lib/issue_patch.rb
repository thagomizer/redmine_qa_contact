require_dependency 'issue'

# Patches Redmine's Issues dynamically.  Adds a relationship
# Issue +belongs_to+ to qa_contact
module IssuePatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      belongs_to :qa_contact, :class_name => 'User', :foreign_key => 'qa_contact_id'
      before_create :default_qa_contact
    end

  end

  module ClassMethods
  end

  module InstanceMethods
    def default_qa_contact
      if qa_contact.nil? && category && category.qa_contact
        self.qa_contact = category.qa_contact
      end
    end
  end
end

# Add module to Issue
Issue.send(:include, IssuePatch)

