class QaContactIssuesHook < Redmine::Hook::ViewListener
  # Renders the QA Contact Name
  #
  # Context:
  # * :issue => Issue being rendered
  #
  def view_issues_show_details_bottom(context = { })
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
    select = context[:form].select :qa_contact_id, context[:project].assignable_users.collect {|u| [u.name, u.id]}, :include_blank => true
    return "<p>#{select}</p>"
  end

  # Renders a drop down containing the possible QA Contacts
  #
  # Context
  # * :project => project for the issue
  #
  def view_issues_bulk_edit_details_bottom(context = { })
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
      context[:issue].qa_contact = User.find(qa_contact_id)
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

end
