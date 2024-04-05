#!/usr/bin/ruby
# frozen_string_literal: true

require 'optparse'
class Ls
  CURRENT_PATH = '.'
  MAX_COLUMN = 3

  def initialize(params)
    @option = {}
    opt = OptionParser.new
    opt.on('-a') { @option[:all] = true }
    opt.on('-r') { @option[:reverse] = true }
    opt.parse!(params)
    @path = params[0] || CURRENT_PATH
  end

  def display
    return 'エラー：指定されたディレクトリが存在しません' unless FileTest.directory?(@path)

    display_without_option(file_list)
  end

  private

  def file_list
    files = if @option[:all]
              Dir.glob('*', File::FNM_DOTMATCH, base: @path, sort: true)
            else
              Dir.glob('*', base: @path, sort: true)
            end

    @option[:reverse] ? files.reverse : files
  end

  def display_without_option(files)
    max_row = calc_max_row(files)
    table = Array.new(max_row) { Array.new(MAX_COLUMN) }
    i = 0
    MAX_COLUMN.times do |c|
      max_row.times do |r|
        table[r][c] = files[i]
        i += 1
      end
    end

    output = ''
    table.each do |row|
      row.each do |f|
        output += format("%-#{calc_column_width(files)}s", f)
        output += "\t"
      end

      output = "#{output.strip}\n"
    end
    output
  end

  def calc_max_row(files)
    remainder = files.size % MAX_COLUMN
    if remainder.zero?
      files.size / MAX_COLUMN
    else
      files.size / MAX_COLUMN + 1
    end
  end

  def calc_column_width(files)
    files.max_by(&:length).length
  end
end

ls = Ls.new(ARGV)
output = ls.display
puts output
