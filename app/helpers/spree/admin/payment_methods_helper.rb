module Spree
  module Admin
    module PaymentMethodsHelper
      def preference_field_for(form, field, options)
        case options[:type]
        when :integer
          form.text_field(field, preference_field_options(options))
        when :boolean
          form.check_box(field, preference_field_options(options))
        when :string
          if field.eql?('preferred_descriptor_name')
             content_tag(:div,
                         Spree.t('descriptor_name_information_box_text').html_safe,
                         class: 'alert alert-warning'
             )
          end.to_s.html_safe +
            form.text_field(field, preference_field_options(options))
        when :password
          form.password_field(field, preference_field_options(options))
        when :text
          form.text_area(field, preference_field_options(options))
        when :boolean_select
          label_tag(field, Spree.t(field))
          form.select(field, {
            Spree.t(:enabled) => true,
            Spree.t(:disabled) => false
          },
          {},
          class: 'select2')
        when :select
          label_tag(field, Spree.t(field))
          form.select(field, options_for_select(options[:values].map { |key| [I18n.t(key, scope: 'braintree.preferences'), key] }, options[:selected]), {}, class: 'select2')
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

        get_preference_fields(object, object.preferences.keys, form)
      end

      def braintree_basic_preference_fields(object, form)
        return unless object.respond_to?(:preferences)

        keys = object.preferences.slice(*basic_braintree_preference_keys).keys
        get_preference_fields(object, keys, form)
      end

      def braintree_advanced_preference_fields(object, form)
        return unless object.respond_to?(:preferences)

        keys = object.preferences.keys.reverse - basic_braintree_preference_keys
        keys_left, keys_right = keys.each_slice((keys.size / 2.0).ceil).to_a

        content_tag(:div, get_preference_fields(object, keys_left, form), class: 'col-md-6') +
          content_tag(:div, get_preference_fields(object, keys_right, form), class: 'col-md-6')
      end

      def get_preference_fields(object, keys, form)
        keys.reject { |k| k == :currency_merchant_accounts }.map do |key|
          next unless object.has_preference?(key)

          content_tag(:div, class: 'form-group', 'data-hook' => "preferred_#{key}") do
            form.label("preferred_#{key}", Spree.t(key) + ': ') +
              preference_field_for(form, "preferred_#{key}", type: object.preference_type(key),
                                 values: object.send("preferred_#{key}_default").is_a?(Hash) ? object.send("preferred_#{key}_default")[:values] : nil,
                                 selected: object.preferences[key])
          end
        end.join(' ').html_safe
      end

      def basic_braintree_preference_keys
        %i[merchant_id public_key private_key server test_mode]
      end
    end
  end
end
