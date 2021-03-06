const http = require('http')  
const port = 3000
var fs = require('fs');
const requestHandler = (request, response) => {  
  console.log(request.url)
  
  fromFile(function(data){
	  console.log(data);
	  response.end(data)
  })
}

const server = http.createServer(requestHandler)

var mustDel =true;

function fromFile(cb){
	if(mustDel){
		var filePath = '/home/root/Intel-Edison-BLE-Sensor-Device-master/test.txt'; 
	}
	else{
		var filePath = '/home/root/Intel-Edison-BLE-Sensor-Device-master/test2.txt';
	}
		fs.readFile(filePath, function(err, data) { // read file to memory
		if (!err) {
			data = data.toString(); // stringify buffer
			
				if(data){
					if(mustDel){
						fs.writeFile(filePath, '', function(err) { 
							sent=[];// write file
							if (err) { // if error, report
								console.log (err);
							}
						})
					}
					cb(data);
				}
					
		
		   
		   
		} else {
			cb(err);
		}
	});
	
}



server.listen(port,'0.0.0.0', (err) => {  
  if (err) {
    return console.log('something bad happened', err)
  }

  console.log(`server is listening on ${port}`)
})
