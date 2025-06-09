module TripsHelper
  def tab_link(path, icon_name, label, count = nil)
    active = current_page?(path)

    classes = [
      "whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm flex items-center",
      active ? "border-blue-500 text-blue-600" : "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
    ].join(" ")

    link_to path, class: classes, "aria-current": active ? "page" : nil do
      concat heroicon icon_name, options: { class: "w-4 h-4 mr-2", "aria-hidden": "true" }

      concat label
      if count
        concat tag.span count, class: "ml-1 bg-gray-200 text-gray-900 rounded-full px-2 py-1 text-xs font-medium"
      end
    end
  end
end
