class Hunter
  def initialize(key)
    @key = key
    @agent = Mechanize.new
  end

  def get_format(domain)
    JSON.parse(@agent.get("https://api.hunter.io/v2/domain-search?domain=#{domain}&api_key=#{@key}").body)["data"]["pattern"]
  end
end
