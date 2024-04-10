#!/usr/bin/ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

class Ls
  CURRENT_PATH = '.'
  MAX_COLUMN = 3
  FILE_TYPE = {
    '01' => 'p',
    '02' => 'c',
    '04' => 'd',
    '06' => 'b',
    '10' => '-',
    '12' => 'l',
    '14' => 's'
  }.freeze
  PERMISSION = {
    '0' => '---',
    '1' => '--x',
    '2' => '-w-',
    '3' => '-wx',
    '4' => 'r--',
    '5' => 'r-x',
    '6' => 'rw-',
    '7' => 'rwx'
  }.freeze

  def initialize(params)
    @option = {}
    opt = OptionParser.new
    opt.on('-a') { @option[:all] = true }
    opt.on('-r') { @option[:reverse] = true }
    opt.on('-l') { @option[:list] = true }
    opt.parse!(params)
    @path = params[0] || CURRENT_PATH
  end

  def display
    return 'エラー：指定されたディレクトリが存在しません' unless FileTest.directory?(@path)

    if @option[:list]
      display_with_list_option(file_list)
    else
      display_without_list_option(file_list)
    end
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

  def display_with_list_option(files)
    lines = create_lines(files)
    format_lines(lines)
  end

  def create_lines(files)
    files.map do |file|
      line = {}
      fs = File.lstat("#{@path}/#{file}")

      line[:permission] = create_permission(fs)
      line[:nlink] = fs.nlink.to_s
      line[:uname] = Etc.getpwuid(fs.uid).name
      line[:gname] = Etc.getgrgid(fs.gid).name
      line[:size] = fs.size.to_s
      line[:updated_at] = fs.mtime.strftime('%b %e %H:%M')
      line[:file] = fs.symlink? ? "#{file} -> #{File.readlink("#{@path}/#{file}")}" : file

      line
    end
  end

  def format_lines(lines)
    nlink_width = calc_column_width(lines, column: :nlink)
    uname_width = calc_column_width(lines, column: :uname)
    gname_width = calc_column_width(lines, column: :gname)
    size_width = calc_column_width(lines, column: :size)
    updated_at_width = calc_column_width(lines, column: :updated_at)
    lines.map do |l|
      "#{l[:permission]} #{l[:nlink].rjust(nlink_width)} "\
      "#{l[:uname].ljust(uname_width)} #{l[:gname].ljust(gname_width)} "\
      "#{l[:size].rjust(size_width)} #{l[:updated_at].ljust(updated_at_width)} #{l[:file]}"
    end
  end

  def create_permission(fs)
    mode = fs.mode.to_s(8).rjust(6, '0')
    type = FILE_TYPE[mode.slice(0..1)]
    owner = PERMISSION[mode.slice(3)].dup
    group = PERMISSION[mode.slice(4)].dup
    other = PERMISSION[mode.slice(5)].dup

    case mode.slice(2)
    when '1'
      other[2] = other[2] == 'x' ? 't' : 'T'
    when '2'
      group[2] = group[2] == 'x' ? 's' : 'S'
    when '4'
      owner[2] = owner[2] == 'x' ? 's' : 'S'
    end

    "#{type}#{owner}#{group}#{other}"
  end

  def display_without_list_option(files)
    max_row = calc_max_row(files)
    table = Array.new(max_row) { Array.new(MAX_COLUMN) }
    i = 0
    MAX_COLUMN.times do |c|
      max_row.times do |r|
        table[r][c] = files[i]
        i += 1
      end
    end

    table.map do |row|
      row.each do |f|
        output += format("%-#{calc_column_width(files)}s", f)
        output += "\t"
      end
      "#{output.strip}\n"
    end
  end

  def calc_max_row(files)
    remainder = files.size % MAX_COLUMN
    if remainder.zero?
      files.size / MAX_COLUMN
    else
      files.size / MAX_COLUMN + 1
    end
  end

  def calc_column_width(list, column: nil)
    if column
      target = list.max_by { |l| l[column].length }
      target[column].length
    else
      list.max_by(&:length).length
    end
  end
end

ls = Ls.new(ARGV)
output = ls.display
puts output
