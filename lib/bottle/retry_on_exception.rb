module RetryOnException
  def retry_on_exception(max_retries=3, reset_delay=30, terminal_error=RuntimeError.new)
    @_retries ||= 0
    @_last_exception ||= Time.now.to_i

    @_retries = 0 if (Time.now.to_i - @_last_exception) > reset_delay

    @_last_exception = Time.now.to_i

    if @_retries < max_retries 
      @_retries += 1
      puts "Exception triggered in [..]. Retry attempt #{@_retries} of #{max_retries}..."
      yield
    else
      raise terminal_error 
    end
  end 
end
