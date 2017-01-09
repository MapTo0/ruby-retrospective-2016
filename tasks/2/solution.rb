class String
  def integer?
    /\A[-+]?\d+\z/ === self
  end
end

class Hash
  def fetch_deep(path)
    keys = path.split(".").map { |key| key.integer? ? key.to_i : key.to_sym }
    self[keys[0]] != nil ? fetch_value(keys) : nil
  end

  def reshape(shape)
    shape.each_key do |key|
      if shape[key].class == Hash
        reshape(shape[key])
      else
        shape[key] = fetch_deep(shape[key])
      end
    end
    shape
  end

  def fetch_value(keys)
    value = dup
    keys.each do |key|
      value = value[key] || value[key.to_s]
    end
    value
  end
end

class Array
  def reshape(shape)
    map.with_index do |_, index|
      reshaped = {}
      shape.each_key do |key|
        reshaped[key] = self[index].fetch_deep(shape[key])
      end
      reshaped
    end
  end
end