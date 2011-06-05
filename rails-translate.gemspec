Gem::Specification.new do |s|
  s.name = 'rails-translate'
  s.version = '1.0.0'
  s.author = 'Francesc Esplugas'
  s.email = 'contact@francescesplugas.com'
  s.homepage = 'http://github.com/fesplugas/rails-translate'
  s.summary = 'Simplest translation mechanism for models.'

  s.add_dependency('rails', '>= 3.0.0')

  s.files = Dir['lib/**/*']
  s.require_path = 'lib'
end
