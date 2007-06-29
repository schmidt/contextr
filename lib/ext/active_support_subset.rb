unless Object.const_defined? "ActiveSupport"
  class Module
    def alias_method_chain(target, feature)
      # Strip out punctuation on predicates or bang methods since
      # e.g. target?_without_feature is not a valid method name.
      aliased_target, punctuation = target.to_s.sub(/([?!=])$/, ''), $1
      yield(aliased_target, punctuation) if block_given?
     
      with_method = "#{aliased_target}_with_#{feature}#{punctuation}"
      without_method = "#{aliased_target}_without_#{feature}#{punctuation}"
     
      alias_method without_method, target
      alias_method target, with_method
     
      case
        when public_method_defined?(without_method)
          public target
        when protected_method_defined?(without_method)
          protected target
        when private_method_defined?(without_method)
          private target
      end
    end
  end

  module Inflector
    extend self
    
    def camelize(lower_case_and_underscored_word, 
                 first_letter_in_uppercase = true)
      if first_letter_in_uppercase
        lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { 
                            "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
      else
        lower_case_and_underscored_word.first + 
                              camelize(lower_case_and_underscored_word)[1..-1]
      end
    end

    def underscore(camel_cased_word)
      camel_cased_word.to_s.gsub(/::/, '/').
                            gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
                            gsub(/([a-z\d])([A-Z])/,'\1_\2').
                            tr("-", "_").
                            downcase
    end

    def constantize(camel_cased_word)
      unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ camel_cased_word
        raise NameError, 
              "#{camel_cased_word.inspect} is not a valid constant name!"
      end

      Object.module_eval("::#{$1}", __FILE__, __LINE__)
    end
  end

  module ActiveSupport
    module CoreExtensions
      module String
        module Inflections
          def camelize(first_letter = :upper)
            case first_letter
            when :upper then Inflector.camelize(self, true)
            when :lower then Inflector.camelize(self, false)
            end
          end
          alias_method :camelcase, :camelize

          def underscore 
            Inflector.underscore(self)
          end

          def constantize
            Inflector.constantize(self)
          end
        end
      end
    end
  end

  class String
    include ActiveSupport::CoreExtensions::String::Inflections
  end
end
