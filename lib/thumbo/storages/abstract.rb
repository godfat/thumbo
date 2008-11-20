
class AbstractStorage
  def read filename
    raise NotImplementedError
  end

  def write filename, blob
    raise NotImplementedError
  end

  def delete filename
    raise NotImplementedError
  end

  def paths filename
    raise NotImplementedError
  end
end
