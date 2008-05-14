module ActsAsConfigurable
  module FormBuilder
    def select_options
      returning "" do |html|
        html << %Q[<ul id="#{@object_name}_options">]
        @object.options.each_item do |item_name, item|
          html << @template.content_tag(:li, option_item_field(item) )
        end
        html << %q[</ul>]
      end
    end

    def option_item_field(item)
      returning "" do |html|
        field_dom = "#{@object_name}_options_#{item.name}"
        html << @template.content_tag(:label, item.name, :for => field_dom)
        html << case item 
                when BooleanItem
                  @template.check_box_tag("#{@object_name}[options][#{item.name}]", "1", @object.options[item.name], :id => field_dom)
                else
                  @template.text_field_tag("#{@object_name}[options][#{item.name}]", @object.options[item.name], :id => field_dom)
                end
      end
    end
  end
end
