require 'cfpropertylist'

# Helper class for accessing translations.   Add the following line to env.rb:
#     Localizable.add_strings(APP_BUNDLE_PATH)
#
# Change the locale with 
#     Localizable.current_locale = 'de'
#
# Access translations with
#     Localizable.lookup_en 'Done' # => 'Fertig'
#     Localizable.lookup_key 'Localization.key' # => '?'
#
# FIXME: This assumes the default language is en.   It shouldn't.
#
class Localizable
  @@current_locale ||= "en"
  @@directories ||= []
  @@localizations ||= {}

  @@inverted_en = nil

  def self.current_locale=(lang)
    @@current_locale = lang
  end
  def self.current_locale
    @@current_locale
  end

  # Specify the directories to look for 'Localizable.strings'.   Specify every bundle directory
  def self.add_strings(directory, file = 'Localizable.strings')
    @@localizations = {}
    @@directories << [directory, file]
  end

  # Contain a map of keys to english phrases.  If we are converting to another language
  # we will get the key for the given english phrase then lookup that key.  This can
  # fail if there are multiple keys for one enlish phrase.
  def self.inverted_en
    @@inverted_en ||= self.localization_for('en').invert
  end
  
  # Load all of the localization files for the specified locale
  def self.load_locale(locale)
    localization = {}
    @@directories.each do |pair|
      directory = pair[0]
      filename  = pair[1]
      file = "#{directory}/#{locale}.lproj/#{filename}"

      if FileTest.exist?(file)
        plist = CFPropertyList::List.new(:file => file)
        native = CFPropertyList.native_types(plist.value)
        localization.merge!(native)
      end
    end
    localization
  end

  # Obtain the localization for the locale - load the localization if it has not been
  def self.localization_for(locale)
    @@localizations[locale] ||= load_locale(locale)

    return @@localizations[locale]
  end

  # Obtain the current locale
  def self.current_localization
    self.localization_for(@@current_locale)
  end

  # Obtain the translation for the specified localization key
  def self.lookup_key(key)
    return self.current_localization[key]
  end

  # Attempt to translate the key into the current translation.  This will
  # Lookup the string in the inverted english map to obtain the key for the phrase.
  # and return that translation if available.
  #
  # NOTE: If there are multiple keys with the same english translation, this may
  #       fail - use lookup_key with the proper localization key instead.
  def self.lookup_en(string)
    key = string
    localeMap = self.current_localization

    if @@current_locale != 'en'
      newKey = self.inverted_en[key]

      if (newKey && localeMap.has_key?(newKey))
        return localeMap[newKey]
      elsif localeMap.has_key?(key)
        return localeMap[key]
      end
    end
    return string
  end

  # String specificiation convention you can use.  Enclosure (['") should be broken out by regex
  # step ala  ?((['"\[])(.*)[\]"']) |wholeValue, type, specific|
  #
  # - [<value>] will lookup the key
  # - '<value>' will lookup the english phrase and translate the resulting key.
  # - "<value>" will return the value.
  def self.lookup_type(type, value)
    if type == '['
      Localizable.lookup_key(value)
    elsif type == "'"
      Localizable.lookup_en(value)
    else
      value
    end
  end
end

