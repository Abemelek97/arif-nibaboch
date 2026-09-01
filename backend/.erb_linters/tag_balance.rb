# frozen_string_literal: true

module ERBLint
  module Linters
    class TagBalance < Linter
      include LinterRegistry

      VOID_ELEMENTS = %w[
        area base br col embed hr img input link meta param source track wbr
        path circle rect polygon line polyline ellipse !doctype
      ].freeze

      def run(processed_source)
        stack = []
        parser = processed_source.parser

        parser.ast.descendants(:tag).each do |tag_node|
          solidus = tag_node.children[0]
          name_node = tag_node.children[1]
          next unless name_node && name_node.type == :tag_name
          tag_name = name_node.children[0].to_s.downcase

          next if VOID_ELEMENTS.include?(tag_name)

          is_closing = solidus && tag_node.loc.source.start_with?("</")
          is_self_closing = solidus && (tag_node.loc.source.end_with?("/>") || tag_node.loc.source.end_with?("/ >"))

          next if is_self_closing

          if is_closing
            if stack.empty?
              add_offense(tag_node.loc, "Unexpected closing tag </#{tag_name}> with no matching opening tag")
            else
              last_node, last_name = stack.pop
              if last_name != tag_name
                add_offense(tag_node.loc, "Mismatched tag: expected </#{last_name}> (opened on line #{last_node.loc.line}), but found </#{tag_name}>")
              end
            end
          else
            stack << [ tag_node, tag_name ]
          end
        end

        stack.each do |tag_node, tag_name|
          add_offense(tag_node.loc, "Unclosed tag <#{tag_name}> (missing closing </#{tag_name}>)")
        end
      end
    end
  end
end
