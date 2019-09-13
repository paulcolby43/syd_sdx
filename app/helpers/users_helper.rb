module UsersHelper
  
  def users_sort_link(column, title = nil, role)
    title ||= column.titleize
    direction = (column == users_sort_column && users_sort_direction == "asc") ? "desc" : "asc"
    icon = (users_sort_direction == "asc" ? "fa fa-chevron-up" : "fa fa-chevron-down")
    icon = (column == users_sort_column ? icon : "")
    link_to "#{title} <i class='#{icon}'></i>".html_safe, {users_column: column, users_direction: direction, role: role}
  end
  
end
