unless Object.const_defined? "ActiveSupport"
  # The Inflector transforms words from singular to plural, class names to 
  # table names, modularized class names to ones without, and class names to 
  # foreign keys. The default inflections for pluralization, singularization, 
  # and uncountable words are kept in inflections.rb.
  module Inflector #:nodoc:
    extend self
    
    # By default, camelize converts strings to UpperCamelCase. If the argument 
    # to camelize is set to ":lower" then camelize produces lowerCamelCase.
    #
    # camelize will also convert '/' to '::' which is useful for converting 
    # paths to namespaces
    #
    # Examples
    #   "active_record".camelize #=> "ActiveRecord"
    #   "active_record".camelize(:lower) #=> "activeRecord"
    #   "active_record/errors".camelize #=> "ActiveRecord::Errors"
    #   "active_record/errors".camelize(:lower) #=> "activeRecord::Errors"
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

    # The reverse of +camelize+. Makes an underscored form from the expression 
    # in the string.
    #
    # Changes '::' to '/' to convert namespaces to paths.
    #
    # Examples
    #   "ActiveRecord".underscore #=> "active_record"
    #   "ActiveRecord::Errors".underscore #=> active_record/errors
    def underscore(camel_cased_word)
      camel_cased_word.to_s.gsub(/::/, '/').
                            gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
                            gsub(/([a-z\d])([A-Z])/,'\1_\2').
                            tr("-", "_").
                            downcase
    end

    # Constantize tries to find a declared constant with the name specified
    # in the string. It raises a NameError when the name is not in CamelCase
    # or is not initialized.
    #
    # Examples
    #   "Module".constantize #=> Module
    #   "Class".constantize #=> Class
    def constantize(camel_cased_word)
      unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ camel_cased_word
        raise NameError, 
              "#{camel_cased_word.inspect} is not a valid constant name!"
      end

      Object.module_eval("::#{$1}", __FILE__, __LINE__)
    end
  end

  module ActiveSupport #:nodoc:
    module CoreExtensions #:nodoc:
      module String #:nodoc:
        # String inflections define new methods on the String class to 
        # transform names for different purposes. For instance, you can figure 
        # out the name of a database from the name of a class.
        #   "ScaleScore".tableize => "scale_scores"
        module Inflections
          # By default, camelize converts strings to UpperCamelCase. If the 
          # argument to camelize is set to ":lower" then camelize produces 
          # lowerCamelCase.
          #
          # camelize will also convert '/' to '::' which is useful for 
          # converting paths to namespaces 
          #
          # Examples
          #   "active_record".camelize #=> "ActiveRecord"
          #   "active_record".camelize(:lower) #=> "activeRecord"
          #   "active_record/errors".camelize #=> "ActiveRecord::Errors"
          #   "active_record/errors".camelize(:lower) #=> "activeRecord::Errors"
          def camelize(first_letter = :upper)
            case first_letter
            when :upper then Inflector.camelize(self, true)
            when :lower then Inflector.camelize(self, false)
            end
          end
          alias_method :camelcase, :camelize

          # The reverse of +camelize+. Makes an underscored form from the 
          # expression in the string.
          # 
          # Changes '::' to '/' to convert namespaces to paths.
          #
          # Examples
          #   "ActiveRecord".underscore #=> "active_record"
          #   "ActiveRecord::Errors".underscore #=> active_record/errors
          def underscore 
            Inflector.underscore(self)
          end

          # Create a class name from a table name like Rails does for table 
          # names to models. Note that this returns a string and not a Class. 
          # (To convert to an actual class follow classify with constantize.)
          #
          # Examples
          #   "egg_and_hams".classify #=> "EggAndHam"
          #   "post".classify #=> "Post"
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
