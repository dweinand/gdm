require "socket"
require "ipaddr"

# A simplified interface for sending and receiving multicast UDP messages
class MulticastSocket
  # Default mutlicast ip address
  MULTICAST_ADDRESS = "224.0.0.1"
  
  # Default ip address of local network interface
  LOCAL_ADDRESS = "0.0.0.0"
  
  # Access to underlying socket used for testing
  # 
  # @!visibility private
  attr_writer :socket 
  
  # @!attribute [r] address
  # @return [Integer] The multicast ip address being used
  attr_reader :address
  
  # @!attribute [r] port
  # @return [Integer] The multicast port being used
  attr_reader :port
  
  # Initialize a MulticastSocket.
  # 
  # @param port [Integer]
  # @param address [String]
  # 
  def initialize(port, address=MULTICAST_ADDRESS)
    @address = address
    @port = port
  end
  
  # Send a multicast message.
  # 
  # @example
  #   multicast_socket.send("M-SEARCH * HTTP/1.1\r\n") # => 21
  # 
  # @param message [String] The message to broadcast.
  # 
  # @return [Integer] Number of bytes sent.
  def send(message)
    socket.send(message, 0, address, port)
  end
    
  # Receive multicast messages. Messages are received on a separate
  # thread. When no block is given, all responses will be returned after 
  # timeout. When a block is given, each response is yielded as it arrives.
  # 
  # @example No block
  #   multicast_socket.receive
  #   # => [["msg", ["AF_INET", 33302, "localhost.localdomain", "127.0.0.1"]]]
  # 
  # @example With a block
  #   multicast_socket.receive do |message, inet_addr|
  #     puts message       # => "msg"
  #     puts inet_addr[-1] # => "127.0.0.1"
  #   end 
  # 
  # @param maxlen [Integer] The maximum number of bytes to read from the socket.
  # @param timeout [Fixnum] The number of seconds receive data for.
  # 
  # @return [Array<(String, Array)>] If no block is given an array of all
  #   responses
  # @return [nil] If block is given
  # 
  # @yield [message, inet_addr] Response message and sender information
  def receive(maxlen=65536, timeout=1)
    socket.bind(LOCAL_ADDRESS, port)
    if block_given?
      listen(timeout) { yield socket.recvfrom(maxlen) }
    else
      responses = []
      listen(timeout) { responses << socket.recvfrom(maxlen) }
      responses
    end   
  end
  
  # Underlying UDPSocket. Only public for testing.
  # 
  # @!visibility private
  def socket
    @socket ||= UDPSocket.new.tap do |socket|
      socket.setsockopt Socket::IPPROTO_IP,
                        Socket::IP_ADD_MEMBERSHIP,
                        multicast_group
      socket.setsockopt Socket::IPPROTO_IP,
                        Socket::IP_MULTICAST_TTL,
                        1
      socket.setsockopt Socket::SOL_SOCKET,
                        Socket::SO_REUSEPORT,
                        1  
    end
  end

  # Byte-ordered string representing the multicast ip address group the socket
  # will join.
  # 
  # @!visibility private
  def multicast_group
    IPAddr.new(address).hton + IPAddr.new(LOCAL_ADDRESS).hton
  end
    
  private
  
  def listen(timeout, &blk)
    listener = Thread.new { loop(&blk) }
    sleep timeout
  ensure
    listener.kill
  end
  
end