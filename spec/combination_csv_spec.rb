require 'csv'
require 'spec_helper'

class CombinationCsv
  def self.generate_csv(input_path, output_dir, assigned_number, col_size)
    input_arrays = CSV.read(input_path)
    generate_combination(assigned_number, col_size).each do |numbers|
      output_path = File.join(output_dir, "A1_#{numbers.join}.csv")
      CSV.open(output_path, 'w') do |csv|
        input_arrays.each_with_index do |input_cols, i|
          csv << input_cols.dup.tap do |output_cols|
            output_cols.each(&:strip!)
            output_cols[1] = numbers[i]
          end
        end
      end
    end
  end

  def self.generate_combination(assigned_number, col_size)
    return [assigned_number] if col_size == 1
    assigned_number.downto(0).flat_map do |n|
      child_results = generate_combination(assigned_number - n, col_size - 1)
      child_results.map { |numbers| [n, *numbers] }
    end
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

    context 'assigned_number is 10' do
      let(:expected) do
        [
            [10, 0],
            [9, 1],
            [8, 2],
            [7, 3],
            [6, 4],
            [5, 5],
            [4, 6],
            [3, 7],
            [2, 8],
            [1, 9],
            [0, 10]
        ]
      end
      example do
        result = CombinationCsv.generate_combination(10, 2)
        expect(result).to contain_exactly(*expected)
      end
    end

    context 'col_size is 4' do
      let(:expected) do
        [
            [2, 0, 0, 0],
            [1, 1, 0, 0],
            [1, 0, 1, 0],
            [1, 0, 0, 1],
            [0, 2, 0, 0],
            [0, 1, 1, 0],
            [0, 1, 0, 1],
            [0, 0, 2, 0],
            [0, 0, 1, 1],
            [0, 0, 0, 2],
        ]
      end
      example do
        result = CombinationCsv.generate_combination(2, 4)
        expect(result).to contain_exactly(*expected)
      end
    end
  end
end