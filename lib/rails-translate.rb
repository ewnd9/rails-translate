module Rails
  module Translate

    def self.included(base)
      base.extend(ActsMethods)
    end

    def self.translated_attribute_name(attribute, locale)
      db_friendly_locale = locale.to_s.gsub('-', '_').downcase
      "#{attribute}_#{db_friendly_locale}"
    end

    def translated_attribute_name(attribute, locale)
      Rails::Translate.translated_attribute_name(attribute, locale)
    end

    module ActsMethods

      def translate(*args)

        args.each do |arg|

          define_method(arg.to_s) do
            attribute = translated_attribute_name(arg, I18n.locale)
            default_attribute = translated_attribute_name(arg, I18n.default_locale)
            begin
              return send(attribute).empty? ? send(default_attribute) : send(attribute)
            rescue
              return send(default_attribute)
            end
          end

          define_method(arg.to_s + '=') do |data|
            attribute = translated_attribute_name(arg, I18n.locale)
            write_attribute attribute, data if self.respond_to? attribute
          end

        end

        extend ClassMethods

      end # translate

      module ClassMethods

        def method_missing(method, *args)
          if method.to_s =~ /^find_(all_by|by)_([_a-zA-Z]\w*)$/
            if column_methods_hash.include?($2.to_sym)
              super
            else
              modifier = $1
              attribute = Rails::Translate.translated_attribute_name($2, I18n.locale.to_s)
              send("find_#{modifier}_#{attribute}".to_sym, *args)
            end
          else
            super
          end
        end

      end

    end

  end
end

ActiveRecord::Base.send :include, Rails::Translate
