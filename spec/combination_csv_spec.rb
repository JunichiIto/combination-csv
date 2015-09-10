require 'csv'
require 'spec_helper'

class CombinationCsv
  def self.generate_csv(input_path, output_dir, assigned_number)
    input_arrays = CSV.read(input_path)
    all_combinations = generate_all_combinations(input_arrays, assigned_number)
    all_combinations.each do |combination|
      file_name = combination.map { |k, v| "#{k}#{v.join}" }.join('_') + '.csv'
      output_path = File.join(output_dir, file_name)
      CSV.open(output_path, 'w') do |csv|
        numbers = combination.values.flatten
        write_csv_rows(csv, input_arrays, numbers)
      end
    end
  end

  def self.generate_all_combinations(input_arrays, assigned_number)
    count_by_group = read_count_by_group(input_arrays)
    combination_hash = combination_by_group(count_by_group, assigned_number)
    all_arrays = combination_hash.values
    first = all_arrays.shift
    all_combinations = first.product(*all_arrays)
    names = combination_hash.keys
    all_combinations.map {|combinations| names.zip(combinations).to_h }
  end

  def self.combination_by_group(count_by_group, assigned_number)
    count_by_group.map {|name, count|
      [name, generate_combination(assigned_number, count)]
    }.to_h
  end

  def self.read_count_by_group(input_arrays)
    name_and_numbers = input_arrays.map{|cols|
      /(?<name>[A-Z]+)(?<number>\d+)/ =~ cols.first
      [name, number.to_i]
    }
    groups_by_name = name_and_numbers.each_with_object(Hash.new { |h,k| h[k] = [] }) do |(name, number), hash|
      hash[name] << number
    end
    groups_by_name.map{|name, values| [name, values.max]}.to_h
  end

  def self.write_csv_rows(csv, input_arrays, numbers)
    input_arrays.each_with_index do |input_cols, i|
      csv << input_cols.dup.tap do |output_cols|
        output_cols.each(&:strip!)
        output_cols[1] = numbers[i]
      end
    end
  end

  def self.generate_combination(assigned_number, col_size)
    return [[assigned_number]] if col_size == 1
    assigned_number.downto(0).flat_map do |n|
      child_results = generate_combination(assigned_number - n, col_size - 1)
      child_results.map { |numbers| [n, *numbers] }
    end
  end
end

describe CombinationCsv do
  describe '::generate_csv' do
    let(:input_dir) { File.expand_path('../input', __FILE__) }
    let(:input_path) { File.join(input_dir, 'test3-1.csv') }
    let(:output_dir) { File.expand_path('../output', __FILE__) }

    def output_files
      Dir.glob(File.join(output_dir, '*.csv'))
    end

    before do
      FileUtils.rm(output_files)
    end
    example do
      expect {
        CombinationCsv.generate_csv(input_path, output_dir, 2)
      }.to change { output_files.size }.from(0).to(9)

      output_path = File.join(output_dir, 'A20_B20_C2.csv')
      result = CSV.read(output_path)
      expect(result).to eq([
                               %w(A1 2 test),
                               %w(A2 0 test),
                               %w(B1 2 test),
                               %w(B2 0 test),
                               %w(C1 2 test),
                           ])

      output_path = File.join(output_dir, 'A02_B02_C2.csv')
      result = CSV.read(output_path)
      expect(result).to eq([
                               %w(A1 0 test),
                               %w(A2 2 test),
                               %w(B1 0 test),
                               %w(B2 2 test),
                               %w(C1 2 test),
                           ])
    end
  end

  describe '::generate_all_combinations' do
    let(:input_dir) { File.expand_path('../input', __FILE__) }
    let(:input_path) { File.join(input_dir, 'test3-1.csv') }
    let(:expected) do
      [
          { 'A' => [2, 0], 'B' => [2, 0], 'C' => [2] },
          { 'A' => [2, 0], 'B' => [1, 1], 'C' => [2] },
          { 'A' => [2, 0], 'B' => [0, 2], 'C' => [2] },
          { 'A' => [1, 1], 'B' => [2, 0], 'C' => [2] },
          { 'A' => [1, 1], 'B' => [1, 1], 'C' => [2] },
          { 'A' => [1, 1], 'B' => [0, 2], 'C' => [2] },
          { 'A' => [0, 2], 'B' => [2, 0], 'C' => [2] },
          { 'A' => [0, 2], 'B' => [1, 1], 'C' => [2] },
          { 'A' => [0, 2], 'B' => [0, 2], 'C' => [2] },
      ]
    end
    example do
      input_arrays = CSV.read(input_path)
      result = CombinationCsv.generate_all_combinations(input_arrays, 2)
      expect(result).to eq(expected)
    end

  end

  describe '::combination_by_group' do
    let(:expected) do
      {
          'A' => [[2, 0], [1, 1], [0, 2]],
          'B' => [[2, 0], [1, 1], [0, 2]],
          'C' => [[2]]
      }
    end
    example do
      count_by_group = {'A' => 2, 'B' => 2, 'C' => 1}
      result = CombinationCsv.combination_by_group(count_by_group, 2)
      expect(result).to eq expected
    end
  end

  describe 'read_count_by_group' do
    let(:input_dir) { File.expand_path('../input', __FILE__) }
    let(:input_path) { File.join(input_dir, 'test3-1.csv') }
    example do
      input_arrays = CSV.read(input_path)
      result = CombinationCsv.read_count_by_group(input_arrays)
      expect(result).to eq({'A' => 2, 'B' => 2, 'C' => 1})
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