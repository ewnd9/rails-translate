# Translate

The main idea of this plugin is to keep all field translations on the same
table. I've worked with other Rails plugins but all of them have some caveats,
and I needed something really simple.

## Installing

Add it to your `Gemfile`:

    gem 'translate', :git => 'https://github.com/fesplugas/rails-translate.git'

## Usage

Given a `Page` model with the following attributes:

    Page#title_en
    Page#title_es

We want an easy way to access the `title` without adding the `locale`.

    Page#title

Adding `translate :title` to our model we can get the content of the attribute
without defining the locale, and we'll get the localized field.

    >> I18n.locale
    => :en
    >> Page.first.title
    => "Hello World"

We can change the locale with `I18n.locale`.

    >> I18n.locale = :es
    => :es
    >> Page.first.title
    => "Hola Mundo"

And we'll get the `title` attribute of the defined locale.

## Migration

    class CreatePages < ActiveRecord::Migration

      def self.up
        create_table :pages do |t|
          t.string :title_en, :null => false
          t.string :title_es
        end
      end

      def self.down
        drop_table :pages
      end

    end

## Model definition

    # app/models/page.rb
    class Page < ActiveRecord::Base
      translate :title, :body
    end

Copyright (c) 2008-2010 Francesc Esplugas Marti, released under the MIT license
