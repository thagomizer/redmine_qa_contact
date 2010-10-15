require_dependency 'query'

# Patches Redmine's Queries dynamically.
# Adds a filter on qa_contact_id
module QueryPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      base.add_available_column(QueryColumn.new(:qa_contact, :sortable => ["#{User.table_name}.lastname", "#{User.table_name}.firstname", "#{User.table_name}.id"], :groupable => true))

        alias_method :redmine_available_filters, :available_filters
        alias_method :available_filters, :qa_contact_available_filters
    end

  end

  module ClassMethods
    # Setter for +available_columns+ that isn't provided by the core.
    def available_columns=(v)
      self.available_columns = (v)
    end

    # Method to add a column to the +available_columns+ that isn't provided by the core.
    def add_available_column(column)
      self.available_columns << (column)
    end
  end

  module InstanceMethods

    # Wrapper around the +available_filters+ to add a new Deliverable filter
    def qa_contact_available_filters
      @available_filters = redmine_available_filters

      user_values = []
      if project
        if !project.module_enabled?('qa_contact')
          qa_contact_filters = { }
        else
          user_values += project.users.sort.collect{|s| [s.name, s.id.to_s] }
        end
      else
        project_ids = Project.all(:conditions => Project.visible_by(User.current)).collect(&:id)
        if project_ids.any?
          # members of the user's projects
          user_values += User.active.find(:all, :conditions => ["#{User.table_name}.id IN (SELECT DISTINCT user_id FROM members WHERE project_id IN (?))", project_ids]).sort.collect{|s| [s.name, s.id.to_s] }
        end
      end

      qa_contact_filters = {"qa_contact_id" => { :type => :list_optional, :order => 4, :values => user_values }} unless user_values.empty?

      return @available_filters.merge(qa_contact_filters)
    end
  end
end

# Add module to Query
Query.send(:include, QueryPatch)
