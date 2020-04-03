
Pod::Spec.new do |spec|

  spec.name           = "FrameworkKeyboard"
  spec.version        = "1.0.0"
  spec.summary        = "Brangerbriz custom keyboard."
  spec.description    = "Framework Keyboard "
  spec.homepage       = "https://github.com/jpipearagon/frameworkTest"
  spec.license        = "MIT"
  spec.author         = { "Felipe Aragon" => "faragon@brangerbriz.com" }
  spec.platform       = :ios, "11.0"
  spec.source         = { :git => "https://github.com/jpipearagon/frameworkTest.git", :tag => "#{spec.version}" }
  spec.source_files   = "FrameworkKeyboard/**/*.{h,m,swift}"
  spec.swift_version  = "5.0"
  spec.resources      = "FrameworkKeyboard/**/*.{lproj,storyboard,xcdatamodeld,xib,xcassets,json,png}"
  spec.static_framework = true
  spec.frameworks     = "Firebase", 'CoreData', 'SystemConfiguration'
  spec.libraries      = 'sqlite3', 'z'
  spec.dependency "Firebase/Analytics"

end
