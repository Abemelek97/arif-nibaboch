#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ruby -e '
  theme_files = %w[
    backend/app/assets/tailwind/theme.css
    android/app/src/main/res/values/colors.xml
    ios/App/Resources/Assets.xcassets/Colors
    ios/App/Resources/Assets.xcassets/AccentColor.colorset
  ]

  icon_files = []
  if File.exist?("ios/App/Resources/Assets.xcassets/Icons/Contents.json")
    icon_files << "ios/App/Resources/Assets.xcassets/Icons/Contents.json"
  end

  icons = Dir["icons/*.svg"].map { |f| File.basename(f, ".svg").tr("-", "_") }.sort
  icons.each do |name|
    icon_files << "backend/app/views/shared/icons/_#{name}.html.erb"
    icon_files << "android/app/src/main/res/drawable/ic_#{name}.xml"

    pascal_name = name.split("_").map(&:capitalize).join
    icon_files << "ios/App/Resources/Assets.xcassets/Icons/#{pascal_name}.imageset"
  end

  solid_bases = icons.grep(/_solid\z/).map { |i| i.sub(/_solid\z/, "") } & icons
  solid_bases.each do |base|
    icon_files << "android/app/src/main/res/drawable/ic_tab_#{base}.xml"
  end

  # Also capture deleted generated files tracked by git
  deleted_tracked = `git diff --name-only --diff-filter=D 2>/dev/null`.lines.map(&:strip)
  deleted_generated = deleted_tracked.select do |path|
    path.start_with?("backend/app/views/shared/icons/", "ios/App/Resources/Assets.xcassets/Icons/") ||
      (path.start_with?("android/app/src/main/res/drawable/ic_") && !path.include?("launcher") && !path.include?("splash"))
  end

  staged_targets = (theme_files + icon_files + deleted_generated).uniq.select do |path|
    File.exist?(path) || system("git", "ls-files", "--error-unmatch", path, out: File::NULL, err: File::NULL)
  end

  exec("git", "add", *staged_targets) unless staged_targets.empty?
'
