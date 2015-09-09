require 'csv'
require 'spec_helper'

class CombinationCsv
  def self.generate_csv(input_path, output_dir, assigned_number, col_size)
    input_arrays = CSV.read(input_path)
    generate_combination(assigned_number, col_size).each do |numbers|
      output_path = File.join(output_dir, "A1_#{numbers.join}.csv")
      CSV.open(output_path, 'w') do |csv|
        input_arrays.each.with_index do |input_cols, i|
          output_cols = input_cols.dup
          output_cols.each(&:strip!)
          output_cols[1] = numbers[i]
          csv << output_cols
        end
      end
    end
  end

  # ゴリ押し実装なので、もっとスマートなロジックがあるはず
  def self.generate_combination(assigned_number, col_size)
    max = "#{assigned_number}#{'0' * (col_size - 1)}".to_i
    (assigned_number..max).map { |number|
      target = number.to_s.chars.map(&:to_i).inject(:+) == assigned_number
      number.to_s.rjust(3, '0').chars.map(&:to_i) if target
    }.compact
  end
end

describe CombinationCsv do
  describe '::generate_csv' do
    let(:input_dir) { File.expand_path('../input', __FILE__) }
    let(:input_path) { File.join(input_dir, 'test2.csv') }
    let(:output_dir) { File.expand_path('../output', __FILE__) }

    def output_files
      Dir.glob(File.join(output_dir, '*.csv'))
    end

    before do
      FileUtils.rm(output_files)
    end
    example do
      expect {
        CombinationCsv.generate_csv(input_path, output_dir, 6, 3)
      }.to change { output_files.size }.from(0).to(28)

      output_path = File.join(output_dir, 'A1_600.csv')
      result = CSV.read(output_path)
      expect(result).to eq([
                               %w(A1 6 test),
                               %w(A2 0 test),
                               %w(A3 0 test)
                           ])

      output_path = File.join(output_dir, 'A1_510.csv')
      result = CSV.read(output_path)
      expect(result).to eq([
                               %w(A1 5 test),
                               %w(A2 1 test),
                               %w(A3 0 test)
                           ])
    end
  end

  describe '::generate_combination' do
    let(:expected) do
      [
          [6, 0, 0],
          [5, 1, 0],
          [5, 0, 1],
          [4, 2, 0],
          [4, 0, 2],
          [4, 1, 1],
          [3, 3, 0],
          [3, 0, 3],
          [3, 2, 1],
          [3, 1, 2],
          [2, 4, 0],
          [2, 0, 4],
          [2, 3, 1],
          [2, 1, 3],
          [2, 2, 2],
          [1, 5, 0],
          [1, 0, 5],
          [1, 4, 1],
          [1, 1, 4],
          [1, 3, 2],
          [1, 2, 3],
          [0, 6, 0],
          [0, 0, 6],
          [0, 5, 1],
          [0, 1, 5],
          [0, 4, 2],
          [0, 2, 4],
          [0, 3, 3]
      ]
    end
    example do
      result = CombinationCsv.generate_combination(6, 3)
      expect(result).to contain_exactly(*expected)
    end
  end
end