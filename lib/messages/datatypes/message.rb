require 'rubygems'
require 'json'

require 'digest/sha1'

require 'kademlia'

class Message
  attr_reader :nonce, :node_id, :id

  def initialize( params )
    if not params.include? 'nonce'
      @nonce = rand()
    elsif
      @nonce = params['nonce']
    end

    if not params.include? 'node_id' and not params.include? :node_id
      raise ArgumentError, 'No local node_id provided'
    else
      @node_id = params['node_id'] if params.include? 'node_id'
      @node_id = params[:node_id] if params.include? :node_id
    end

    if not params.include? 'id'
      @id = Digest::SHA1.hexdigest( rand( 2 ** 128 ).to_s + Time.new.inspect.to_s )
    else
      @id = params['id']
    end
  end

  def message( params = {} )
    finalize_message( params )
  end

  def finalize_message( params = {} )
    params['msgType'] = self.class.name
    params['nonce'] = @nonce
    params['node_id'] = @node_id
    params['id'] = @id
    return params
  end

  def to_s
    "##{self.class.name}:(#{self.object_id}) -- { 'msgType' => '#{self.class.name}', 'nonce' => #{@nonce}, 'node_id' => '#{@node_id}', 'id' => '#{@id}' }"
  end

  def clone()
    msg = messsage
    msg.delete 'nonce'
    self.class.new( msg )
  end
end
