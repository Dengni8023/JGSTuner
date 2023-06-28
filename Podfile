source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'
# source 'https://github.com/cocoapods/specs.git'
# source 'https://cdn.cocoapods.org/'

# 私有库B依赖了模块A，同时在主工程里 添加A到 development pod，cocoapods 重复生成相同库的uuid
# pod install 警告信息 [!] [Xcodeproj] Generated duplicate UUIDs
install! 'cocoapods', :deterministic_uuids => false

# 源码测试请屏蔽此选项，否则源码库内部调用出现的警告将不会提示
# inhibit_all_warnings!

# use_frameworks! 要求生成的是 .framework 而不是 .a
# use_frameworks! # 使用默认，动态链接
#use_frameworks! :linkage => :dynamic # 使用动态链接
 use_frameworks! :linkage => :static # 使用静态链接

# 将 pods 转为 Modular，因为 Modular 是可以直接在 Swift中 import ，所以不需要再经过 bridging-header 的桥接。
# 但是开启 use_modular_headers! 之后，会使用更严格的 header 搜索路径，开启后 pod 会启用更严格的搜索路径和生成模块映射
# 历史项目可能会出现重复引用等问题，因为在一些老项目里 CocoaPods 是利用Header Search Paths 来完成引入编译
# 当然使用 use_modular_headers!可以提高加载性能和减少体积。
use_modular_headers!

# workspace
workspace "JGSTuner"

# platform
platform :ios, 13.0

abstract_target "JGSTuner" do

  # JGSourceBase
  pod 'JGSourceBase/Category', :git => 'https://gitee.com/dengni8023/JGSourceBase', :commit => '2651b42dd7c4656a7dfbedd0b5df8c7fc8d40a8f' #'~> 1.2.2'
  
  # JGSTuner
  target "JGSTuner" do
    # project
    project "JGSTuner.xcodeproj"
  end

  # JGSTunerDemo
  target "JGSTunerAPP" do

    # JGSTuner
    pod 'JGSTuner', :path => "./"
    # pod 'JGSTuner', :podspec => "./JGSTuner.podspec"
    
    # project
    project "JGSTuner.xcodeproj"
  end

  # JGSTunerDemo
  target "JGSTunerDemo" do
    # project
    project "JGSTuner.xcodeproj"
  end
end

# Hooks: post_install 在生成的Xcode project写入硬盘前做最后的改动
post_install do |installer|
  puts ""
  puts "##### post_install start #####"
  
  # BuildIndependentTargetsInParallel 并发构建
  installer.pods_project.root_object.attributes['BuildIndependentTargetsInParallel'] = "YES"
  
  installer.pods_project.build_configurations.each do |config|
    # STRIP
    config.build_settings['DEAD_CODE_STRIPPING'] = "YES"
  end
  
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # 设置Pods最低版本
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 13.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = 13.0
      end
      # 编译架构
      config.build_settings['ARCHS'] = "$(ARCHS_STANDARD)"
      # 解决最新Mac系统编模拟器译报错：
      # building for iOS Simulator-x86_64 but attempting to link with file built for iOS Simulator-arm64
      # config.build_settings['ONLY_ACTIVE_ARCH'] = false
      # Code Sign: Xcode 14适配
      config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
      config.build_settings['CODE_SIGN_IDENTITY'] = ""
      config.build_settings['CODE_SIGN_IDENTITY[sdk=appletvos*]'] = ""
      config.build_settings['CODE_SIGN_IDENTITY[sdk=iphoneos*]'] = ""
      config.build_settings['CODE_SIGN_IDENTITY[sdk=watchos*]'] = ""
      config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
      config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
      # STRIP
      # config.build_settings['COPY_PHASE_STRIP'] = "YES"
      # config.build_settings['STRIP_INSTALLED_PRODUCT'] = "YES"
      # config.build_settings['STRIP_STYLE'] = "all"
      # config.build_settings['STRIP_SWIFT_SYMBOLS'] = "YES"
      config.build_settings['DEAD_CODE_STRIPPING'] = "YES"
    end
  end
  
  puts "##### post_install end #####"
  puts ""
end
