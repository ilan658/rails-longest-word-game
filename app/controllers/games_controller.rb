class GamesController < ApplicationController
  def new
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }
    @start_time = Time.now
  end

  def score
    # Récupère les informations depuis les paramètres
    start_time = Time.parse(params[:start_time])
    end_time = Time.now
    @time_taken = end_time - start_time

    @word = params[:word].upcase
    @letters = params[:letters].split

    # Vérifie les différents scénarios
    if !word_in_grid?(@word, @letters)
      @score = 0
      @message = "Sorry, but #{@word} can't be built out of #{@letters.join(', ')}"
    elsif !valid_word?(@word)
      @score = 0
      @message = "Sorry, but #{@word} does not seem to be a valid English word."
    else
      @score = calculate_score(@word, @time_taken)
      @message = "Congratulations! #{@word} is a valid English word!"
    end
  end

  private

  # Vérifie si le mot peut être formé avec les lettres de la grille
  def word_in_grid?(word, grid)
    word.chars.all? { |letter| word.count(letter) <= grid.count(letter) }
  end

  # Vérifie si le mot existe en anglais en utilisant l'API Wagon Dictionary
  def valid_word?(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word.downcase}"
    begin
      response = URI.open(url).read
      json = JSON.parse(response)
      json['found']
    rescue OpenURI::HTTPError
      false
    end
  end

  # Calcule le score basé sur la longueur du mot et le temps pris pour répondre
  def calculate_score(word, time_taken)
    (word.length * 10) - (time_taken * 0.5)
  end
end
