Spree::Admin::BaseHelper.module_eval do

  def preference_field_for(form, field, options)
    case options[:type]
      when :integer
        form.text_field(field, preference_field_options(options))
      when :boolean
        form.check_box(field, preference_field_options(options))
      when :string
        form.text_field(field, preference_field_options(options))
      when :password
        form.password_field(field, preference_field_options(options))
      when :text
        form.text_area(field, preference_field_options(options))
      when :boolean_select
        content_tag('div', class: 'form-group', 'data-hook' => field) do
          label_tag(field, Spree.t(field))
          form.select(field, {Spree.t(:enabled) => true, Spree.t(:disabled) => false}, {}, class: 'select2')
        end
      when :select
        content_tag('div', class: 'form-group', 'data-hook' => field) do
          label_tag(field, Spree.t(field))
          form.select(field, options_for_select(options[:values].map { |key| [I18n.t(key, scope: 'braintree.preferences'), key] }, options[:selected]), {}, class: 'select2')
        end
      else
        form.text_field(field, preference_field_options(options))
    end
  end

  def preference_field_tag(name, value, options)
    case options[:type]
      when :integer
        text_field_tag(name, value, preference_field_options(options))
      when :boolean
        hidden_field_tag(name, 0, id: "#{name}_hidden") +
          check_box_tag(name, 1, value, preference_field_options(options))
      when :string
        text_field_tag(name, value, preference_field_options(options))
      when :password
        password_field_tag(name, value, preference_field_options(options))
      when :text
        text_area_tag(name, value, preference_field_options(options))
      when :boolean_select
        select_tag(name, value, preference_field_options(options))
      when :select
        select_tag(name, value, preference_field_options(options))
      else
        text_field_tag(name, value, preference_field_options(options))
    end
  end

  def preference_fields(object, form)
    return unless object.respond_to?(:preferences)
    object.preferences.keys.map { |key|
      if object.has_preference?(key)
        form.label("preferred_#{key}", Spree.t(key) + ": ") +
          preference_field_for(form, "preferred_#{key}", type: object.preference_type(key),
                               values: object.send("preferred_#{key}_default").is_a?(Hash) ? object.send("preferred_#{key}_default")[:values] : nil,
                               selected: object.preferences[key])
      end
    }.join("<br />").html_safe
  end


end