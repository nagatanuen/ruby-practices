#!/usr/bin/ruby

require 'optparse'
require 'date'

class MyCalendar
  def initialize
    set_year_and_month
  end

  def show
    # 年・月・曜日
    puts "#{@month}月 #{@year}".center(20)
    puts "\e[31m日\e[m 月 火 水 木 金 \e[34m土\e[m"

    # その月の最終日
    last_date = Date.new(@year, @month, -1)
    (1..last_date.day).each do |day|
      date = Date.new(@year, @month, day)

      # 初日の出力位置までスペースで埋める
      print '   ' * date.wday if day == 1

      case date.wday
      when 0 then # 日曜日は赤色で出力
        printf("\e[%dm%2d\e[m ", 31, day)
      when 6 then # 土曜日は青色で改行して出力
        printf("\e[%dm%2d\e[m\n", 34, day)
      else # 月〜金
        printf("%2d ", day)
      end

      # 月の最終日なら改行する(土曜日なら改行済みなのでやらない)
      puts if day == last_date.day && date.wday != 6
    end
  end

  private

  def set_year_and_month
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
