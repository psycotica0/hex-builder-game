extends Reference

var requests = []
var requests_sorted = false
var recursive_break = false
var cached_benefit

func add_request(request):
	# This list is unsorted while I collect them
	# This is because their values may change based on the market
	# So, we don't want to compute the value until everything's in
	requests.append(request)

func request_sort(a, b):
	return a.benefit() > b.benefit()

func requests():
	if not requests_sorted:
		requests.sort_custom(self, "request_sort")
		requests_sorted = true
	
	return requests

func benefit():
	if cached_benefit:
		return cached_benefit
	
	assert(not recursive_break)
	
	recursive_break = true
	cached_benefit = requests()[0].benefit()
	recursive_break = false
	
	return cached_benefit
