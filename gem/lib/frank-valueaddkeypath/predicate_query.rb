require 'frank-cucumber/frank_helper.rb'
require 'features/support/frank_helper'


class Object
  def predicate_value(components)
    if self.kind_of?(Symbol)
      self.to_s
    elsif self.kind_of?(String)
      self
    elsif self.kind_of?(Array)
      result = self.collect {|item| item.predicate_value(components)}
      result.join(" && ")
    elsif self.kind_of?(Hash)
      array = []
      self.each {|key, value| 
        if key.kind_of?(Symbol)
          array << components.send(key, value)
        else
          array << "#{key} == #{value.predicate_value(components)}"
        end
      }
      array.predicate_value(components)
    elsif self.kind_of?(Proc)
      result = self.call(components)
      result.predicate_value(components)
    elsif self.kind_of?(TrueClass)
      "YES"
    elsif self.kind_of?(FalseClass)
      "NO"
    else
      raise "Unsupported object #{self} / #{self.class}"
    end
  end
end


class Check
  def self.fromString(string)
    # 'not present' -> 'CheckNotPresent'
    classname = 'Check'+ string.split(' ').collect {|word| word.capitalize}.join('')
    c = eval(classname)
    raise "Unknown check '#{string}'" if c == nil
    return c.new()
  end

  attr_reader :action, :expected_value, :wait_for, :received_value
  attr_writer :action, :expected_value, :wait_for, :received_value

  def verifyCount(count)
    return count == 1
  end

  def checkResult(r)

    ok = self.verifyCount(r.count)
    if ok && self.expected_value != nil
      if self.expected_value.kind_of?(Cucumber::Ast::Table)
        self.received_value = r[0]
        self.expected_value.raw.each_with_index {|row, rindex|
          rrow = self.received_value[rindex]
          row.each_with_index {|column, cindex|
            rcol = rrow[cindex]
            return false if (rcol != column)
          }
        }
      else
        self.received_value = r[0]
        ok = self.received_value.to_s == self.expected_value
      end
    end
    return ok
  end
end

class CheckEnabled < Check
  def initialize
    self.action = :enabled
    self.expected_value = true
  end
  # Can not change expected_value, make it a no-op
  def expected_value=(arg)
  end
end

class CheckDisabled < CheckEnabled
  def initialize
    self.expected_value = false
  end
end

class CheckPresent < Check
  def initialize
    self.action = :value
    self.expected_value = nil
  end
  def verifyCount(count) 
    count > 0
  end
  # Can not change expected_value, make it a no-op
  def expected_value=(arg)
  end
end

class CheckNotPresent < CheckPresent
  def verifyCount(count) 
    count == 0
  end
end

class CheckEqualTo < Check
  def initialize
    self.action = :value
  end
end

class QueryComponents
  attr_reader :proxy, :check, :specifier, :value
  attr_writer :proxy, :check, :specifier, :value
  def initialize(proxy, options = {})
    @proxy = proxy
    @check = options[:check] 
    @specifier = options[:specifier]
    @value = options[:value]

    # Ensure check has a value.
    @check ||= '='
  end

  def accessibilityPredicate(specifier, check = nil)
    specifier ||= self.specifier
    check ||= self.check
    "accessibilityLabel #{check} '#{specifier}'"
  end

  def className(specifier, check = nil)
    specifier ||= self.specifier
    "(self isKindOfClassByString:'#{specifier}')"
  end

  def tag(specifier = nil, check = nil)
    specifier ||= self.specifier
    if specifier.kind_of?(String) == false
      specifier = specifier.to_s
    end

    "tag = #{specifier}"
  end

  def invoke(selector, *args)
    self.proxy.invoke(self, selector, *args)
  end

  def invokeAction(action)
    results = self.proxy.invokeAction(action, self)
  end

  def invokeCheck(check)
    r = self.invokeAction(check.action)
    ok = check.checkResult(r)

    if check.wait_for == true && ok != true
      sleep 0.5
      return self.invokeCheck(check)
    end
    return ok
  end
end

