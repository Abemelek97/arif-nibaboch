require "tomlrb"

namespace :theme do
  desc "Generate web/Android/iOS theme files from the root theme.toml"
  task :generate do
    backend_root = File.expand_path("../..", __dir__)
    repo_root = File.expand_path("..", backend_root)
    tokens = Tomlrb.load_file(File.join(repo_root, "theme.toml"))

    abort("theme.toml: [dark] is not wired up yet — only [light] is supported.") if tokens.key?("dark")

    colors = tokens.fetch("light")
    header = "GENERATED from theme.toml by `bundle exec rake theme:generate` — do not edit."

    rgba = colors.transform_values { |hex| parse_hex(hex) }

    write_web_theme(repo_root, header, colors)
    write_android_colors(backend_root, header, rgba)
    write_ios_colorsets(backend_root, rgba)

    puts "Generated theme files for web, Android, and iOS from theme.toml"
  end

  def parse_hex(hex)
    h = hex.delete("#").downcase
    h = h.chars.map { |c| c * 2 }.join if h.length == 3
    h = "ff#{h}" if h.length == 6
    abort("theme.toml: invalid hex color \"#{hex}\"") unless h.match?(/\A[0-9a-f]{8}\z/)

    h.to_i(16)
  end

  def write_web_theme(repo_root, header, colors)
    css = +<<~CSS
      /* #{header} */
      @theme {
    CSS
    colors.each { |name, hex| css << "  --color-#{name.tr('_', '-')}: #{hex};\n" }
    css << "}\n"

    path = File.join(repo_root, "backend/app/assets/tailwind/theme.css")
    File.write(path, css)
  end

  def write_android_colors(backend_root, header, rgba)
    xml = +<<~XML
      <?xml version="1.0" encoding="utf-8"?>
      <!-- #{header} -->
      <resources>
    XML
    rgba.each { |name, value| xml << format("    <color name=\"%s\">#%08X</color>\n", name, value) }
    xml << "</resources>\n"

    path = File.join(backend_root, "../android/app/src/main/res/values/colors.xml")
    File.write(path, xml)
  end

  def write_ios_colorsets(backend_root, rgba)
    colors_dir = File.join(backend_root, "../ios/App/Resources/Assets.xcassets/Colors")
    FileUtils.rm_rf(colors_dir)

    rgba.each do |name, value|
      colorset = File.join(colors_dir, "#{name.split('_').map(&:capitalize).join}.colorset")
      write_colorset(colorset, value)
    end

    # Fill the empty template AccentColor slot with the brand primary.
    write_colorset(
      File.join(backend_root, "../ios/App/Resources/Assets.xcassets/AccentColor.colorset"),
      rgba.fetch("primary")
    )
  end

  def write_colorset(path, value)
    alpha = ((value >> 24) & 0xff) / 255.0
    red = ((value >> 16) & 0xff) / 255.0
    green = ((value >> 8) & 0xff) / 255.0
    blue = (value & 0xff) / 255.0

    json = {
      colors: [ {
        color: {
          "color-space": "srgb",
          components: {
            alpha: format("%.3f", alpha),
            blue: format("%.3f", blue),
            green: format("%.3f", green),
            red: format("%.3f", red)
          }
        },
        idiom: "universal"
      } ],
      info: { author: "xcode", version: 1 }
    }

    FileUtils.mkdir_p(path)
    File.write(File.join(path, "Contents.json"), JSON.pretty_generate(json) << "\n")
  end
end
