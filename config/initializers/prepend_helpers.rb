Rails.application.config.after_initialize do
  Spree::Admin::NavigationHelper.prepend(Spree::Admin::DecoratedNavigationHelper)
end
