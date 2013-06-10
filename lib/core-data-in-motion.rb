Motion::Project::App.setup do |app|
  Dir.glob(File.join(File.dirname(__FILE__), 'cdim/*.rb')).each { |file| app.files.unshift(file) }
  Dir.glob(File.join(File.dirname(__FILE__), 'cdim/*/*.rb')).each { |file| app.files.unshift(file) }

  app.frameworks << 'CoreData'
end
