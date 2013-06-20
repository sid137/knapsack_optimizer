#!/usr/bin/env ruby
require 'pry'
require 'pry-nav'
require 'matrix'

class Matrix
  def []=(i, j, x)
    @rows[i][j] = x
  end
end

class Knapsack
  attr_accessor :capacity, :items, :matrix, :best_value, :decision_string

  def initialize(opts)
    @capacity = opts[:capacity]
    @items    = opts[:items]
    @matrix   = Matrix.build(@capacity+1, @items.count+1) {nil}
  end 

  def optimize
    fill_lookup_matrix
    enumerate_items
  end 

private

  def optimal_value(weight, item_count)
    index = item_count - 1
    return 0 if item_count.zero? || weight.zero?
    return matrix[weight, item_count] unless matrix[weight, item_count].nil?

    current_item_weight = items[index][:weight]
    current_item_value  = items[index][:value]

    no_item  = matrix[weight, item_count-1]
    new_item = current_item_value + matrix[weight-current_item_weight, item_count - 1]

    return no_item if current_item_weight > weight
    return [no_item, new_item].max 
  end 


  def fill_lookup_matrix
    for item_count in 0..items.count
      for weight in 0..capacity
        matrix[weight, item_count] = optimal_value(weight, item_count)
      end
    end

    @best_value = matrix[capacity, items.count]
  end 

  def enumerate_items
    weight_index = capacity
    item_index   = items.count

    while item_index > 0  
      index = item_index - 1
      item_was_changed = matrix[weight_index, item_index] != matrix[weight_index, item_index - 1]

      if item_was_changed
        self.items[index][:selected] = true
        weight_index = weight_index - items[index][:weight]
      end
      item_index = item_index - 1
    end
  end 

  def decision_bitstring
    items.map{|item| item[:selected] ? 1 : 0 }
  end 

  def selected_items
    items.select{|item| item[:selected]}
  end 

  def to_s
    puts "My capacity is #{capacity}"
    puts "My items are #{items}"
    puts
    puts "The optimization matrix is:"
    matrix.to_a.each {|r| puts r.inspect}
    puts 
    puts "The optimal value is: #{best_value}"
    puts items
    puts "The selected items are #{items.select{|i| i[:selected]}.join(', ')}"
    puts "The decision string is: #{decision_bitstring}"
  end 
end


problem = {
  items: [
    {value: 16, weight: 2 }, 
    {value: 19, weight: 3 }, 
    {value: 23, weight: 4 }, 
    {value: 28, weight: 5 }
  ],
  capacity: 7
}

knapsack = Knapsack.new problem
knapsack.optimize
puts knapsack
