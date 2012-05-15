When /^I tap (the .*)$/ do |query|
  wait_for_animations

  c = CheckPresent.new
  c.wait_for = true
  Timeout::timeout(5) {
    query.invokeCheck(c).should == true
  }

  r = query.invokeAction(:touch)
  r.count.should == 1

  wait_for_animations
end


When /^I select (([\['"])(.*)["'\]]) on (the .*)$/ do |allValue, valueType, value, query|

  query.value = Localizable.lookup_type(valueType, value)

  r = query.invokeAction(:select)
  r.count.should == 1

  wait_for_animations
end

When /^I (scroll|swipe) (the .*) to the (.*)$/ do |type, query, where|
  c = CheckPresent.new
  c.wait_for = true
  Timeout::timeout(5) {
    query.invokeCheck(c).should == true
  }

  if where == "next page"
    r = query.invoke('scrollToNextPage')
  elsif where == "top"
    r = query.invoke('scrollToTop')
  else
    r = query.invoke('swipeInDirection:', where)
  end
  r.count.should == 1

  wait_for_animations
end

# Non Table Version
Then /^I (see|wait for) (the .*) (is .*)$/ do
  |type, query, check|

  check.wait_for = (type == "wait for")

  Timeout::timeout(10) {
    ok = query.invokeCheck(check)

    expected = check.expected_value
    received = check.received_value.to_s
    
    received.should == expected if expected != nil

    if check == "not present"
      ok.should == false
    else
      ok.should == true
    end
  }
end

# Table Version
Then /^I (see|wait for) (the .*) (is .*) table$/ do
  |type, query, check, table|

  check.wait_for = (type == "wait for")
  check.expected_value = table

  Timeout::timeout(10) {
    ok = query.invokeCheck(check)
    ok.should == true
  }
end

Transform /^is (enabled|disabled|present|not present|equal to) ?(([\['"])(.*)["'\]])?/ do
  |checkType, quotedValue, type, value|

  # Create a check object from the check type.
  c = Check.fromString(checkType)
  c.expected_value = Localizable.lookup_type(type, value)
  c
end

Transform /^the ([^\'\[\"]*) ?((['"\[])(.*)[\]"'])?/ do
  |viewType, specificGlob, type, specific|

  # Helper function to pull off a check qualifier from the sentence.
  def get_and_chomp_predicate(string)
    translations = {
      "ending with" => "ENDSWITH",
      "beginning with" => "BEGINSWITH",
      "containing" => "CONTAINS",
      "like" => "LIKE",
      "matching" => "MATCHES",
    }
    translations.each_pair { |key, value|
      if string.end_with? " #{key}"
        string.chomp! " #{key}"
        return value
      end
    }
    return "="
  end

  viewType.chomp! ' '

  check = get_and_chomp_predicate(viewType)

  specific = Localizable.lookup_type(type, specific)

  lookup = FrankPredicateLookup.lookupForLabel(viewType)

  raise "Unknown view type '#{viewType}'" if lookup == nil

  QueryComponents.new(lookup,
                      :check => check,
                      :specifier => specific)
end
