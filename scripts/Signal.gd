extends Object
class_name Signal

enum Kind { UNDEFINED=-1, LOW=0, HIGH=1 }

static func from(v):
	match typeof(v):
		TYPE_INT:
			return v
		TYPE_REAL:
			return int(v)
		TYPE_BOOL:
			if v:
				return Kind.HIGH
			return Kind.LOW
		TYPE_NIL:
			return Kind.UNDEFINED
		TYPE_ARRAY:
			var r = []
			for s in v:
				r.append(from(s))
			return r
	push_error("Couldn't convert signal from %s (type=%d)"%[str(v), typeof(v)])

static func invert(sig):
	if sig == -1:
		return -1
	if sig == 0:
		return 1
	return 0

static func name(sig):
	match(sig):
		Kind.UNDEFINED:
			return "UNDEFINED"
		Kind.LOW:
			return "LOW"
		Kind.HIGH:
			return "HIGH"
	return "NO SIGNAL NAME for %s"%str(sig)

class List:
	static func repeat(sig, times):
		var ar = []
		for _i in range(times):
			ar.append(sig)
		return ar
	
	# converts a number to its binary representation with, at most, 'size' bits
	static func from_number(number, size):
		if number < 0:
			return repeat(-1, size)
		if number == 0:
			return repeat(0, size)
		var ar = []
		while number > 1:
			ar.append(number % 2)
			number /= 2
		ar.append(1)
		while ar.size() < size:
			ar.append(0)
		while ar.size() > size:
			ar.pop_back()
		return ar
	
	# requires a list with only 1s and 0s
	static func to_number(list):
		if is_any(list, -1):
			return -1
		var n = 0
		for i in range(list.size()):
			if list[i]:
				n += Utils.int_pow(2, i)
		return n
	
	static func to_twos_complement(list):
		var neg = list[list.size()-1]
		var l = list.slice(0, list.size()-2)
		var t_value = to_number(l)
		
		if neg:
			t_value -= Utils.int_pow(2, list.size()-1)
		return t_value
	
	static func from_twos_complement(number, size):
		if number < 0:
			number = abs(number)
			var list = from_number(number-1, size-1)
			list.append(0)
			for i in range(list.size()):
				if list[i] == 0:
					list[i] = 1
				else:
					list[i] = 0
			return list
		return from_number(number, size)
	
	static func negative_equivalent(number, size):
		var l = from_twos_complement(number, size)
		return to_twos_complement(l)
	
	static func is_any(list, sig):
		for s in list:
			if s == sig:
				return true
		return false

class Utils:
	static func int_pow(base, exponent):
		var r = 1
		for _i in range(exponent):
			r *= base
		return r
