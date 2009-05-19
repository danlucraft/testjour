require 'spec/expectations'
$:.unshift(File.dirname(__FILE__) + '/../../lib') # This line is not needed in your own project
require 'calculator'

Before do
  @calc = Demo::Calculator.new
end

Given "I have entered $n into the calculator" do |n|
  if n == "asd"
    raise "error!!"
  end
  sleep 0.1
  @calc.push n.to_i
end

When /I press (\w+)/ do |key|
  sleep 0.1
  @calc.send(key.intern)
end

Then /the result should be (.*) on the screen/ do |result|
  sleep 0.1
  @calc.screen.should == result.to_i
end
