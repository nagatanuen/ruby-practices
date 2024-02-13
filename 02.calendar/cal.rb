#!/usr/bin/ruby

require 'optparse'
require 'date'

class MyCalendar
  def initialize
    begin
      setYearAndMonth
    rescue => e
      puts e.message
      exit
    end
  end

  def show
    # 年・月・曜日
    puts "#{@month}月 #{@year}".center(20)
    puts '日 月 火 水 木 金 土'

    # 日にち
    day = 1
    date = Date.new(@year, @month, day)

    # 初週
    row = day.to_s.rjust(2)
    (6 - date.wday).times do
      day += 1
      row += ' '
      row += "#{day.to_s.rjust(2)}"
    end
    puts row.rjust(20)

    # 2週目以降
    while Date.valid_date?(@year, @month, day)
      row = ''

      # 1週(7日)ずつ作成していく
      7.times do
        day += 1

        # 次の日付が有効でなくなったら最終行を出力して終了
        unless Date.valid_date?(@year, @month, day) then
          puts row.ljust(20)
          return
        end
        row += "#{day.to_s.rjust(2)}"
        row += ' '
      end
      puts row.rjust(20)
    end
  end

  private

  def setYearAndMonth
    # 年の有効範囲を1970〜2100に限定する
    year_regex = /\A(19[7-9][0-9]{1}|20[0-9]{2}|2100)\z/
    # 月の有効範囲を1〜12に限定する
    month_regex = /\A([1-9]|1[0-2])\z/

    # 実行時に指定されたオプションを取得
    opt = OptionParser.new
    opt.on('-y YEAR', year_regex, Integer, '表示したい年を1970〜2100の範囲で指定します') { |v| @year = v }
    opt.on('-m MONTH', month_regex, Integer, '表示したい月を1〜12の範囲で指定します') { |v| @month = v }
    opt.parse!(ARGV)

    # 指定がなければ現在年月をセットする
    @year = Time.now.year if @year.nil?
    @month = Time.now.month if @month.nil?
  end
end

cal = MyCalendar.new
cal.show
