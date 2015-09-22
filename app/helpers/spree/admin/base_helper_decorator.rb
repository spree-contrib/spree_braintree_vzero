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
        form.select(field, [true, false])
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
      else
        text_field_tag(name, value, preference_field_options(options))
    end
  end


end