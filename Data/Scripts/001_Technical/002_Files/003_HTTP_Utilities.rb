#############################
#
# HTTP utility functions
#
#############################
def pbPostData(url, postdata, filename = nil, depth = 0)
  if url[/^http:\/\/([^\/]+)(.*)$/]
    host = $1
#    path = $2
#    path = "/" if path.length == 0
    userAgent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.14) Gecko/2009082707 Firefox/3.0.14"
    body = postdata.map { |key, value|
      keyString   = key.to_s
      valueString = value.to_s
      keyString.gsub!(/[^a-zA-Z0-9_\.\-]/n) { |s| sprintf("%%%02x", s[0]) }
      valueString.gsub!(/[^a-zA-Z0-9_\.\-]/n) { |s| sprintf("%%%02x", s[0]) }
      next "#{keyString}=#{valueString}"
    }.join("&")
    ret = HTTPLite.post_body(
      url,
      body,
      "application/x-www-form-urlencoded",
      {
        "Host" => host, # might not be necessary
        "Proxy-Connection" => "Close",
        "Content-Length" => body.bytesize.to_s,
        "Pragma" => "no-cache",
        "User-Agent" => userAgent
      }
    ) rescue ""
    return ret if !ret.is_a?(Hash)
    return "" if ret[:status] != 200
    return ret[:body] if !filename
    File.open(filename, "wb") { |f| f.write(ret[:body]) }
    return ""
  end
  return ""
end

def pbDownloadData(url, filename = nil, authorization = nil, depth = 0, &block)
  headers = {
    "Proxy-Connection" => "Close",
    "Pragma" => "no-cache",
    "User-Agent" => "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.14) Gecko/2009082707 Firefox/3.0.14"
  }
  headers["authorization"] = authorization if authorization
  ret = HTTPLite.get(url, headers) rescue ""
  return ret if !ret.is_a?(Hash)
  return "" if ret[:status] != 200
  return ret[:body] if !filename
  File.open(filename, "wb") { |f| f.write(ret[:body]) }
  return ""
end

def pbDownloadToString(url)
  begin
    data = pbDownloadData(url)
    return data
  rescue
    return ""
  end
end

def pbDownloadToFile(url, file)
  begin
    pbDownloadData(url, file)
  rescue
  end
end

def pbPostToString(url, postdata)
  begin
    data = pbPostData(url, postdata)
    return data
  rescue
    return ""
  end
end

def pbPostToFile(url, postdata, file)
  begin
    pbPostData(url, postdata, file)
  rescue
  end
end
