require 'rubygems'
require 'macaddr'
require 'json'

require 'digest/sha1'
require 'singleton'
require 'thread'

require 'bucket_manager'
require 'k_bucket'
require 'node'
require 'messages/json_message_parser'
require 'modules/prefix_distance_extension'

class Kademlia
  attr_reader :id, :options, :socket, :socket_mutex

  def initialize( params = {} )
    String.send( 'include', PrefixDistanceExtension )
    @hook_mutex = Mutex.new
    @msg_queue_mutex = Mutex.new
    @options_mutex = Mutex.new
    @socket_mutex = Mutex.new
    
    @id =  Digest::SHA1.hexdigest( Mac.addr.to_s + rand( 2**256 ).to_s )
    
    @options = Hash.new
    @buckets = BucketManager.new( :id => @id )
    @hooks = Hash.new
    
    @socket = UDPSocket.new
    @options[:mac_addr] = Mac.addr.to_s
    
    @setup_done = false
    #@start = false if params.include? :manuel_start
    @start = true if not params.include? :manuel_start
    set( params )
    start_recv()
  end

  def set( options = {} )
    standards = { :K => 5,
                  :port => 4223,
                  :send_format => {
                    :priority => 1000,
                    :callback => Proc.new do | msg |
                        msg.message.to_json
                      end,
                    :one_time_hook => false
                  },
                  :parser => {
                    :priority => 10,
                    :callback => Proc.new do | recv |
                        JsonMessageParser.parse( recv )
                      end,
                    :one_time_hook => false
                  },
                  :handler => {
                    :callback => Proc.new do | msg |
                        MessageHandler.i.handle( msg )
                      end,
                    :one_time_hook => false
                  },
                  :bootstrap_retriever => {
                    :callback => Proc.new do
                        require 'bootstrap/html_retriever'
                        require 'bootstrap/list_parser/json_list_parser'
                        retrv = HTMLRetriever.get_list_from( "23.23.23.1" )
                        JsonListParser.parse( retrv, self, @buckets )
                      end,
                    :one_time_hook => false
                  }
                }
    if not @setup_done
      standards.each do | k, v |
        if not options.include? k
          options[k] = v
        end
      end
    end
    options.each do | k, v |
      case k
        when :K then
          @options_mutex.synchronize{ @options[:K] = v }
        when :port then
          @options_mutex.synchronize{ 
            @options[:port] = v
          }
        else
          reqister(
      end
    end
    @setup_done = true
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
      begin
        @socket_mutex.lock
      rescue ThreadError
      end
        @socket.bind( '127.0.0.1', @options[:port] )
      @socket_mutex.unlock if @socket_mutex.locked?
      @recv_thread ||= Thread.new {
        while true
          recv = ""
          from = nil
          r = select( [@socket], nil, nil )
          if r != nil
            begin
              @socket_mutex.lock
            rescue ThreadError
            end
              recv, from = @socket.recvfrom( 2048 )
            @socket_mutex.unlock if @socket_mutex.locked?
            msg = hook( "message.recv", recv )
            node = @buckets.get_node( msg.node_id )
            node.has_been_seen if node != nil
            if node == nil
              node = Node.new(  :endpoint => from[2],
                                :port => from[1],
                                :id => msg.node_id,
                                :kademlia => self,
                                :socket => @socket )
              @buckets.add_node( node )
            end
            msg = hook( "message", msg )
            msg = hook( "message.type." + msg.class.name, msg )
            msg = hook( "message." + msg.id, msg )
            ack_msg = Acknowledge.new(  'node_id' => @id,
                                        'id' => msg.id,
                                        'nonce' => msg.nonce
                                     )
            begin
              @socket_mutex.lock
            rescue ThreadError
            end
              node.send( ack_msg )
            @socket_mutex.unlock if @socket_mutex.locked?
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

  def []( key )
    if @storage.include? key
      @storage[key]
    else
      bucket = @buckets[ id.bin_dist_to key ]
    end
  end

  def []=( key, value )
    
  end

  def new_id()
    Digest::SHA1.hexdigest( @options[:mac_addr] + rand( 2**256 ).to_s )
  end
end
