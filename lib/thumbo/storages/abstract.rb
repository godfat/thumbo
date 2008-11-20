
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

  def file_paths filename
    raise NotImplementedError
  end
end
