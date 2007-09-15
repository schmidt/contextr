module ContextR
  class EventMachine # :nodoc: all
    module ClassMethods
      include UniqueId 

      def listeners 
        @listeners ||= { :method_added => {} }
      end

      def register(listener, callback, options)
        observed = check_options_hash(options)
        register_observers_on_demand(observed)
        self.listeners[observed[:event]][observed[:module]][listener] = callback
      end

      def unregister(listener, *cumulated_options)
        observed = check_options_hash(cumulated_options.last)
        self.listeners[observed[:event]][observed[:module]].delete(listener)
      end

      def on_method_added(modul, name)
        version = self.new_unique_id
        self.listeners[:method_added][modul].each do | listener, method_name |
          listener.send( method_name, modul, name, version )
        end 
      end

      def check_options_hash(options)
        observed = {}
        observed[:event] = options[:on_event]
        observed[:module] = options[:in_class] || options[:in_module]
        [:event, :module].each do |key|
          unless observed[key]
            raise ArgumentError.new("Missing Argument in options Hash")
          end
        end
        unless self.listeners.keys.include?(observed[:event])
          raise ArgumentError.new("Unknown event `#{observed[:event]}`. " + 
                  "Please use one of these: #{self.listeners.keys.join(', ')}")
        end
        observed
      end

      def register_observers_on_demand(observed)
        unless self.listeners[observed[:event]].include?(observed[:module])
          self.listeners[observed[:event]][observed[:module]] = {}
          case observed[:event]
          when :method_added
            observe_method_added(observed[:module])
          end
        end
      end

      def observe_method_added(modul)
        modul.class_eval(%Q{
          def self.method_added_with_contextr_listener(name)
            ContextR::EventMachine::on_method_added(self, name)
            method_added_without_contextr_listener(name)
          end
          unless self.methods.include? "method_added"
            def self.method_added(name); end
          end
          class << self
            alias_method_chain(:method_added, :contextr_listener)
          end
        }, __FILE__, __LINE__)
      end
    end
    self.extend(ClassMethods)
  end
end
