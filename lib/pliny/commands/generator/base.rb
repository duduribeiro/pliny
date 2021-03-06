require 'active_support/inflector'
require 'ostruct'
require 'erb'
require 'fileutils'
require 'pliny'

module Pliny::Commands
  class Generator
    class Base
      attr_reader :name, :stream, :options

      def initialize(name, options = {}, stream = $stdout)
        @name = name
        @options = options
        @stream = stream
      end

      def singular_class_name
        name.tr('-', '_').singularize.camelize
      end

      def plural_class_name
        name.tr('-', '_').pluralize.camelize
      end

      def field_name
        name.tableize.singularize
      end

      def pluralized_file_name
        name.tableize
      end

      def table_name
        name.tableize.tr('/', '_')
      end

      def display(msg)
        stream.puts msg
      end

      def render_template(template_file, vars = {})
        template_path = File.dirname(__FILE__) + "/../../templates/#{template_file}"
        template = ERB.new(File.read(template_path), 0, '>')
        context = OpenStruct.new(vars)
        template.result(context.instance_eval { binding })
      end

      def write_template(template_file, destination_path, vars = {})
        write_file(destination_path) do
          render_template(template_file, vars)
        end
      end

      def write_file(destination_path)
        FileUtils.mkdir_p(File.dirname(destination_path))
        File.open(destination_path, 'w') do |f|
          f.puts yield
        end
      end
    end
  end
end
