# This code is copyrighted by Mauricio Fernandez
# http://eigenclass.org/hiki.rb?cmd=view&p=deferred-finalizers-in-Ruby&key=_id2ref

class SimpleWeakHash
  def initialize
    @valid = false
  end

  def [](key)
    __get_hash__[key]
  end

  def []=(key, value)
    __get_hash__[key] = value
  end

  private

  def __get_hash__
    old_critical = Thread.critical
    Thread.critical = true
    set_internal_hash unless @valid
    recover_hash
  ensure
    Thread.critical = old_critical
  end

  def recover_hash
    return ObjectSpace._id2ref(@hash_id)
  rescue RangeError
    set_internal_hash
    return ObjectSpace._id2ref(@hash_id)
  end

  def set_internal_hash
    hash = {}
    @hash_id = hash.object_id
    @valid = true
    ObjectSpace.define_finalizer(hash, lambda{ |id| @valid = id != @hash_id })
    hash = nil
  end
end