class FrankPredicateLookup
  @@invoker = Object.new.extend(Frank::Cucumber::FrankHelper)

  @behavior = {}
  attr_reader :behavior

  def initialize(behavior)
    @behavior.merge!(behavior)
  end

  def specificRestriction(components)
    specific = @behavior[:specific]
    specific_check = @behavior[:specific_check]

    if specific.kind_of?(Symbol)
      components.send(specific, components.specifier, specific_check)
    elsif specific.kind_of?(Proc)
      specific.call(components)
    end
  end

  def queryFor(components)
    query = self.defaultQuery()

    if @behavior[:predicate] != nil
      predicateObjects = [] + @behavior[:predicate]
      

      if components.specifier != nil
        specificPredicate = self.specificRestriction(components)
        predicateObjects << specificPredicate if specificPredicate != nil
      end

      predicate = predicateObjects.predicate_value(components)
      query = query + "[[" + predicate  + "]]"
    end

    if @behavior[:post_path] != nil
      query += @behavior[:post_path]
    end

    query
  end

  def selectorFor(key, components)
    custom = @behavior[key]
    raise "Unknown behavior #{key}" if custom == nil

    if custom.kind_of?(Symbol)
      custom.to_s
    elsif custom.kind_of?(String)
      custom
    elsif custom.kind_of?(Hash)
      custom
    elsif custom.kind_of?(Proc)
      custom.call(components)
    else
      raise "Unsupported behavior key #{key} => #{custom}"
    end
  end

  def defaultQuery
    ""
  end

  def invoke(components, selector, *values)
    query = self.queryFor(components)

    @@invoker.frankly_engine_map('filtered_keypath', query, selector, *values)
  end

  def invokeAction(label, components)
    sel = self.selectorFor(label, components)
    if sel.kind_of?(String)
      return self.invoke(components, sel)
    else
      selector = sel.keys.join('')
      return self.invoke(components, selector, *sel.values)
    end
  end

  def displayType(result)
    if result == nil
      'nil'
    elsif result.kind_of?(TrueClass)
      "true"
    elsif result.kind_of?(FalseClass)
      "false"
    elsif result.kind_of?(Numeric)
      "" + result.to_s + ""
    elsif result.kind_of?(Array)
      "[" + result.collect {|subresult|
        displayType(subresult)
      }.join(', ') + "]"
    else
      "'" + result + "'"
    end
  end

  def display(results, displayCount)
    if self.behavior.has_key? :select
      puts "# Selectable"
    end
    puts "# Visible Results: #{results.count}"

    display = results[0..displayCount].collect {|result|
      displayType(result)
    }
    display << "And #{results.count - displayCount} more" if results.count > displayCount && displayCount != -1

    puts "# Values: #{display.join(', ')}"
  end
end

class FrankViewPredicateLookup < FrankPredicateLookup
  def initialize(behavior)
    @behavior = {
      :value => 'accessibilityLabel',
      :touch => 'touch',
      :enabled => 'isEnabled'
    }
    super(behavior)

    @behavior[:predicate] ||= []
    if @behavior[:predicate].kind_of?(Array) == false
      @behavior[:predicate] = [ @behavior[:predicate] ]
    end
    @behavior[:predicate] << "isOnScreen=YES"
    @behavior[:predicate] << "isHidden=NO"
  end

  def defaultQuery
    "windows.@flattenBy.subviews"
  end
end

class FrankPredicateLookup
  @@grammar = {}
  def self.addLabel(label, behavior = {})
    @@grammar[label] = FrankViewPredicateLookup.new(behavior)
  end

  def self.addView(label, behavior = {})
    if behavior[:predicate] == nil
      className = "UI"
      label.split(' ').each {|word|
        className += word.capitalize
      }
      behavior[:predicate] = [ "(self isKindOfClassByString:'#{className}')" ]
    end

    if behavior[:specific] == nil
      behavior[:specific] = :tag
    end
    self.addLabel(label, behavior)
  end

  def self.cloneLabel(label, newLabel, behavior ={})
    proxy = @@grammar[label]
    
    oldBehavior = proxy.behavior
    behavior = oldBehavior.merge(behavior)

    @@grammar[newLabel] = proxy.class.new(behavior)
  end

  def self.lookupForLabel(label)
    @@grammar[label]
  end

  def self.displayMatchesFor(label, specific = nil)
    proxy = self.lookupForLabel(label)
    c = QueryComponents.new('')
    if specific != nil
      c.specifier = specific
    end
    results = proxy.invokeAction(:value, c)

    if results.count != 0
      puts "################################################################"
      puts "# Element: #{label}"
      proxy.display(results, -1)
    end
  end

  def self.displayMatches(min = 3, visible = 0)
    c = QueryComponents.new('')
    @@grammar.each_pair {|key, proxy|
      results = proxy.invokeAction(:value, c)
      if results.count > visible
        puts "################################################################"
        puts "# Element: #{key}"    
        proxy.display(results, min)
      end
    }
  end

  def self.displayAllElements
    self.displayMatches(3, -1)
  end
