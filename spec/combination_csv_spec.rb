require 'spec_helper'

class CombinationCsv
  def self.generate_combination(assigned_number, col_size)
    max = "#{assigned_number}#{'0' * (col_size - 1)}".to_i
    (assigned_number..max).map { |number|
      number.to_s.rjust(3, '0').chars.map(&:to_i) if number.to_s.chars.map(&:to_i).inject(:+) == assigned_number
    }.compact
  end
end

describe CombinationCsv do
  describe '::generate_combination' do
    let(:expected) do
      [
          [6,0,0],
          [5,1,0],
          [5,0,1],
          [4,2,0],
          [4,0,2],
          [4,1,1],
          [3,3,0],
          [3,0,3],
          [3,2,1],
          [3,1,2],
          [2,4,0],
          [2,0,4],
          [2,3,1],
          [2,1,3],
          [2,2,2],
          [1,5,0],
          [1,0,5],
          [1,4,1],
          [1,1,4],
          [1,3,2],
          [1,2,3],
          [0,6,0],
          [0,0,6],
          [0,5,1],
          [0,1,5],
          [0,4,2],
          [0,2,4],
          [0,3,3]
      ]
    end
    example do
      result = CombinationCsv.generate_combination(6, 3)
      expect(result).to contain_exactly(*expected)
    end
  end
end