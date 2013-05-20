Motion::Project::App.setup do |app|
  Dir.glob(File.join(File.dirname(__FILE__), 'cdim/*.rb')).each do |file|
    app.files.unshift(file)
  end

  app.frameworks << 'CoreData'
end
