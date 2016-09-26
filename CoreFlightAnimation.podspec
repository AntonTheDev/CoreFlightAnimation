Pod::Spec.new do |s|
  s.name         = "CoreFlightAnimation"
  s.version      = "0.9.2"
  s.summary      = "Natural Animation Enhancements on Top of Core Animation"
  s.homepage     = "https://github.com/AntonTheDev/CoreFlightAnimation"
  s.license      = 'MIT'
  s.author       = { "Anton Doudarev" => "antonthedev@gmail.com" }
  s.source       = { :git => 'https://github.com/AntonTheDev/CoreFlightAnimation.git', :branch => 'dev' }
  

  s.platform     = :ios, "8.0"
  s.platform     = :tvos, "9.0"

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'

  s.source_files = "Source/*.swift"
end
