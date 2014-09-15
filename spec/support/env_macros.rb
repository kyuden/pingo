module ENVMacros
  def set_valid_env
    ENV['APPLE_ID'] = "valid@sample.com"
    ENV['APPLE_PASSWORD'] = "valid_pass"
  end

  def set_invalid_env
    ENV['APPLE_ID'] = "invalid@sample.com"
    ENV['APPLE_PASSWORD'] = "invalid_pass"
  end
end
