extends Node

class_name PingCalculator

signal done_calculation(region:Hathora.Region, ping:int)
signal lost_service_connection(code:int, reason:String)

class PingPong:
	var start:int
	var end:int
	func _init() -> void:
		start = Time.get_ticks_msec()
		end = 0
	func pong(delta:float) -> void:
		end = Time.get_ticks_msec() - (delta * 1000) / 2

const MAX_PING_PONG = 5 #should not be less than 3

var _socket:WebSocketPeer
var _host:String
var _port:int
var _region:Hathora.Region
var _ping_pong_values:Array[PingPong]
var _ping_pong_array_index:int
var _is_pinging:bool
var _is_welcome_message_received:bool


func _init(host:String, port:int, region:Hathora.Region):
	_socket = WebSocketPeer.new()
	_host = host
	_port = port
	_region = region
	_ping_pong_values.resize(MAX_PING_PONG)
	_ping_pong_array_index = 0
	_is_pinging = false
	_is_welcome_message_received = false


func _ready():
	set_process(false)


func _process(delta):
	_socket.poll()
	var state = _socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		if _is_welcome_message_received:
			ping_and_pong(delta)
		else:
			read_welcome_message()
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = _socket.get_close_code()
		var reason = _socket.get_close_reason()
		set_process(false) # Stop processing.
		if _socket.get_close_code() != 1000:
			lost_service_connection.emit(_socket.get_close_code(), _socket.get_close_reason())
		else:
			done_calculation.emit(_region, calculate_ping_average())
		queue_free()


func read_welcome_message() -> void:
	if _socket.get_available_packet_count():
		while _socket.get_available_packet_count():
			var packet:PackedByteArray = _socket.get_packet()
		_is_welcome_message_received = true
		if not OS.has_feature("web"):
			_socket.set_no_delay(true)


func start_calculate_ping_to_host() -> Error:
	var error:Error
	if OS.has_feature("web"):
		error = _socket.connect_to_url("wss://" + _host + ":" + str(_port) + "/ws", TLSOptions.client(X509Certificate.new()))
	else:
		error = _socket.connect_to_url("wss://" + _host + ":" + str(_port) + "/ws")
	if not error:
		set_process(true)
	return error


func ping_and_pong(delta:float) -> void:
	if _ping_pong_array_index < MAX_PING_PONG:
		if _is_pinging:
			if _socket.get_available_packet_count():
				_ping_pong_values[_ping_pong_array_index].pong(delta)
				_ping_pong_array_index += 1
				while _socket.get_available_packet_count():
					var packet:PackedByteArray = _socket.get_packet()
				_is_pinging = false
				if _ping_pong_array_index == MAX_PING_PONG:
					_socket.close()
		else:
			_is_pinging = true
			
			_ping_pong_values[_ping_pong_array_index] = PingPong.new()
			_socket.send_text("ping")


func calculate_ping_average() -> int:
	var pings:Array[int]
	var highest_ping_index:int = 0
	var lowest_ping_index:int = 0
	var current_index:int = 0
	for ping_pong:PingPong in _ping_pong_values:
		pings.push_back(ping_pong.end - ping_pong.start)
		if pings.back() > pings[highest_ping_index]:
			highest_ping_index = current_index
		if pings.back() < pings[lowest_ping_index]:
			lowest_ping_index = current_index
		current_index += 1
	if highest_ping_index == lowest_ping_index:
		pings.remove_at(highest_ping_index)
	else:
		pings.remove_at(max(highest_ping_index, lowest_ping_index))
		pings.remove_at(min(highest_ping_index, lowest_ping_index))
	return pings.reduce(func(accum, number): return accum + number) / pings.size()
