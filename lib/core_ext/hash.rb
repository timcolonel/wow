class Hash
  def deep_fetch(key, default = nil)
    default = yield if block_given?
    (deep_find(key) or default) or fail KeyError.new("key not found: #{key}")
  end

  def deep_find(key)
    key?(key) ? self[key] : self.values.inject(nil) { |memo, v| memo ||= v.deep_find(key) if v.respond_to?(:deep_find) }
  end
end