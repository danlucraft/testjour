Given /^I am a naughty step$/ do
  @naughty = true
end

class NaughtyScenarioException < Exception; end

After do
  if @naughty
    raise(NaughtyScenarioException.new("I have been very very naughty"))
  end
end