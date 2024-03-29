#!/usr/bin/ruby
# frozen_string_literal: true
class Ls
  CURRENT_PATH = '.'
  MAX_COLUMN = 3

  def initialize(specified_path)
    @path = specified_path || CURRENT_PATH
  end

  def display
    display_without_option
  end

  private

  def files
    dir = Dir.new(@path)
    dir.children.sort
  end

  def display_without_option
    return 'エラー：指定されたディレクトリが存在しません' unless FileTest.directory?(@path)

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

      output = output.strip + "\n"
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

ls = Ls.new(ARGV[0])
output = ls.display
puts output
