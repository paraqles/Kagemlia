require 'rubygems'
require 'macaddr'
require 'json'

require 'digest/sha1'
require 'singleton'
require 'thread'
require 'monitor'

require 'bucket_manager'
require 'k_bucket'
require 'node'
require 'messages/json_message_parser'
require 'modules/prefix_distance_extension'

class Kademlia
    attr_reader :id

  def initialize( params = {} )
    String.send( 'include', PrefixDistanceExtension )
    @id =  Digest::SHA1.hexdigest( Mac.addr.to_s + rand( 2**256 ).to_s )

    @options = Hash.new
    @options.extend( MonitorMixin )
    @buckets = BucketManager.new( :id => @id )
    @hooks = Hash.new
    @hooks.extend( MonitorMixin )

    @messages = Array.new
    @messages.extend( MonitorMixin )

    @socket = UDPSocket.new
    @socket.extend( MonitorMixin )

    @options[:mac_addr] = Mac.addr.to_s

    @setup_done = false
    @start = true 
    standards( params )
    start_recv() if not params.include? :manuel_start
    start_resend() if not params.include? :manuel_start
  end

  private
  def standards( params )
    @stdops = Hash.new 
    @stdops[:K]                     ||= 5
    @stdops[:port]                  ||= 4223

    # Standard hooks for handling messages
    @stdops[:message_send]          ||= {
      :priority => 1000,
      :callback => Proc.new do | msg |
        msg.message.to_json
      end,
      :one_time_hook => false
    }
    @stdops[:message_parse]         ||= {
      :priority => 10,
      :callback => Proc.new do | recv |
        JsonMessageParser.parse( recv )
      end,
      :one_time_hook => false
    }

    # hooks for handling message types
    @mesg_handler = MessageHandler.new( self, @buckets, @store )
    @stdops[:message_message]       ||= {
      :callback => Proc.new do | msg |
        @mesg_handler.handle( msg )
      end,
      :one_time_hook => false
    }
    @ack_handler = AcknowledgeHandler.new( self, @buckets, @store )
    @stdops[:message_acknowledge]   ||= {
      :callback => Proc.new do | msg |
        @ack_handler.handle( msg )
      end,
      :one_time_hook => false
    }
    @fn_handler = FindNodeHandler.new( self, @buckets, @store )
    @stdops[:message_find_node]     ||= {
      :callback => Proc.new do | msg |
        @fn_handler.handle( msg )
      end,
      :one_time_hook => false
    }
    @gd_handler = GetDataHandler.new( self, @buckets, @store )
    @stdops[:message_get_data]      ||= {
      :callback => Proc.new do | msg |
        @gd_handler.handle( msg )
      end,
      :one_time_hook => false
    }
    @ping_handler = PingHandler.new( self, @buckets, @store )
    @stdops[:message_ping]          ||= {
      :callback => Proc.new do | msg |
        @ping_handler.handle( msg )
      end,
      :one_time_hook => false
    }
    @pong_handler = PongHandler.new( self, @buckets, @store )
    @stdops[:message_pong]          ||= {
      :callback => Proc.new do | msg |
        @pong_handler.handle( msg )
      end,
      :one_time_hook => false
    }
    @rd_handler = ReturnDataHandler.new( self, @buckets, @store )
    @stdops[:message_return_data]   ||= {
      :callback => Proc.new do | msg |
        @rd_handler.handle( msg )
      end,
      :one_time_hook => false
    }
    @rn_handler = ReturnNodeHandler.new( self, @buckets, @store )
    @stdops[:message_return_node]   ||= {
      :callback => Proc.new do | msg |
        @rn_handler.handle( msg )
      end,
      :one_time_hook => false
    }
    @store_handler = StoreHandler.new( self, @buckets, @store )
    @stdops[:message_store]         ||= {
      :callback => Proc.new do | msg |
        @store_handler.handle( msg )
      end,
      :one_time_hook => false
    }

    # Bootstrap hook for getting initial nodes
    @stdops[:bootstrap]             ||= {
      :callback => Proc.new do
        require 'bootstrap/node_list_retriever/html_retriever'
        require 'bootstrap/node_list_parser/json_list_parser'
        retrv = HTMLRetriever.get_list_from( "23.23.23.1" )
        JsonListParser.parse( retrv, self, @buckets )
      end,
      :one_time_hook => false
    }

    if not @setup_done
      @stdops.each do | k, v |
        if not params.include? k
          params[k] = v
        end
      end
    end
    set( params )
    @setup_done = true
  end

  public
  def set( options = {} )
    options.each do | k, v |
      case k
        when :K then
          @options_mutex.synchronize{ @options[:K] = v }
        when :port then
          @options_mutex.synchronize{ 
            @options[:port] = v
          }
        else
          register( k.to_s, v )
      end
    end
  end

  def register( hook_id, hook )
    @hook_standard ||= {  :priority => 100,
                          :one_time_hook => true }
    @hook_standard.each do | k, v |
      hook[k] = v if not hook.include? k
    end
    begin
      @hook_mutex.lock
    rescue ThreadError
    end
    if @hooks[hook_id] == nil
      @hooks[hook_id] = Array.new
    end
    if not @hooks[hook_id].include? hook
      @hooks[hook_id].push( hook )
      @hooks[hook_id].sort! { | a, b | a[:priority] <=> b[:priority] }
    end
    @hook_mutex.unlock if @hook_mutex.locked?
  end

  def unregister( hook_id, hook )
    @hook_standard.each do | k, v |
      if not hook.include? k
        hook[k] = v
      end
    end
    begin
      @hook_mutex.lock
    rescue ThreadError
    end
    if @hooks.include? hook
      if @hooks[hook_id].include? hook
        @hooks[hook_id].delete hook
        if @hooks[hook].length == 0
          @hooks.delete hook
        end
      end
    end
    @hook_mutex.unlock if @hook_mutex.locked?
  end

  def hook( hook_id, msg  )
    begin
      @hook_mutex.lock
    rescue ThreadError
    end
    if @hooks.key? hook_id
      @hooks[hook_id].each do | hook |
        msg = hook[:callback].call( msg )
        if hook[:one_time_hook]
          unregister( hook_id, hook )
        end
      end
    end
    return msg
    @hook_mutex.unlock if @hook_mutex.locked?
  end

  def start_recv()
    if @start
      require 'messages/datatypes/acknowledge'
      @socket.synchronize {
        @socket.bind( '127.0.0.1', @options[:port] )
      }
      @recv_thread ||= Thread.new {
        while true
          recv = ""
          from = nil
          r = select( [@socket], nil, nil )
          if r != nil
            @socket.synchronize {
              recv, from = @socket.recvfrom( 2048 )
            }
            msg = hook( :message_parse, recv )

            node = @buckets.get_node( msg.node_id )
            node.has_been_seen if node != nil
            if node == nil
              node = Node.new(  :endpoint => from[2],
                                :port => from[1],
                                :id => msg.node_id,
                                :kademlia => self
              )
              @buckets.add_node( node )
            end
            msg = hook( :message, msg )
            msg = hook( :message_message, msg )
            tyep = msg.class.name
            type = msg['msgType'].gsub( /^[A-Z]/) { $&.downcase  }
            type.gsub!( /[A-Z]/ ) { | m | m = '_' + m.downcase }
            msg = hook( ("message_" + type).to_sym , msg )
            msg = hook( "message.id=" + msg.id.to_s, msg )
          end
        end
      }
      @recv_thread.abort_on_exception = true
    end
  end

  def stop_recv()
    if @recv_thread != nil
      @recv_thread.exit
    end
  end

  def start_resend()
    @thread_resend = Thread.new {
      while true
        sleep( 
  end
  def send( buf, flags, adress, port )
    @socket.synchronize {
      @socket.send( buf, flags, adress, port )
    }
  end

  def []( key )
    key = Digest::SHA1.hexdigest( key )
    if @storage.include? key
      @storage[key]
    else
      sync_req_thread = Thread.new( key ) { | key |
        msg = FindNode.new( :key => key )
        @buckets.get_nodes_for( key ).each do | node |
          
    end
  end

  def []=( key, value )
    
  end

  def new_id()
    Digest::SHA1.hexdigest( @options[:mac_addr] + rand( 2**256 ).to_s )
  end
end
