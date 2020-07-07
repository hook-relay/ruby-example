require "net/http"
require "sinatra"
require "uri"

get "/" do
  erb :index
end

post "/" do
  logger.info "Posting to #{params[:url]} via #{ENV["HOOKRELAY_URL"]}"

  headers = params[:headers].split(/\r?\n/).each_with_object({}) { |pair, h|
    k, v = pair.split(/:\s*/)
    h[k] = v
  }.merge("HR-Target-Url" => params[:url])

  res = Net::HTTP.post(URI(ENV["HOOKRELAY_URL"]), params[:body], headers)

  logger.info "Reponse: #{res.inspect} / #{res["location"]}"

  redirect "/?location=#{res["Location"]}", 302
end
