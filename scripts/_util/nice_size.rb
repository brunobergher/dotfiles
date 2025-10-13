def nice_size(bytes)
  {
    'B'  => 1024,
    'KB' => 1024 * 1024,
    'MB' => 1024 * 1024 * 1024,
    'GB' => 1024 * 1024 * 1024 * 1024,
    'TB' => 1024 * 1024 * 1024 * 1024 * 1024
  }.each_pair { |e, s| return "#{(bytes.to_f / (s / 1024)).round(2)}#{e}" if bytes < s }
end