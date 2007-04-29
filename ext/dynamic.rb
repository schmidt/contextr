module Dynamic
  class << self
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
      return_value = block.call
      variables.update save
      return_value
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
end
