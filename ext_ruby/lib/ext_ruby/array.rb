class Array
  class SizeMismatch < ::StandardError; end

  def mode
    return if empty?
    counts = each_with_object(Hash.new(0)){ |v, h| h[v] += 1 }
    max = counts.values.max
    counts.find{ |_v, count| count == max }.first
  end

  def average(&block)
    return if empty?
    total = sum(&block)
    total / size.to_f
  end
  alias_method :mean, :average

  def stddev(...)
    return if empty?
    Math.sqrt(variance(...))
  end

  def variance(mean = average)
    return if empty?
    total = sum{ |v| (v - mean) ** 2 }
    total / size.to_f
  end
  alias_method :var, :variance

  def median
    percentile(0.5)
  end

  def percentile(bucket)
    return if empty?
    bucket /= 100.0 if bucket > 1.0
    values = sort
    last_i = values.size - 1
    upper_i = bucket.to_f * last_i
    lower_i = upper_i.floor
    if lower_i == last_i
      values.last
    else
      values[lower_i] + (upper_i % 1) * (values[lower_i + 1] - values[lower_i])
    end
  end

  def join!(separator = $,)
    reject(&:blank?).join(separator)
  end

  def except(*values)
    self - values
  end

  def insert_before(anchor, value)
    insert((index(anchor) || -1), value)
  end

  def insert_after(anchor, value)
    insert((index(anchor) || -2) + 1, value)
  end

  def switch(old_value, new_value)
    arr = dup
    arr.switch! old_value, new_value
    arr
  end

  def switch!(old_value, new_value)
    return unless (i = index(old_value))
    self[i] = new_value
    self
  end

  def intersperse(element)
    flat_map{ |e| [e, element] }.tap(&:pop)
  end

  def neg
    map{ |x| -x }
  end

  def mul(value)
    return map{ |x| x * value } unless value.is_a? Array
    raise SizeMismatch if size != value.size
    map.with_index{ |x, i| x * value[i] }
  end

  def div(value)
    return map{ |x| x / value } unless value.is_a? Array
    raise SizeMismatch if size != value.size
    map.with_index{ |x, i| x / value[i] }
  end

  def sub(value)
    return map{ |x| x - value } unless value.is_a? Array
    raise SizeMismatch if size != value.size
    map.with_index{ |x, i| x - value[i] }
  end

  def add(value)
    return map{ |x| x + value } unless value.is_a? Array
    raise SizeMismatch if size != value.size
    map.with_index{ |x, i| x + value[i] }
  end

  def l0(other = nil)
    return sum{ |x| !x.zero? } if other.nil?
    raise SizeMismatch if size != other.size
    sum_with_index{ |x, i| (x != other[i]).to_f }
  end

  def l1(other = nil)
    return sum(&:abs) if other.nil?
    raise SizeMismatch if size != other.size
    sum_with_index{ |x, i| (x - other[i]).abs }
  end

  def l2(...)
    Math.sqrt(l2_squared(...))
  end

  def l2_squared(other = nil)
    return sum{ |x| x ** 2 } if other.nil?
    raise SizeMismatch if size != other.size
    sum_with_index{ |x, i| (x - other[i]) ** 2 }
  end

  def l_infinity(other = nil)
    return max_by(&:abs) if other.nil?
    raise SizeMismatch if size != other.size
    max_by.with_index{ |x, i| (x - other[i]).abs }
  end
  alias_method :l_inf, :l_infinity

  def sum_with_index(&block)
    map.with_index(&block).sum
  end
end
