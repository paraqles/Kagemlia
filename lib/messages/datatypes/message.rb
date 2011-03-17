require 'json'

require 'kademlia'

class Message
  attr_reader :nonce, :node_id, :id

  def initialize( msg = {} )
    if not msg.include? 'nonce'
      @nonce = rand()
    else
      @nonce = msg['nonce']
    end

    if not msg.include? 'node_id'
      @node_id = Kademlia.i.id
    else
      @node_id = msg['node_id']
    end

    if not msg.include? 'id'
      @id = Kademlia.i.new_id
    else
      @id = msg['id']
    end
  end

  def message( msg = {} )
    finalize_message( msg )
  end

  def finalize_message( msg = {} )
    msg['msgType'] = self.class.name
    msg['nonce'] = @nonce
    msg['node_id'] = @node_id
    msg['id'] = @id
    return msg
  end

  def to_s
    "##{self.class.name}:(#{self.object_id}) -- { 'msgType' => '#{self.class.name}', 'nonce' => #{@nonce}, 'node_id' => '#{@node_id}', 'id' => '#{@id}' }"
  end
end
