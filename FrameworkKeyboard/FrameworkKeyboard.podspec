
Pod::Spec.new do |spec|

  spec.name           = "FrameworkKeyboard"
  spec.version        = "1.0.0"
  spec.summary        = "Brangerbriz custom keyboard."
  spec.description    = "Framework Keyboard "
  spec.homepage       = "https://github.com/jpipearagon/frameworkTest"
  spec.license        = "MIT (example)"
  spec.author         = { "Felipe Aragon" => "faragon@brangerbriz.com" }
  spec.platform       = :ios, "11.0"
  spec.source         = { :git => "https://github.com/jpipearagon/frameworkTest.git", :tag => "#{spec.version}" }
  spec.source_files   = "FrameworkKeyboard/lib/Sources/**/*"
  spec.swift_version  = "5.0"
  spec.resources      = "FrameworkKeyboard/lib/Resources/**/*"
  spec.dependency "Firebase"
  spec.dependency "Firebase/Analytics"

end
