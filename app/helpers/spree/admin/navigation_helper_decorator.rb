Spree::Admin::NavigationHelper.module_eval do
  alias_method :original_link_to_with_icon, :link_to_with_icon

  def link_to_with_icon(icon_name, text, url, options = {})
    icon_name = 'capture' if icon_name.eql?('settle')
    original_link_to_with_icon(icon_name, text, url, options)
  end
end
