cjson = require "cjson"
redis = require "resty.redis"

function main() 
    local redis_cli = redis:new()
    local ok, err = redis_cli:connect("127.0.0.1", 6379)
    if not ok then
         ngx.log(ngx.ERR, "failed to connect: ", err)
         ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end 

    local truncated_key = string.match(ngx.var.key, '(.+)%(')
    local res = ngx.location.capture('/ssm/' .. ngx.var.key)
    if res.status ~= 200 then
        ngx.log(ngx.ERR, 'failed to invoke SSM API')
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
    
    local res_json = cjson.decode(res.body)

    -- if entityList from ssm is empty, request mydata-ssm api again with truncated key
    if not res_json.success and truncated_key then
        res = ngx.location.capture('/ssm/' .. truncated_key)
        if res.status ~= 200 then
            ngx.log(ngx.ERR, 'failed to invoke SSM API')
            ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
        end
        res_json = cjson.decode(res.body)    
    end

    cache(res_json.entityList, ngx.unescape_uri(string.upper(ngx.var.key)), redis_cli)

    -- return 404 error code to trigger error_page directive
    return ngx.exit(ngx.HTTP_NOT_FOUND)
end

-- cache into redis and check if exact match company name can be found
function cache(entityList, key, redis_cli)
    if #entityList > 0 then
        a = string.sub(cjson.encode(entityList), 2, -2)
        redis_cli:setex(key, 86400, a)
    end

    for index, entity in ipairs(entityList) do
        local e = cjson.encode(entity)
        redis_cli:set(string.gsub(entity.name, '[%(%)%.%,]', ''), e)
        redis_cli:set(string.sub(entity.regNo, 1, -3), e)
        redis_cli:set(entity.name, e)
        redis_cli:set(entity.regNo, e)
        redis_cli:set(entity.newRegNo, e)
    end
end

main()
