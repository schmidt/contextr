require "rubygems"
require "contextr"

module Cop
  # Fig. 3
  class Node
    attr_accessor :first, :op, :second

    def initialize(values = {})
      values.each do |key, value|
        self.send("#{key}=", value)
      end
    end
  end
  class Leaf
    attr_accessor :value
    def initialize(value)
      self.value = value
    end
  end

  # Fig. 4
  class ExampleTree
    def initialize
      @tree = Node.new(
        :first => Node.new(
          :first => Node.new(
            :first => Leaf.new(1),
            :op => :+,
            :second => Leaf.new(2)),
          :op => :*,
          :second => Node.new(
            :first => Leaf.new(3),
            :op => :-,
            :second => Leaf.new(4))),
        :op => :/,
        :second => Leaf.new(5))
    end
  end

  # Fig. 5
  class Node
    def evaluate
      # first.evaluate.send(op, second.evaluate.to_f)
      first.evaluate.send(op, second.evaluate)
    end
    def print_prefix
      "(#{op}#{first.print_prefix}#{second.print_prefix})"
    end
    def print_infix
      "(#{first.print_infix}#{op}#{second.print_infix})"
    end
    def print_postfix
      "(#{first.print_postfix}#{second.print_postfix}#{op})"
    end
  end

  class Leaf
    def evaluate
      value
    end
    def print_infix
      value.to_s
    end
    def print_postfix
      value.to_s
    end
    def print_prefix
      value.to_s
    end
  end

  # Fig. 7
  class ExampleTree
    def show
      puts @tree.print_infix
      puts @tree.print_prefix
      puts @tree.print_postfix
      puts @tree.evaluate
    end
  end
  ExampleTree.new.show

  # Fig. 8
  class Node
    def accept(visitor)
      visitor.visit(self)
    end
  end
  class Leaf 
    def accept(visitor)
      visitor.visit(self)
    end
  end

  # Fig. 9
  class Visitor
    def visit(node_or_leaf)
      case node_or_leaf
      when Node
        visit_node(node_or_leaf)
      when Leaf
        visit_leaf(node_or_leaf)
      end
    end
  end
  class PrintPrefixVisitor < Visitor
    def visit_leaf(leaf)
      leaf.value.to_s
    end
    def visit_node(node)
      "(#{node.op}#{node.first.accept(self)}#{node.second.accept(self)})"
    end
  end
  class PrintInfixVisitor < Visitor
    def visit_leaf(leaf)
      leaf.value.to_s
    end
    def visit_node(node)
      "(#{node.first.accept(self)}#{node.op}#{node.second.accept(self)})"
    end
  end
  class PrintPostfixVisitor < Visitor
    def visit_leaf(leaf)
      leaf.value.to_s
    end
    def visit_node(node)
      "(#{node.first.accept(self)}#{node.second.accept(self)}#{node.op})"
    end
  end
  class EvaluateVisitor < Visitor
    def visit_leaf(leaf)
      leaf.value
    end
    def visit_node(node)
      # node.first.accept(self).send(node.op, node.second.accept(self).to_f)
      node.first.accept(self).send(node.op, node.second.accept(self))
    end
  end

  # Fig. 10
  class ExampleTree
    def show_visitor
      puts @tree.accept(PrintInfixVisitor.new)
      puts @tree.accept(PrintPrefixVisitor.new)
      puts @tree.accept(PrintPostfixVisitor.new)
      puts @tree.accept(EvaluateVisitor.new)
    end
  end
  ExampleTree.new.show_visitor

  # Fig. 11
  class Leaf
    in_layer :print_prefix do
      def to_s
        yield(:receiver).value.to_s
      end
    end
    in_layer :print_infix do
      def to_s
        yield(:receiver).value.to_s
      end
    end
    in_layer :print_postfix do
      def to_s
        yield(:receiver).value.to_s
      end
    end
    in_layer :evaluate do
      def evaluate
        yield(:receiver).value
      end
    end
  end
  class Node
    in_layer :print_prefix do
      def to_s
        node = yield(:receiver)
        "(#{node.op}#{node.first}#{node.second})"
      end
    end
    in_layer :print_infix do
      def to_s
        node = yield(:receiver)
        "(#{node.first}#{node.op}#{node.second})"
      end
    end
    in_layer :print_postfix do
      def to_s
        node = yield(:receiver)
        "(#{node.first}#{node.second}#{node.op})"
      end
    end
    in_layer :evaluate do
      def evaluate
        node = yield(:receiver)
        # node.first.evaluate.send(node.op, node.second.evaluate.to_f)
        node.first.evaluate.send(node.op, node.second.evaluate)
      end
    end
  end

  # Fig. 12
  class ExampleTree
    def show_layers
      ContextR::with_layer(:print_infix) { puts @tree }
      ContextR::with_layer(:print_prefix) { puts @tree }
      ContextR::with_layer(:print_postfix) { puts @tree }
      ContextR::with_layer(:evaluate) { puts @tree.evaluate }
    end
  end
  ExampleTree.new.show_layers
end
