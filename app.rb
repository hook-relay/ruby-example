require "net/http"
require "sinatra"
require "uri"

get "/" do
  erb :index
end

post "/" do
  logger.info "Posting to #{params[:url]} via #{ENV["HOOKRELAY_URL"]}"

  uri = URI(ENV["HOOKRELAY_URL"])
  req = Net::HTTP::Post.new(uri)

  params[:headers].split(/\r?\n/).each do |pair|
    k, v = pair.split(/:\s*/)
    req[k] = v
  end
  req["HR-Target-Url"] = params[:url]

  res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http|
    http.request(req)
  }
  logger.info "Reponse: #{res.inspect} / #{res["location"]}"

  redirect "/?location=#{res["Location"]}", 302
end
