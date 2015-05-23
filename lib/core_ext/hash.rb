# Extend the hash class to had useful methods
class Hash
  def deep_fetch(key, default = nil)
    default = yield if block_given?
    value = (deep_find(key) || default)
    fail KeyError, "Key not found: #{key}" if value.nil?
    value
  end

  def deep_find(key)
    return self[key] if self.key?(key)
    values.inject(nil) do |_a, e|
      e.deep_find(key) if e.respond_to?(:deep_find)
    end
  end
end
