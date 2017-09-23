import redis
r = redis.Redis(host='localhost', port=6379, db=0)
r.set('foo', 'bar')
print(r.get('foo'))
x = 1
while True:
	print "This won't appear on file"   
    x += 1