end

FrankPredicateLookup.addView('accessibility label', :predicate => [], :specific => :accessibilityPredicate, :specific_required => true)
                
FrankPredicateLookup.addView('label', :specific => :accessibilityPredicate, :specific_required => true)
FrankPredicateLookup.addView('button', 
                             :specific => :accessibilityPredicate, 
                             :specific_required => true,
                             :value => 'currentTitle')
FrankPredicateLookup.addView('web view')

FrankPredicateLookup.addView('segment',
                :specific => :accessibilityPredicate,
                :specific_check => 'BEGINSWITH[c]'
                )
                
FrankPredicateLookup.addView('switch', :value => 'isOn')
                             


FrankPredicateLookup.addView('segmented control',
                :value => proc{|components| 
                               {'titleForSegmentAtIndex:' => components.specifier.to_i}
                },
                :specific_required => true,
                :touch => proc{|components|
                  {'selectSegmentAtIndex:' => components.specifier.to_i}
                },
                :select => proc{|components| 
                  {'selectSegmentAtIndex:' => components.value.to_i}
                },
                :enabled => proc{|components|
                  if components.specifier
                    {'isEnabledForSegmentAtIndex:' => components.specifier.to_i}
                  else
                    'isEnabled'
                  end
                }
                )

FrankPredicateLookup.addView('date picker',
                             :value => {'valueForKeyPath:' => "date.timeIntervalSince1970"},
                :select => proc{|components| 
                               {"selectDateFromTimestamp:" => Time.parse(components.value).to_i}
                             }
                             )

FrankPredicateLookup.addView('picker view',
                :value => {'selectedTitleInComponent:' => 0},
                :select => proc{|components| {"selectTitle:" => components.value, 'inComponent:' => 0}}
                )

FrankPredicateLookup.addView('picker view component',
                :predicate => {:className => 'UIPickerView'}, :specific_required => true,
                :value =>  proc{|components| {
                    'selectedTitleInComponent:' => components.specifier.to_i}},
                :select => proc{|components| {
                    "selectTitle:" => components.value, 
                    'inComponent:' => components.specifier.to_i}}
                )

FrankPredicateLookup.addView('alert button',
                :predicate => ["(self isKindOfClassByString:'UIThreePartButton') || (self isKindOfClassByString:'UIButton' && self.superview isKindOfClassByString:'UIAlertView')"],
                :specific => :accessibilityPredicate
                )

FrankPredicateLookup.addView('action sheet button',
                             :predicate => ["(self isKindOfClassByString:'UIButtonLabel' && self.superview isKindOfClassByString:'UIAlertButton') || (self isKindOfClassByString:'UIThreePartButton' && self.superview isKindOfClass:'UIActionSheet')"],
                             :specific => :accessibilityPredicate
                )

#FrankPredicateLookup.addView('first table row',
#                :predicate => {:className => 'UITableView'},
#                :post_path => '.visibleCells.@firstObject'
#                )

FrankPredicateLookup.addView('table view') # Useful for scrolling

FrankPredicateLookup.addView('navigation title',
                :predicate => {:className => 'UINavigationItemView'}
                )

FrankPredicateLookup.addView('navigation item',
                :predicate => ["(self isKindOfClassByString:'UINavigationButton' || self isKindOfClassByString:'UINavigationItemButtonView')"],
                :specific => :accessibilityPredicate
                )

FrankPredicateLookup.addView('toolbar item',
                :predicate => {:className => 'UIToolbarTextButton'},
                :specific => :accessibilityPredicate,
                :specific_check => 'BEGINSWITH[c]'
                )

