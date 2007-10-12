module ContextR
  class InnerClass
    self.instance_methods.each do |method_name|
      unless method_name =~ /^__.*__$/ or %w{inspect send}
        undef_method(method_name)
      end
    end

    def method_missing(method_name, *rest_args)
      self.outer.send(method_name, *rest_args)
    end
  end

  def self.InnerClass(receiver)
    c = Class.new(InnerClass)
    c.module_eval do
      define_method :outer do
        receiver
      end
    end
    c
  end
end
