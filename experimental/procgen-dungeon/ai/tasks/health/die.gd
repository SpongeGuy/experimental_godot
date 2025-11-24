extends BTAction

func _tick(_delta: float) -> Status:
	agent.queue_free()
	return SUCCESS
