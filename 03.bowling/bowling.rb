#!/usr/bin/ruby
# frozen_string_literal: true

class MyBowling
  def initialize(text)
    @frames = create_frames(text)
  end

  def result
    total_score = 0
    @frames.each_with_index do |frame, i|
      total_score += frame.sum
      break if i == 9
      total_score += calc_strike_bonus(i) if strike?(frame)
      total_score += calc_spare_bonus(i) if spare?(frame)
    end
    total_score
  end

  private

  def strike?(frame)
    frame[0] == 10
  end

  def spare?(frame)
    !strike?(frame) && frame.sum == 10
  end

  def calc_strike_bonus(index)
    bonus = 0
    next_frame = @frames[index + 1]
    after_next_frame = @frames[index + 2]
    if strike?(next_frame)
      bonus += 10
      # 9フレーム目だけ10フレーム目の2投目を加算する
      bonus += index < 8 ? after_next_frame[0] : next_frame[1]
    else
      bonus += next_frame[0..1].sum
    end
    bonus
  end

  def calc_spare_bonus(index)
    @frames[index + 1][0]
  end

  def create_frames(text)
    text_array = text.split(',')
    scores = text_array.map { |s| s == 'X' ? 10 : s.to_i }
    frames = []
    10.times do |i|
      first = scores.shift
      if i < 9
        second = first == 10 ? 0 : scores.shift
        frames[i] = [first, second]
      else
        second = scores.shift
        third = first + second >= 10 ? scores.shift : 0
        frames[i] = [first, second, third]
      end
    end
    frames
  end
end

bowling = MyBowling.new(ARGV[0])
puts bowling.result
