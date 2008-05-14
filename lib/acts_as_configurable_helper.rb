module ActsAsConfigurable
  module FormBuilder
    def select_options
      returning "" do |html|
        @object.options.each_item do |item_name, item|
          html << field_for_option_item(item)
        end
      end
    end

    def field_for_option_item(item)
      @template.text_field_tag "#{@object_name}[options][#{item.name}]"
    end
  end
end
