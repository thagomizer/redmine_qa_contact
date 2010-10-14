class AddQaContactToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :qa_contact_id, :integer
  end

  def self.down
    remove_column :issues, :qa_contact_id
  end
end
