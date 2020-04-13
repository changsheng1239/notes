local cjson = require'cjson'
local redis = require "resty.redis"
local redis_key = ngx.unescape_uri(string.upper(ngx.var.key))
local stripped_key = string.gsub(redis_key, '[%(%)%.%,]', '')

-- connect to redis server
local redis_cli = redis:new()
local ok, err = redis_cli:connect("127.0.0.1", 6379)
if not ok then
    ngx.log(ngx.ERR, "failed to connect: ", err)
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

-- read redis using input key
local res, err = redis_cli:get(redis_key)
if (not res) or (res == ngx.null) then
    -- read redis using stripped key: ABC (SDN), BHD. -> ABC SDN BHD
    res, err = redis_cli:get(stripped_key)
    if (not res) or (res == ngx.null) then 
        ngx.log(ngx.ERR, "No entity record found inside redis")
        return ngx.exit(ngx.HTTP_NOT_FOUND)
    end
end

result = cjson.decode('[' .. res .. ']')

--ngx.say('[' .. res .. ']')
ngx.say('{"entityList": [' .. res .. '], "pagination":{}, "entityCount": ' .. #result .. ', "success": true}')
return ngx.exit(ngx.HTTP_OK)
