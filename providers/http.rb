
def valid_user_password?(user, password)
  return !user.nil? && !password.nil?
end

def get_authorization_header(user, password)
  return "Basic " + Base64.encode64("#{user}:#{password}")
end

def get_headers(user, password, headers)
  hdrs = headers.nil? ? Hash.new : headers
  hdrs['Content-Type'] = 'application/json'
  if valid_user_password?(user, password)
    hdrs['AUTHORIZATION'] = get_authorization_header(user, password)
  end
  return hdrs
end

def get_headers_curl(user, password, headers)
  return get_headers(user, password, headers).map{|k, v| " -H \"#{k}: #{v}\""}.join(" ")
end

action :get do
  http_request 'get request' do
    action :get
    url new_resource.url
    headers get_headers(new_resource.user, new_resource.password, new_resource.headers)
    retries new_resource.retries
    retry_delay new_resource.retryDelay
  end
end

action :delete do
  http_request 'delete request' do
    action :delete
    url new_resource.url
    headers get_headers(new_resource.user, new_resource.password, new_resource.headers)
    retries new_resource.retries
    retry_delay new_resource.retryDelay
    only_if {new_resource.only_if_cond} if !new_resource.only_if_cond.nil?
    if new_resource.only_if_exists
      if valid_user_password?(new_resource.user, new_resource.password)
        not_if "test \"$(curl -s -k -o /dev/null -w '%{http_code}\n' -u #{new_resource.user}:#{new_resource.password} #{new_resource.url})\" = \"404\""
      else
        not_if "test \"$(curl -s -o /dev/null -w '%{http_code}\n' #{new_resource.url})\" = \"404\""
      end
    end
  end
end

action :put do
  http_request 'put request' do
    action :put
    url new_resource.url
    headers get_headers(new_resource.user, new_resource.password, new_resource.headers)
    message new_resource.message
    retries new_resource.retries
    retry_delay new_resource.retryDelay
    only_if {new_resource.only_if_cond} if !new_resource.only_if_cond.nil?
    if new_resource.only_if_exists == false
      if valid_user_password?(new_resource.user, new_resource.password)
        only_if "test \"$(curl -s -k -o /dev/null -w '%{http_code}\n' -u #{new_resource.user}:#{new_resource.password} #{new_resource.url})\" = \"404\""
      else
        only_if "test \"$(curl -s -o /dev/null -w '%{http_code}\n' #{new_resource.url})\" = \"404\""
      end
    end
  end
end

action :post do
  http_request 'post request' do
    action :post
    url new_resource.url
    headers get_headers(new_resource.user, new_resource.password, new_resource.headers)
    message new_resource.message
    retries new_resource.retries
    retry_delay new_resource.retryDelay
    only_if {new_resource.only_if_cond} if !new_resource.only_if_cond.nil?
  end
end

action :post_curl do
  bash 'post request' do
    user node['hopslog']['user']
    code <<-EOF
    curl -k -XPOST #{get_headers_curl(new_resource.user, new_resource.password, new_resource.headers)} #{new_resource.url} -d #{new_resource.message}
    EOF
    retries new_resource.retries
    retry_delay new_resource.retryDelay
    only_if {new_resource.only_if_cond} if !new_resource.only_if_cond.nil?
  end
end
