require "thread"
module MutexCode #:nodoc:
  def semaphore
    @semaphore ||= Mutex.new
  end

  def synchronized
    semaphore.synchronize do
      yield
    end
  end

  def is_blocked?
    semaphore.locked?
  end

  def only_once
    synchronized do
      yield
    end unless is_blocked?
  end
end
