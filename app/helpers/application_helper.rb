module ApplicationHelper

  def flash_class(type)
    case type.to_sym
    when :notice, :success
      "app-flash-success"
    when :alert, :error
      "app-flash-error"
    when :warning
      "app-flash-warning"
    when :info
      "app-flash-info"
    else
      "app-flash-info"
    end
  end


  def nav_link_class(path)
    base = "block px-3 py-2"
    active = "bg-slate-700 text-white font-medium"
    inactive = "text-slate-200 hover:bg-slate-800 hover:text-white"

    current_page?(path) ? "#{base} #{active}" : "#{base} #{inactive}"
  end

  def reports_nav_link_class
  base = "block px-3 py-2"
  active = "bg-slate-700 text-white font-medium"
  inactive = "text-slate-200 hover:bg-slate-800 hover:text-white"

  request.path.start_with?("/reports") ? "#{base} #{active}" : "#{base} #{inactive}"
end
end