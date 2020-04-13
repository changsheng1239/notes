redis = require "resty.redis"
redis_cli = redis:new()

local ok, err = redis_cli:connect("127.0.0.1", 6379)
if not ok then
    ngx.log("failed to connect: ", err)
    ngx.exit(500)
end

local count = 1000001
repeat 
    redis_cli:set(tostring(count), tostring(count))
    count = count + 1
until count == 4000000
