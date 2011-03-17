require 'rubygems'
require 'macaddr'
require 'json'

require 'digest/sha1'
require 'singleton'
require 'thread'

require 'k_bucket'
require 'bucket_manager'
require 'messages/message_parser'
require 'node'

class Kademlia
  include Singleton

  attr_reader :id, :options

  private
  def initialize()
    @hook_mutex = Mutex.new
    @id =  Digest::SHA1.hexdigest( Mac.addr.to_s + rand( 2**256 ).to_s )
    @options = Hash.new
    @buckets = BucketManager.i
    @hooks = Hash.new
    @options[:mac_addr] = Mac.addr.to_s

    @setup_done = false
    set()
    BucketManager.i
    @id.length.times do | i |
      BucketManager.i[i] = KBucket.new( @options[:K] )
    end
  end

  public
  def self.i()
    self.instance
  end

  def set( options = {} )
    standards = { :K => 5,
                  :port => 4223,
                  :send_format => Proc.new do | msg |
                    msg.message.to_json
                  end,
                  :parser => Proc.new do | recv |
                    MessageParser.i.parse( recv )
                  end,
                  :handler => Proc.new do | msg |
                    MessageHandler.i.handle( msg )
                  end,
                  :bootstrap_retriever => Proc.new do
                    require 'bootstrap/html_retriever'
                    require 'bootstrap/list_parser/json_list_parser'

                    JsonListParser.new( HTMLRetriever.new( "23.23.23.1" ) )
                  end
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
        when :bootstrap_retriever then register( 'bootstrap.retriever', v )
        when :K then @options[:K] = v
        when :port then @options[:port] = v
        when :send_format then register( "node.send", v )
        when :parser then register( "message.recv", v )
        when :handler then register( "message.handle", v )
      end
    end
    @setup_done = true
  end

  def register( hook, callback, priority = 100 )
    @hook_mutex.synchronize {
      if @hooks[hook] == nil
        @hooks[hook] = Array.new
      end
      is_in = false
      @hooks[hook].each do | v |
        if v[0] == priority and v[1].hash == callback.hash
          is_in = true
        end
      end
      @hooks[hook].push( [priority, callback] ) if not is_in
      @hooks[hook].sort! { | a, b | a[0] <=> b[0] }
    }
  end

  def unregister( hook, callback, priority = 100 )
    @hook_mutex.synchronize {
      if @hooks.include? hook
        if @hooks[hook].include? [priority, callback]
          @hooks[hook].delete [priority, callback]
          if @hooks[hook].length == 0
            @hooks.delete hook
          end
        end
      end
    }
  end

  def hook( hook_id, msg  )
    @hook_mutex.synchronize {
      if @hooks.key? hook_id
        @hooks[hook_id].each do | hook |
          msg = hook[1].call( msg )
        end
      end
      return msg
    }
  end

  def start_recv()
    require 'messages/datatypes/acknowledge'
    @socket = UDPSocket.new
    @recv_thread ||= Thread.new {
      @socket.bind( '127.0.0.1', @options[:port] )
      while true
        recv, from = @socket.recvfrom( 2048 )
        msg = MessageParser.i.parse( recv )
        node = BucketManager.i.get_node( msg.node_id )
        node.has_been_seen if node != nil
        if node == nil
          node = Node.new( :endpoint => from[2],
                           :port => from[1],
                           :id => msg.node_id )
          BucketManager.i.add_node( node )
        end
        msg = hook( "message", msg )
        msg = hook( "message.type." + msg.class.name, msg )
        msg = hook( "message." + msg.id, msg )
        ack_msg = Acknowledge.new( 'id' => msg.id, 'nonce' => msg.nonce )
        node.send( ack_msg )
      end
    }
    @recv_thread.abort_on_exception = true
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
