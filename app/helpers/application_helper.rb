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

  def can_manage_dispatches?
    current_user&.super_admin? || current_user&.admin_officer? || current_user&.dispatch_officer?
  end

  def can_create_incidents?
    current_user&.super_admin? || current_user&.admin_officer?
  end

  def can_manage_logs?
    current_user&.super_admin? || current_user&.admin_officer? || current_user&.unit_officer?
  end

  def can_delete_logs?
    current_user&.super_admin? || current_user&.admin_officer?
  end



 def nav_link_class(path)
  base = "flex items-center px-4 py-2.5 text-sm font-medium transition-colors"
  active = "bg-green-50 text-green-800 border-l-4 border-green-700 font-semibold shadow-sm"
  inactive = "text-slate-700 hover:bg-green-50 hover:text-green-800"

  current_page?(path) ? "#{base} #{active}" : "#{base} #{inactive}"
end

  def reports_nav_link_class
  base = "block px-3 py-2"
  active = "bg-slate-700 text-white font-medium"
  inactive = "text-slate-200 hover:bg-slate-800 hover:text-white"

  request.path.start_with?("/reports") ? "#{base} #{active}" : "#{base} #{inactive}"
end

def btn_primary
  "inline-flex items-center justify-center bg-green-700 hover:bg-green-800 text-white px-4 py-2 text-sm font-medium transition-colors"
end

def btn_secondary
  "inline-flex items-center justify-center border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 px-4 py-2 text-sm font-medium transition-colors"
end

def btn_danger
  "inline-flex items-center justify-center bg-red-600 hover:bg-red-700 text-white px-4 py-2 text-sm font-medium transition-colors"
end

def btn_success
  "inline-flex items-center justify-center bg-green-600 hover:bg-green-700 text-white px-4 py-2 text-sm font-medium transition-colors"
end

def card_class
  "bg-white border border-slate-200 shadow-sm"
end

def page_header_class
  "bg-white border border-slate-200 px-6 py-5 shadow-sm"
end
end