FrankPredicateLookup.addView('tab bar item',
                :predicate => {:className => 'UITabBarButton'},
                :specific => :accessibilityPredicate,
                :specific_check => 'BEGINSWITH[c]'
                )

FrankPredicateLookup.addView('selected tab bar item',
                :predicate => ["(self isKindOfClassByString:'UITabBarButton') && SUBQUERY(subviews, $s, ($s isKindOfClassByString:'UITabBarSelectionIndicatorView')).@count == 1"],
                :specific => :accessibilityPredicate,
                :specific_check => 'BEGINSWITH[c]'
                )

################################################################
# Saturn Specific

FrankPredicateLookup.addView('card main label',
                             :predicate => {:className => 'AGUNumericLabel'},
                             :value => 'valueString')

FrankPredicateLookup.addView('card tab',
                             :predicate => {:className => 'AGUCardTab'},
                             :specific => proc{|components| 
                               index = ['Glucose', 'Carbs', 'Insulin'].index(components.specifier)
                               tabTag = 100 + index + 1
                               "tag = #{tabTag}"
                             },
                             :value => 'text')

FrankPredicateLookup.cloneLabel('card main label', 'card main unit label',
                                :value => 'unitString')

FrankPredicateLookup.addView('card note count',
                             :predicate => {:className => 'NoSwipeTableView'},
                             :value => {'numberOfRowsInSection:' => 0})

FrankPredicateLookup.addView('card note cell',
                             :predicate => ["(self isKindOfClassByString:'AGUCardNoteCell')"],
                             :specific => :accessibilityPredicate,
                             :value => "accessibilityLabel")


FrankPredicateLookup.addView('card aux label',
                             :predicate => {:className => 'AGURespondLabel', :tag => 112},
                             :value => 'valueString')
FrankPredicateLookup.addView('card time label',
                             :predicate => {:className => 'AGURespondLabel', :tag => 113},
                             :value => 'valueString')
FrankPredicateLookup.addView('card time bucket label',
                             :predicate => {:className => 'AGURespondLabel', :tag => 114},
                             :value => 'valueString')

FrankPredicateLookup.addView('card delete button',
                             :predicate => {:className => 'UIButton', :accessibilityPredicate => 'Delete'})

FrankPredicateLookup.cloneLabel('table view', 'card note table',
                                :predicate => {:className => 'NoSwipeTableView'})


FrankPredicateLookup.addView('logbook cell',
                             :predicate => {:className => 'AGULogbookCell'},
                             :specific => proc{|components|
                               date = components.specifier.split(' ').join('\n')

                               "dateLabel.text = '#{date}'"
                             },
                             :value => {
                               'valueForKeyPath:' => 'rowViews.buttons.currentTitle'
                             },
                             :select => proc{|components|
                                 tap = ['Pre-Breakfast', 'Post-Breakfast',
                                        'Pre-Lunch', 'Post-Lunch',
                                        'Pre-Dinner', 'Post-Dinner',
                                        'Night']
                                 columnIndex = tap.index(components.value)

                                 x = 40 + 20 + (40 * columnIndex)
                                 y = 20
                                 {'y:' => y, "tapAtPointX:" => x}}
                             )


FrankPredicateLookup.addView('note cell',
                             :predicate => ["(self isKindOfClassByString:'AGUBlueCheckMarkCell')"],
                             :post_path => "textField",
                             :specific => proc{|components|
                               "textField.text = '#{components.specifier}'"
                             },
                             :value => "text")
                             

FrankPredicateLookup.addView('note cell delete icon',
                             :predicate => ["(self isKindOfClassByString:'AGUBlueCheckMarkCell')"],
                             :post_path => "subviews[[(self isKindOfClassByString:'UITableViewCellEditControl')]]",
                             :value => ".superview.textField.text",
                             :specific => proc{|components|
                               "textField.text = '#{components.specifier}'"
                             })

FrankPredicateLookup.addView('note cell delete confirmation for',
                             :predicate => ["(self isKindOfClassByString:'AGUBlueCheckMarkCell')"],
                             :specific => proc{|components|
                               "textField.text = '#{components.specifier}'"
                             },

                             :touch => "delete"
                             )

                             
