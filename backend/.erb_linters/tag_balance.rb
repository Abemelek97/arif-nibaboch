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
          tag = BetterHtml::Tree::Tag.from_node(tag_node)
          tag_name = tag.name&.downcase
          next unless tag_name

          next if VOID_ELEMENTS.include?(tag_name)
          next if tag.self_closing?

          if tag.closing?
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
