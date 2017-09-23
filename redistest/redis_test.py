import redis
r = redis.Redis(host='localhost', port=6379, db=0)


for x in xrange(1, 11):
	r.rpush("list",x);
   