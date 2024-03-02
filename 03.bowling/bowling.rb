#!/usr/bin/ruby
# frozen_string_literal: true

class MyBowling
  def initialize(text)
    create_frames(text)
  end

  # スコア計算結果を返す
  def result
    total_score = 0
    @frames.each_with_index do |frame, i|
      total_score += frame.sum

      # 以降の処理は10フレーム目はやらない
      break if i == 9

      # ストライクまたはスペアのボーナスを加算する
      total_score += get_strike_bonus(i) if strike?(frame)
      total_score += get_spare_bonus(i) if spare?(frame)

      # puts "#{i}: #{@frames[i]}: #{total_score}"
    end
    puts total_score
  end

  private

  # ストライクかどうかを返す
  def strike?(frame)
    frame[0] == 10
  end

  # スペアかどうかを返す
  def spare?(frame)
    !strike?(frame) && frame.sum == 10
  end

  # ストライクのボーナス点を返す
  def get_strike_bonus(index)
    # 次のフレームもストライクの場合は、次の次のフレームの1投目のスコアも加算する
    bonus = 0
    if @frames[index + 1][0] == 10
      bonus += 10
      # 9フレーム目だけ10フレーム目の2投目を加算する
      bonus += index < 8 ? @frames[index + 2][0] : @frames[index + 1][1]
    else
      bonus += @frames[index + 1][0] + @frames[index + 1][1]
    end
    bonus
  end

  # スペアのボーナス点を返す
  def get_spare_bonus(index)
    @frames[index + 1][0]
  end

  # 引数をパースして1投ごとの結果を得る
  def create_frames(text)
    scores = text.split(',')
    scores.map! { |x| x == 'X' ? 10 : x.to_i }
    # 1投ごとの結果をフレームにセットする
    @frames = []
    10.times do |i|
      second = third = 0
      first = scores.shift
      if i < 9
        # 1〜9フレーム
        second = scores.shift if first != 10
        @frames[i] = [first, second]
      else
        # 10フレーム
        second = scores.shift
        # 1投目がストライクもしくは2投目がスペアだった場合、3投目が投げられる
        third = scores.shift if first == 10 || (first + second) >= 10
        @frames[i] = [first, second, third]
      end
    end
  end
end

bowling = MyBowling.new(ARGV[0])
bowling.result
