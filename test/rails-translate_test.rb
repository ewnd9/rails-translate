# encoding: UTF-8
require 'rubygems'
gem 'minitest' # ensures you're using the gem, and not the built in MT
require 'minitest/autorun'
require 'active_record'

$LOAD_PATH << File.expand_path("#{File.dirname(__FILE__)}/../lib")
require 'rails-translate'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

def setup_db

  silence_stream(STDOUT) do
    ActiveRecord::Schema.define(:version => 1) do
      create_table :pages, :force => true do |t|
        t.string :name_en
        t.string :name_es
        t.string :name_zh_cn
        t.text :body_en
        t.text :body_es
        t.text :body_zh_cn
        t.timestamps
      end
    end
  end

end

class Page < ActiveRecord::Base
  translate :name, 'body'
end

class RailsTranslateTest < MiniTest::Unit::TestCase

  def setup

    setup_db

    Page.create :name_en => "Name",
                :name_es => "Nombre",
                :name_zh_cn => "名称",
                :body_en => "Content",
                :body_es => "Contenido",
                :body_zh_cn => "内容",
                :created_at => Time.now - 60

    Page.create :name_en => "Second Name",
                :name_es => "Nombre",
                :name_zh_cn => "名称",
                :body_en => "Second Content",
                :body_es => "Segundo Contenido",
                :body_zh_cn => "第二内容",
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
    I18n.with_locale(:es) do
      page = Page.first
      assert_equal page.send('name_es'), page.name
    end
  end

  def test_should_get_title_zh_cn_of_the_page
    I18n.with_locale(:'zh-CN') do
      page = Page.first
      assert_equal page.send('name_zh_cn'), page.name
    end
  end

  def test_should_return_title_en_when_undefined_locale
    I18n.with_locale(:undefined) do
      page = Page.first
      assert_equal page.send('name_en'), page.name
    end
  end

  def test_should_return_title_es_because_is_the_default_locale
    I18n.default_locale = :es
    I18n.with_locale(:undefined) do
      page = Page.first
      assert_equal page.send('name_es'), page.name
    end
    I18n.default_locale = :en
  end

  def test_should_return_title_zh_cn_because_is_the_default_locale
    I18n.default_locale = :'zh-CN'
    I18n.with_locale(:undefined) do
      page = Page.first
      assert_equal page.send('name_zh_cn'), page.name
    end
    I18n.default_locale = :en
  end

  def test_should_find_by_translated_attribute
    page = Page.find_by_name('Name')
    assert_equal page.name, 'Name'
    assert_equal 'Content', page.body

    I18n.with_locale(:es) do
      page = Page.find_by_name('Nombre')
      assert_equal 'Nombre', page.name
    end

    I18n.with_locale(:'zh-CN') do
      page = Page.find_by_name('名称')
      assert_equal '名称', page.name
    end
  end

  def test_should_find_with_options_with_default_locale
    pages = Page.find_all_by_name('Name')
    assert pages.kind_of?(Array)
  end

  def test_should_find_with_options_with_locale_set_to_es
    I18n.with_locale(:es) do
      pages = Page.find_all_by_name('Nombre')
      assert_equal 2, pages.length

      pages = Page.find_all_by_name('Nombre', :limit => 1)
      assert_equal 1, pages.length

      pages = Page.find_all_by_name('Nombre', :limit => 1, :order => "created_at DESC")
      assert_equal "Segundo Contenido", pages.first.body

      pages = Page.find_all_by_name('Nombre', :limit => 1, :order => "created_at ASC")
      assert_equal "Contenido", pages.first.body
    end
  end

  def test_should_find_with_options_with_locale_set_to_zh_cn
    I18n.with_locale(:'zh-CN') do
      pages = Page.find_all_by_name('名称')
      assert_equal 2, pages.length

      pages = Page.find_all_by_name('名称', :limit => 1)
      assert_equal 1, pages.length

      pages = Page.find_all_by_name('名称', :limit => 1, :order => "created_at DESC")
      assert_equal "第二内容", pages.first.body

      pages = Page.find_all_by_name('名称', :limit => 1, :order => "created_at ASC")
      assert_equal "内容", pages.first.body
    end
  end

  def test_wrong_method_should_raise_nomethod_error
    assert_raises NoMethodError do
      Page.wadus_wadus
    end
  end

end
