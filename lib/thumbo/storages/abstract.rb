
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

  def exist? filename
    raise NotImplementedError
  end

  protected
  def raise_file_not_found filename
    raise Thumbo::FileNotFound.new(filename)
  end
end
