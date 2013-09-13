local say = ngx.say
local log = ngx.log
local ERR = ngx.ERR
local req = ngx.req
local req_headers = req.get_headers()
local request = ngx.location.capture
local headers = ngx.header

local facebook_api = settings.facebook_api
local twitter_api = settings.twitter_api -- .. '1/urls/count.json'
local uri_args = req.get_uri_args()
local article_url = uri_args.url

function get_json(url, args)
    local resp = request(url, { args = args })
    if resp.status == 200 then
        return cjson.decode(resp.body)
    end
    return nil
end

function render_template(template, environment)
    function replace(x)
        local key = x:sub(3, -2) -- peel ${} from ${foobar}
        return environment[key] or key
    end
    local result = template:gsub('($%b{})', replace)
    return result
end

--[[
function calculate_repr_type(accept)
    if accept and accept:matchthen
        return "text/html; charset=utf-8"
end
]]

if not article_url then
    headers["Content-Type"] = "application/json"
    say(cjson.encode({}))
else
    local facebook_json = get_json(facebook_api, { id = article_url })
    local facebook_shares = facebook_json and facebook_json.shares or 0
    local facebook_comments = facebook_json and facebook_json.comments or 0
    local facebook_count = (facebook_shares + facebook_comments)

    local twitter_json = get_json(twitter_api, { url = article_url }) 
    local twitter_count = twitter_json and twitter_json.count or 0

    --local repr = calculate_repr_type(req_headers["Accept"])

    headers["Content-Type"] = "text/html; charset=utf-8"
    say(render_template([[
<div class="sharecounts" data-for="">
    <span class="facebook-count">${fbcount}</span>    
    <span class="facebook-shares">${fbshares}</span>    
    <span class="facebook-comments">${fbcomments}</span>    
    <span class="twitter-count">${twcount}</span>    
</div>]], {
    fbcount = facebook_count, 
    fbshares = facebook_shares, 
    fbcomments = facebook_comments, 
    twcount = twitter_count}))

    --[[
    say(cjson.encode({ 
        url = article_url,
        facebook = {
            shares = facebook_shares,
            comments = facebook_comments,
            count = facebook_shares + facebook_comments
        },
        twitter = {
            count = twitter_count
        }
    }))
    ]]

end
