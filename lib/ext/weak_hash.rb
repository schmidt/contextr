# This code is copyrighted by Mauricio Fernandez
# http://eigenclass.org/hiki.rb?cmd=view&p=deferred-finalizers-in-Ruby&key=_id2ref

class WeakHash
  attr_reader :cache
  def initialize( cache = Hash.new )
    @cache = cache
    @key_map = {}
    @rev_cache = Hash.new{|h,k| h[k] = {}}
    @reclaim_value = lambda do |value_id| 
      if @rev_cache.has_key? value_id
        @rev_cache[value_id].each_key{|key| @cache.delete key}
        @rev_cache.delete value_id
      end
    end
    @reclaim_key = lambda do |key_id|
      if @key_map.has_key? key_id
        @cache.delete @key_map[key_id]
      end
    end
  end

  def []( key )
    value_id = @cache[key]
    return ObjectSpace._id2ref(value_id) unless value_id.nil?
    nil
  rescue RangeError
    nil
  end

  def []=( key, value )
    case key
    when Fixnum, Symbol, true, false
      key2 = key
    else
      key2 = key.dup
    end
    @rev_cache[value.object_id][key2] = true
    @cache[key2] = value.object_id
    @key_map[key.object_id] = key2

    ObjectSpace.define_finalizer(value, @reclaim_value)
    ObjectSpace.define_finalizer(key, @reclaim_key)
  end
end
