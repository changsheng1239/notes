json = require "cjson"
redis = require "resty.redis"
redis_cli = redis:new()

local ok, err = redis_cli:connect("127.0.0.1", 6379)
if not ok then
    ngx.log("failed to connect: ", err)
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

local cursor = "0"
local time_start = os.clock()
local keys = {}
repeat
    local data, err = redis_cli:scan(cursor, "match", ngx.unescape_uri(ngx.var.pattern), "count", "10000")
    if not data then
        ngx.say(err)
        break
    end
    cursor = data[1]
    if #data[2] ~= 0 then
        for i,v in ipairs(data[2]) do
            table.insert(keys, v)
        end
    end
until cursor == "0"
--ngx.say(os.clock() - time_start)
redis_cli:set_keepalive(600000, 100)
ngx.say(json.encode(keys))
ngx.exit(200)
