require 'Thread'

class StoreManager
  def initialize( params )
    @values_mutex = Mutex.new
    @timestamps_mutex = Mutex.new

    @values = Hash.new
    @timestamps = Hash.new
    
    @max_state_time = params[:time_to_keep] if params.include? :time_to_keep
    @max_state_time = 180 if not params.include? :time_to_keep

    @thread_clean_up ||= Thread.new {
      while true
        sleep( @max_state_time + 10 )
        lock_mutexs()
          if @values.length > 0
            t = Time.new
            t -= @max_state_time
            @timestamps.each do | k, v |
              @values.delete v if k < t
              @timestamps.delete k if k < t
            end
          end
        unlock_mutexs()
      end
    }
    @thread_hold_state ||= Thread.new {
      while true
        sleep( @max_state_time - 10 )
        TODO: Hold the soft state
      end
    }
  end

  def lock_mutexs
    begin
      @values_mutex.lock
      @timestamps_mutex.lock
    rescue ThreadError
    end
  end

  def unlock_mutexs
    @values_mutex.unlock if @values_mutex.locked?
    @timestamps_mutex.unlock if @timestamps_mutex.locked?
  end
  
  def add( params )
    lock_mutexs()
      @values[params[:key]] = params[:value]
      @timestamps[Time.new] = params[:key]
    unlock_mutexs()
  end

  def get( key )
    lock_mutexs()
      value = @values[key]
    unlock_mutexs
    return value
  end

  def delete( key )
    lock_mutexs()
      @values.delete key if @values.include? key
      @timestamps.delete( @timestamps.key key ) if timestamps.value? key
    unlock_mutexs()
  end

  def update_time( key )
    lock_mutexs
      if @timestamps.value? key
        @timestamps.delete( @timestamps.key key )
        @timestamps[Time.new] = key
      end
    unlock_mutexs()
  end

  def []( key )
    lock_mutexs
      value = ( @value.include? key )? @values[key] : nil
    unlock_mutexs
    return value
  end

  def []=( key, value )
    lock_mutexs()
      @values[key] = value
      if @timestamps.value? key
        @timestamps.delete( @timestamps.key key )
      end
      @timestamps[Time.new] = key
    unlock_mutexs()
  end
end
