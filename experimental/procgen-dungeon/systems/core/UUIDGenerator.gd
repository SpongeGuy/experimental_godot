class_name UUIDGenerator extends Node

static func v4() -> String:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var bytes: Array[int] = []
	for i in range(16):
		bytes.append(rng.randi_range(0, 255))
	
	# Set version 4 (random)
	bytes[6] = (bytes[6] & 0x0F) | 0x40
	# Set variant (RFC 4122)
	bytes[8] = (bytes[8] & 0x3F) | 0x80
	
	var hex: String = ""
	for i in range(16):
		hex += "%02x" % bytes[i]
		if i == 3 or i == 5 or i == 7 or i == 9:
			hex += "-"
	
	return hex
