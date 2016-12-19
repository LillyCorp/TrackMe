import httplib2
resp, content = httplib2.Http().request("http://10.10.2.150:80/location")
print(content)