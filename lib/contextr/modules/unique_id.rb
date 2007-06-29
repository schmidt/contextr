module UniqueId
  def new_unique_id
    $id_semaphore ||= Mutex.new
    $id_semaphore.synchronize do
      $gen_unique_id ||= 0
      $gen_unique_id += 1
    end
  end

  def last_unique_id
    $gen_unique_id ||= 0
  end
end
