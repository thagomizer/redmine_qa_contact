class QaContactIssuesHook < Redmine::Hook::ViewListener
  def find_name_by_reflection(field, id)
    association = Issue.reflect_on_association(field.to_sym)
    if association
      record = association.class_name.constantize.find_by_id(id)
      return record.name if record
    end
  end

  # Renders the QA Contact Name
  #
  # Context:
  # * :issue => Issue being rendered
  #
  def view_issues_show_details_bottom(context = { })
    return '' unless context[:project].module_enabled?('qa_contact')
    issue = context[:issue]

    if issue.qa_contact then
      return "<tr><td><b>QA contact:</b></td><td> #{context[:issue].qa_contact.name}</td></tr>"
    else
      return "<tr><td><b>QA contact:</b></td></tr>"
    end
  end

  # Renders a drop down containing the possible QA Contacts
  #
  # Context
  # * :project => project for the issue
  # * :issue => Issue being created/editted
  #
  def view_issues_form_details_bottom(context = { })
    return '' unless context[:project].module_enabled?('qa_contact')

    select = context[:form].select :qa_contact_id, context[:project].assignable_users.collect {|u| [u.name, u.id]}, :include_blank => true
    return "<p>#{select}</p>"
  end

  # Renders a drop down containing the possible QA Contacts
  #
  # Context
  # * :project => project for the issue
  #
  def view_issues_bulk_edit_details_bottom(context = { })
    return '' unless context[:project].module_enabled?('qa_contact')
    select = select_tag('qa_contact_id',
                        content_tag('option', l(:label_no_change_option), :value => '') +
                        options_from_collection_for_select(context[:project].assignable_users, :id, :name))
    return "<p><label>QA contact:</label> #{select} </p>"
  end

  # Saves the QA contact into a new issue
  #
  # Context
  # * :params => params passed back by the form
  # * :issue => the new issue
  #
  def controller_issues_new_before_save(context = { })
    if context[:params][:issue][:qa_contact_id] =~ /(\d+)/ then
      qa_contact_id = context[:params][:issue][:qa_contact_id].to_i
      context[:issue].qa_contact = User.find(qa_contact_id)
    end

    return ''
  end

  # Saves the QA contact when an issue is updated
  #
  # Context
  # * :params => params passed back from the form
  # * :issue => the issue
  def controller_issues_edit_before_save(context = { })
    if context[:params][:issue][:qa_contact_id] then
      qa_contact_id = context[:params][:issue][:qa_contact_id]
      unless qa_contact_id == ''
        context[:issue].qa_contact = User.find(qa_contact_id)
      end
    end

    return ''
  end

  # Saves the QA contact when issues are updated via bulk_edit
  #
  # Context
  # * :params => params passed back from the form
  # * :issue => the issue
  def controller_issues_bulk_edit_before_save(context = { })
    qa_contact_id = context[:params][:qa_contact_id]

    if qa_contact_id.blank? then
      # Do nothing
    elsif context[:params][:qa_contact_id] =~ /(\d+)/ then
      context[:issue].qa_contact = User.find(qa_contact_id.to_i)
    end

    return ''
  end

  def helper_issues_show_detail_after_setting(context = {})
    # These should be setting context[:old_value] and context[:new_value]
    # But because of redmine bug 3672 I can't.  That sucks and annoys me.

    detail    = context[:detail]
    field     = detail.prop_key.to_s.gsub(/\_id/, "")
    label     = context[:label]
    value     = context[:detail].value
    old_value = context[:detail].old_value

    if label == "QA contact"
      context[:detail].value = find_name_by_reflection(field, value)
      context[:detail].old_value = find_name_by_reflection(field, old_value)
    end
  end
end
