cjson = require "cjson"
redis = require "resty.redis"

function getTokenfromSSM(redis_cli)
    -- get random username/password from redis
    local res, err = redis_cli:srandmember('users')
    if (not res) or (res == ngx.null) then
        ngx.log(ngx.ERR, "no users in redis")
        return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

    -- must read the request body to set body for subrequest
    ngx.req.read_body()

    -- invoke subrequest to login mydata-ssm and get token
    local result = ngx.location.capture("/login", {method = ngx.HTTP_POST, body = res});
    if (result == nil) or (result.status ~= 200) then
        ngx.log(ngx.ERR, "unable to login my-data ssm")
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR);
    end

    redis_cli:setex('token', 180, cjson.decode(result.body).token)
end

function getTokenfromRedis(redis_cli)
    result, err = redis_cli:get('token')
    if (not result) or (result == ngx.null) or (result[1] == nil) then
        getTokenfromSSM(redis_cli)
    end

    result, err = redis_cli:get('token')
    return result
end

function main()
    -- connect to redis server
    local redis_cli = redis:new()
    local ok, err = redis_cli:connect("127.0.0.1", 6379)
    if not ok then
        ngx.log(ngx.ERR, "failed to connect: ", err)
        return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

    ngx.var.token = getTokenfromRedis(redis_cli)
end

main()