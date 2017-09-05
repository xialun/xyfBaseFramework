Pod::Spec.new do |s|


s.name         = "xyfBaseFramework"
s.version      = "1.0.23"
s.summary      = "xyf基本框架"

s.homepage     = "https://github.com/xialun/xyfBaseFramework.git"

s.license      ='MIT'

s.author       = { "wangshuai" => "1032188750@qq.com" }




s.source       = { :git => "https://github.com/xialun/xyfBaseFramework.git", :tag => "1.0.23" }


s.source_files  = "xyfBaseFramework/**/*.{h,m}"

s.requires_arc = true

s.public_header_files  = "xyfBaseFramework/System/SCBaseObserveDefine.h"

s.platform     = :ios, "7.0"




s.dependency 'AFNetworking', '~> 3.1.0'
s.dependency 'FMDB', '~> 2.7.2'
s.dependency 'RSA', '~> 1.0.0'
pod 'SCNSdataExtensions', '~> 1.0.4'



end