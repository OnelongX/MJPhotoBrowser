Pod::Spec.new do |s|

  s.name         = "MJPhotoBrowser"
  s.version      = "1.0.4"
  s.summary      = "The easiest lightest way to use PhotoBrowser, enhanced by Sunnyyoung."
  s.homepage     = "https://github.com/OnelongX/MJPhotoBrowser"
  s.license      = "MIT"

  s.authors      = { 'onelong' => 'https://github.com/OnelongX/MJPhotoBrowser' }

  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/OnelongX/MJPhotoBrowser.git", :tag => s.version }
  s.source_files = "MJPhotoBrowser/MJPhotoBrowser/*.{h,m}"
  s.resource     = "MJPhotoBrowser/MJPhotoBrowser/*.bundle"
  s.requires_arc = true
  s.dependency 'SDWebImage'
  s.dependency 'SVProgressHUD'
  s.dependency 'YLGIFImage'

end
