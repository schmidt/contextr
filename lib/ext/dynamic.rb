# This library was created by Christian Neukirchen in the context of
# EuRuKo 2005 and is licensed under the same terms as Ruby.
#
# It provides dynamically scoped variables. It is used within ContextR to
# store the current, thread-wide activated layers.
#
# For more information see the corresponding slides at
# http://chneukirchen.org/talks/euruko-2005/chneukirchen-euruko2005-contextr.pdf
#
# (c) 2005 - Christian Neukirchen - http://chneukirchen.org
module Dynamic
  module ClassMethods #:nodoc:
    Thread.main[:DYNAMIC] = Hash.new { |hash, key|
      raise NameError, "no such dynamic variable: #{key}"
    }

    def here!
      Thread.current[:DYNAMIC] = Hash.new { |hash, key|
        raise NameError, "no such dynamic variable: #{key}"
      }.update Thread.main[:DYNAMIC]
    end

    def variables
      Thread.current[:DYNAMIC] or here!
    end

    def variable(definition)
      case definition
      when Symbol
        if variables.has_key? definition
          raise NameError, "dynamic variable `#{definition}' already exists"
        end
        variables[definition] = nil
      when Hash
        definition.each { |key, value|
          if variables.has_key? key
            raise NameError, "dynamic variable `#{key}' already exists"
          end
          variables[key] = value
        }
      else
        raise ArgumentError,
        "can't create a new dynamic variable from #{definition.class}"
      end
    end

    def [](key)
      variables[key]
    end

    def []=(key, value)
      variables[key] = value
    end

    def undefine(*keys)
      keys.each { |key|
        self[key]
        variables.delete key
      }
    end

    def let(bindings, &block)
      save = {}
      bindings.to_hash.collect { |key, value|
        save[key] = self[key]
        self[key] = value
      }
      block.call
    ensure
      variables.update save
    end

    def method_missing(name, *args)
      if match = /=\Z/.match(name.to_s)    # setter?
        raise ArgumentError, "invalid setter call"  unless args.size == 1
        self[match.pre_match.intern] = args.first
      else
        raise ArgumentError, "invalid getter call"  unless args.empty?
        self[name]
      end
    end
  end
  extend ClassMethods
end
