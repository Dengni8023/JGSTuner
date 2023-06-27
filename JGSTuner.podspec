#
#  Be sure to run `pod spec lint JGSTuner.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  # CocoaPods - Podspec文件配置讲解: https://www.jianshu.com/p/743bfd8f1d72
  def self.smart_host
    # 网络防火墙问题，优先使用 Gitee
    # "github.com"
    "gitee.com"
  end
  def self.smart_version
    # tag = `git describe --abbrev=0 --tags 2>/dev/null`.strip
    tag = `git describe --abbrev=0 --tags`
    if $?.success? then tag else "0.0.1" end
  end
  def self.version_date
    date = `git log -1 --pretty=format:%ad --date=format:%Y%m%d #{smart_version}`
    date
  end
  
  spec.name         = "JGSTuner" # (必填) 库的名字
  spec.version      = smart_version # (必填) 库的版本号
  spec.summary      = "JGSTuner functional component library." # (必填) 库描述
  
  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  spec.description  = <<-DESC
  JGSTuner 通用调音器工具 (An iOS Instruments Tuner.)
                   DESC

  spec.homepage     = "https://#{smart_host}/dengni8023/JGSTuner"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See https://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  spec.license      = "MIT (LICENSE.md)"
  # spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  spec.author             = {
    "Dengni8023" => "945835664@qq.com",
    "MeiJiGao" => "945835664@qq.com",
   }
  # Or just: spec.author    = "Dengni8023"
  # spec.authors            = { "Dengni8023" => "945835664@qq.com" }
  # spec.social_media_url   = "https://twitter.com/Dengni8023"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  #  (选填) 支持的Swift版本。CocoaPods会将“4”视为“4.0”，而不是“4.1”或“4.2”。
  # spec.swift_version = "5.6"
  # 5.6: Xcode 13.3
  # 5.7: Xcode 14.2
  # 5.8: Xcode 14.3
  spec.swift_versions = ["5.6", "5.7", "5.8"]

  #  (选填) 支持的CocoaPods版本
  spec.cocoapods_version = '>= 1.10'
  
  spec.platform     = :ios, "13.0" # 指定最低支持 iOS 版本

  #  When using multiple platforms
  # spec.ios.deployment_target = "5.0"
  # spec.osx.deployment_target = "10.7"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  spec.source = { :git => "https://#{smart_host}/dengni8023/JGSourceBase.git", :tag => "#{spec.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  spec.source_files  = [
    "JGSTuner/*.{h,m,swift}",
    "JGSTuner/MicrophoneDetector/*.{h,m,swift}",
    "JGSTuner/PCMBufferUtils/*.{h,m,swift}",
    "JGSTuner/PitchDetector/*.{h,m,swift}",
  ]
  spec.project_header_files = [
  ]
  spec.public_header_files = [
    "JGSTuner/*.h",
    "JGSTuner/MicrophoneDetector/*.h",
    "JGSTuner/PCMBufferUtils/*.h",
    "JGSTuner/PitchDetector/*.h",
  ]
  
  # spec.public_header_files = "Classes/**/*.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # spec.resource  = "icon.png"
  # spec.resources = "Resources/*.png"

  # spec.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # spec.framework  = "SomeFramework"
  # spec.frameworks = "SomeFramework", "AnotherFramework"

  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # (选填) 是否使用静态库
  # 如果 Podfile 指明了 use_frameworks! 命令，是否以静态framework的形式构建
  # use_frameworks! 默认构建动态链接库
  # use_frameworks! :linkage => :dynamic # 使用动态链接库
  # use_frameworks! :linkage => :static # 使用静态链接库
  # 设置为 true，在Podfile使用 use_frameworks!指定动态链接库时，仍旧打包静态库
  # 由于存在bundle资源使用，在动态链接库中，无法直接使用到framework内的bundle资源
  spec.static_framework = true
  # requires_arc允许指定哪些source_files使用ARC。可以设置为true表示所有source_files使用ARC。
  # 不使用ARC的文件会有-fno-objc-arc编译标志。
  spec.requires_arc = true
  
  spec.pod_target_xcconfig = {
    "PRODUCT_BUNDLE_IDENTIFIER" => "com.meijigao.#{spec.name}",
    "MARKETING_VERSION" => "#{spec.version}",
    "CURRENT_PROJECT_VERSION" => "#{spec.version}",
    'GENERATE_INFOPLIST_FILE' => 'NO',
    # 'DEFINES_MODULE' => 'YES',
  }
  
  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"

  spec.dependency "JGSourceBase/Base", ">= 1.4.0"
end
