module Spree
  module Admin
    module DecoratedNavigationHelper
      def link_to_with_icon(icon_name, text, url, options = {})
        icon_name = 'capture' if icon_name.eql?('settle')
        super
      end
    end
  end
end
