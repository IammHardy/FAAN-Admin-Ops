module ApplicationHelper
  def flash_class(type)
    case type.to_sym
    when :notice, :success
      "bg-green-50 border-green-300 text-green-800"
    when :alert, :error
      "bg-red-50 border-red-300 text-red-800"
    when :warning
      "bg-yellow-50 border-yellow-300 text-yellow-800"
    when :info
      "bg-blue-50 border-blue-300 text-blue-800"
    else
      "bg-gray-50 border-gray-300 text-gray-800"
    end
  end

  def nav_link_class(path)
    base = "block px-3 py-2"
    active = "bg-slate-700 text-white font-medium"
    inactive = "text-slate-200 hover:bg-slate-800 hover:text-white"

    current_page?(path) ? "#{base} #{active}" : "#{base} #{inactive}"
  end
end