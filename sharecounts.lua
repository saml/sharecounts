local say = ngx.say
local log = ngx.log
local ERR = ngx.ERR
local req = ngx.req
local req_headers = req.get_headers()
local request = ngx.location.capture
local headers = ngx.header

local facebook_api = settings.facebook_api
local twitter_api = settings.twitter_api 
local uri_args = req.get_uri_args()
local article_url = uri_args.url

function get_json(url, args)
    local resp = request(url, { args = args })
    if resp.status == 200 then
        local _,result = pcall(cjson.decode, resp.body)
        return result
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

function get_facebook_count()
    local resp = get_json(facebook_api, { id = article_url })
    local shares = resp and resp.shares or 0
    local comments = resp and resp.comments or 0
    local count = shares + comments
    return { shares = shares, comments = comments, count = count }
end

function get_twitter_count()
    local resp = get_json(twitter_api, { url = article_url }) 
    return { count = resp and resp.count or 0 }
end

if not article_url then
    headers["Content-Type"] = "application/json"
    say(cjson.encode({}))
else
    local facebook = get_facebook_count()
    local twitter = get_twitter_count()

    headers["Content-Type"] = "text/html; charset=utf-8"
    say(render_template([[
<div class="sharecounts" data-for="${url}">
    <span class="facebook-count"    data-n="${fbcount}">${fbcount} fb total.</span>    
    <span class="facebook-shares"   data-n="${fbshares}">${fbshares} likes.</span>    
    <span class="facebook-comments" data-n="${fbcomments}">${fbcomments} comments.</span>    
    <span class="twitter-count"     data-n="${twcount}">${twcount} tweets.</span>    
</div>]], {
        url = article_url,
        fbcount = facebook.count, 
        fbshares = facebook.shares, 
        fbcomments = facebook.comments, 
        twcount = twitter.count,
    }))
end
