module Slim
  # @api private
  class BooleanAttributes < Filter
    # Handle attributes expression `[:html, :attrs, *attrs]`
    #
    # @param [Array] attrs Array of temple expressions
    # @return [Array] Compiled temple expression
    def on_html_attrs(*attrs)
      [:multi, *attrs.map {|a| compile(a) }]
    end

    # Handle attribute expression `[:slim, :attr, escape, code]`
    #
    # @param [Boolean] escape Escape html
    # @param [String] code Ruby code
    # @return [Array] Compiled temple expression
    def on_html_attr(name, value)
      return super unless value[0] == :slim && value[1] == :attrvalue

      escape = value[3]
      code = value[4]
      case code
      when 'true'
        [:html, :attr, name, [:static, name]]
      when 'false', 'nil'
        [:multi]
      else
        tmp = unique_name
        [:html, :attr, name,
         [:multi,
          [:code, "#{tmp} = (#{code})"],
          [:case, tmp,
           ['true', [:static, name]],
           ['false, nil', [:multi]],
           [:else,
            [:escape, escape,
             [:dynamic,
              if delimiter = options[:attr_delimiter][name]
                "Array === #{tmp} ? #{tmp}.flatten.compact.join(#{delimiter.inspect}) : #{tmp}"
              else
                tmp
              end
             ]]]]]]
      end
    end

    # Handle attribute expression `[:slim, :attrvalue, escape, code]`
    #
    # @param [Boolean] escape Escape html
    # @param [String] code Ruby code
    # @return [Array] Compiled temple expression
    def on_slim_attrvalue(name, escape, code)
      tmp = unique_name
      [:multi,
       [:code, "#{tmp} = #{code}"],
       [:escape, escape,
        [:dynamic,
         if delimiter = options[:attr_delimiter][name]
           "Array === #{tmp} ? #{tmp}.flatten.compact.join(#{delimiter.inspect}) : #{tmp}"
         else
           tmp
         end
        ]]]
    end
  end
end