module TripsHelper
  def tab_link(path, icon_name, label, count = nil, controller = nil)
    active = current_page?(path)

    # Base classes for both main tabs and dropdown items
    base_classes = "whitespace-nowrap font-medium text-sm flex items-center"

    # Main tab classes (default)
    main_classes = [
      base_classes,
      "py-4 px-1 border-b-2",
      active ? "border-blue-500 text-blue-600" : "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
    ].join(" ")

    # Dropdown item classes (will be applied via CSS when moved to dropdown)
    dropdown_classes = [
      base_classes,
      "px-4 py-2 text-gray-700 hover:bg-gray-100 w-full",
      active ? "bg-blue-50 text-blue-600" : ""
    ].join(" ")

    data_attrs = {}
    if controller
      data_attrs["#{controller.gsub('_', '-')}-target"] = "tab"
      data_attrs["dropdown-classes"] = dropdown_classes
    end

    link_to path,
            class: main_classes,
            "aria-current": active ? "page" : nil,
            data: data_attrs do
      concat heroicon icon_name, options: { class: "w-4 h-4 mr-2", "aria-hidden": "true" }

      concat label
      if count
        concat tag.span count, class: "ml-1 bg-gray-200 text-gray-900 rounded-full px-2 py-1 text-xs font-medium"
      end
    end
  end
end
