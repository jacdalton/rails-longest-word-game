require 'open-uri'
require 'json'

class GamesController < ApplicationController
  ALPHABET = ("A".."Z").to_a

  def new
    @letters = []
    10.times { @letters << ALPHABET.sample }
  end

  def get_word_hash(word)
    # gets hash from JSON data from Wagon Dict API
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    JSON.parse(open(url).read)
  end

  def check_if_valid_word(word)
    # check to see if the "found" key is true from the Wagon Dict API
    # return true or false
    word_hash = get_word_hash(word)
    word_hash["found"]
  end

  def count_frequency
    # take a string and count frequencies of each letter
    # return the hash of letters with their frequencies
    @freq_hash = {}
    params[:guess].split("").each do |letter|
      @freq_hash[letter] ? @freq_hash[letter] += 1 : @freq_hash[letter] = 1
    end
    @freq_hash
  end

  def grid_frequency
    @grid_hash = {}
    params[:grid].split(" ").each do |letter|
      @grid_hash[letter] ? @grid_hash[letter] += 1 : @grid_hash[letter] = 1
    end
    @grid_hash
  end

  def check_in_grid(grid, word)
    # check to see if the word can be made using letters available in grid
    letter_freq = count_frequency
    l_keys = letter_freq.keys.map do |key|
      key.upcase
    end
    grid_freq = grid_frequency
    grid_freq.values_at(*l_keys).include?(nil) ? false : (letter_freq.values - grid_freq.values_at(*l_keys)).empty?
  end

  def get_base_score(is_in_grid, is_valid_word, word_length, grid_length)
    # determine base score
    # if the word is valid, its length matches the grid length, and the word is within the grid
    #   double the score
    # if the word is valid & within the grid
    #   the score is the word length
    # otherwise the score should be 0
    if is_in_grid && is_valid_word
      grid_length == word_length ? word_length * 2 : word_length
    else
      0
    end
  end

  def get_final_score(is_in_grid, is_valid_word, word_length, grid_length)
    base_score = get_base_score(is_in_grid, is_valid_word, word_length, grid_length)
  end

  def get_message(grid, word, is_in_grid, is_valid_word)
    if is_in_grid && is_valid_word
      "well done"
    elsif is_in_grid == false
      "#{word} not in the grid"
    elsif is_valid_word == false
      "#{word} not an english word"
    else
      "I don't know what went wrong!"
    end
  end

  def score
    word_in_grid = check_in_grid(params[:grid], params[:guess])
    word_valid = check_if_valid_word(params[:guess])
    @results = {
      score: get_final_score(word_in_grid, word_valid, params[:guess].length, params[:grid].length),
      message: get_message(params[:grid], params[:guess], word_in_grid, word_valid)
    }
  end
end
