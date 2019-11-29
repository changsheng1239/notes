local cjson = require "cjson"
local redis = require "resty.redis"
local redis_cli = redis:new()
local redis_key = ngx.unescape_uri(ngx.var.key)
local stripped_key = string.gsub(redis_key, '[%(%)%.%,]', '')

-- connect to redis server
local ok, err = redis_cli:connect("127.0.0.1", 6379)
if not ok then
    ngx.log("failed to connect: ", err)
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

function main()
    -- read redis using input key
    local res, err = redis_cli:get(redis_key)
    if (not res) or (res == ngx.null) then
        -- read redis using stripped key: ABC (SDN), BHD. -> ABC SDN BHD
        res, err = redis_cli:get(stripped_key)
        if (not res) or (res == ngx.null) then 
            return ngx.exit(ngx.HTTP_NOT_FOUND)
        end
    end
    ngx.say("[" .. res .. "]")

    return ngx.exit(ngx.HTTP_OK)
end

main()
