class XcodegenAT2430 < Formula
  desc "Generate your Xcode project from a spec file and your folder structure"
  homepage "https://github.com/yonaskolb/XcodeGen"
  url "https://github.com/yonaskolb/XcodeGen/archive/refs/tags/2.43.0.tar.gz"
  sha256 "d79a89ea056ccc3cf84b736ee52c7b5184a560e54808e51f418f34d292869d66"
  license "MIT"
  head "https://github.com/yonaskolb/XcodeGen.git", branch: "master"

  depends_on xcode: ["14.0", :build]
  depends_on :macos

  uses_from_macos "swift"

  def install
    system "swift", "build", "--disable-sandbox", "-c", "release"
    
    # 获取构建输出，查找生成的二进制文件位置
    build_output = `swift build -c release --show-bin-path`.strip
    bin.install "#{build_output}/xcodegen"
    pkgshare.install "SettingPresets"
  end

  test do
    (testpath/"xcodegen.yml").write <<~YAML
      name: GeneratedProject
      options:
        bundleIdPrefix: com.project
      targets:
        TestProject:
          type: application
          platform: iOS
          sources: TestProject
    YAML
    (testpath/"TestProject").mkpath
    system bin/"xcodegen", "--spec", testpath/"xcodegen.yml"
    assert_path_exists testpath/"GeneratedProject.xcodeproj"
    assert_path_exists testpath/"GeneratedProject.xcodeproj/project.pbxproj"
    output = (testpath/"GeneratedProject.xcodeproj/project.pbxproj").read
    assert_match "name = TestProject", output
    assert_match "isa = PBXNativeTarget", output
  end
end