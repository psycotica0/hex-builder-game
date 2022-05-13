extends Reference

# What kind of resource do I represent
var resource = 1

# Who has this need
var source

var start_time
var base_priority
var time_priority

func _init():
	start_time = OS.get_ticks_msec()

func priority():
	var elapsed = OS.get_ticks_msec() - start_time
	
	return base_priority + time_priority * elapsed

func matches(other):
	return resource == other.resource

func position():
	return source.position()

func complete():
	source.complete(self)
