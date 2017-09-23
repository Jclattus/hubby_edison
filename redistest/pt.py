import time
i = 0
print('START!')

while i >= 0:
        f = open('timelog.txt','a')
        nowstr = time.strftime('%Y-%m-%d %H:%M:%S')
        print(nowstr)
        f.write(nowstr)
        f.write('\n')
        f.close()
        time.sleep(1)
        i = i + 1

print('DONE!');