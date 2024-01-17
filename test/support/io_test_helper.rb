module IoTestHelper
  def io_refresh!
    @stdout = StringIO.new
    @stderr = StringIO.new
  end

  def stdout
    @stdout
  end

  def stderr
    @stderr
  end

  def read_output!
    io_read_and_reset(@stdout)
  end

  def read_errors!
    io_read_and_reset(@stderr)
  end

  def io_read_and_reset(io)
    io.tap(&:rewind).read.tap do
      io.truncate(0)
      io.rewind
    end
  end
end
