class Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  throttle("logins/ip", limit: 5, period: 10.minutes) do |req|
    req.ip if req.path == "/users/sign_in" && req.post?
  end

  throttle("logins/email", limit: 5, period: 10.minutes) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.params.dig("user", "email").to_s.downcase.strip.presence
    end
  end

  self.throttled_responder = lambda do |_request|
    [
      429,
      { "Content-Type" => "text/plain" },
      ["Too many login attempts. Please try again later."]
    ]
  end
end