
def wait_for_turbo
  counter = 0
  puts page.evaluate_script("typeof(Turbo)  != 'object'")
  while page.evaluate_script("typeof(Turbo)  != 'object'")
    counter += 1
    print "_"
    $stdout.flush
    sleep(0.1)
    if counter > 100
      raise "there was an error waiting for #{query_selector}"
    end
  end
end
