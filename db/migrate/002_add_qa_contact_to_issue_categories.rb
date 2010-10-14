class AddQaContactToIssueCategories < ActiveRecord::Migration
  def self.up
    add_column :issue_categories, :qa_contact_id, :integer
  end

  def self.down
    remove_column :issue_categories, :qa_contact_id
  end
end
