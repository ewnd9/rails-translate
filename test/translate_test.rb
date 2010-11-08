require 'test/unit'
require 'rubygems'
require 'active_record'

$LOAD_PATH << File.expand_path("#{File.dirname(__FILE__)}/../lib")
require 'translate'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

def setup_db

  silence_stream(STDOUT) do
    ActiveRecord::Schema.define(:version => 1) do
      create_table :pages, :force => true do |t|
        t.string :name_en
        t.string :name_es
        t.text :body_en
        t.text :body_es
        t.timestamps
      end
    end
  end

end

class Page < ActiveRecord::Base
  translate :name, 'body'
end

class TranslateTest < Test::Unit::TestCase

  def setup

    setup_db

    Page.create :name_en => "Name", 
                :name_es => "Nombre", 
                :body_en => "Content", 
                :body_es => "Contenido",
                :created_at => Time.now - 60

    Page.create :name_en => "Second Name",
                :name_es => "Nombre",
                :body_en => "Second Content",
                :body_es => "Segundo Contenido",
                :created_at => Time.now

    I18n.default_locale = :en
    I18n.locale = :en

  end

  def teardown
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end

  def test_should_get_title_en_of_the_page
    page = Page.first
    assert_equal page.send('name_en'), page.name
  end

  def test_should_get_title_es_of_the_page
    I18n.locale = :es
    page = Page.first
    assert_equal page.send('name_es'), page.name
  end

  def test_should_return_title_en_when_undefined_locale
    I18n.locale = :undefined
    page = Page.first
    assert_equal page.send('name_en'), page.name
  end

  def test_should_return_title_es_because_is_the_default_locale
    I18n.default_locale = :es
    I18n.locale = :undefined
    page = Page.first
    assert_equal page.send('name_es'), page.name
  end

  def test_should_find_by_translated_attribute
    page = Page.find_by_name('Name')
    assert_equal page.name, 'Name'
    assert_equal page.body, 'Content'

    I18n.locale = :es
    page = Page.find_by_name('Nombre')
    assert_equal page.name, 'Nombre'
  end

  def test_should_find_with_options_with_default_locale
    pages = Page.find_all_by_name('Name')
    assert pages.kind_of?(Array)
  end

  def test_should_find_with_options_with_locale_set_to_es
    I18n.locale = :es

    pages = Page.find_all_by_name('Nombre')
    assert_equal pages.length, 2

    pages = Page.find_all_by_name('Nombre', :limit => 1)
    assert_equal pages.length, 1

    pages = Page.find_all_by_name('Nombre', :limit => 1, :order => "created_at DESC")
    assert_equal pages.first.body, "Segundo Contenido"

    pages = Page.find_all_by_name('Nombre', :limit => 1, :order => "created_at ASC")
    assert_equal pages.first.body, "Contenido"
  end

  def test_wrong_method_should_raise_nomethod_error
    assert_raise NoMethodError do
      Page.wadus_wadus
    end
  end

end
