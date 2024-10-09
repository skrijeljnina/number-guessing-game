#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER_GUESS_GAME() {
  SECRET_NUMBER=$(( 1 + $RANDOM % 1000 ))
  
  echo "Enter your username:"

  read USERNAME
  
  SELECT_USERNAME=$(echo $($PSQL "SELECT username FROM number_guess WHERE username = '$USERNAME'") | sed 's/^ *| *$//g' )

  if [[ -z $SELECT_USERNAME ]]
  then
      INSERT_USERNAME=$($PSQL "INSERT INTO number_guess(username) VALUES('$USERNAME')")

      SELECT_USERNAME=$(echo $($PSQL "SELECT username FROM number_guess WHERE username = '$USERNAME'") | sed 's/^ *| *$//g' )

      echo "Welcome, $SELECT_USERNAME! It looks like this is your first time here."
  else
      SELECT_GAMES_PLAYED=$(echo $($PSQL "SELECT games_played FROM number_guess WHERE username = '$SELECT_USERNAME'") | sed 's/^ *| *$//g')

      SELECT_BEST_GAME=$(echo $($PSQL "SELECT best_game FROM number_guess WHERE username = '$SELECT_USERNAME'") | sed 's/^ *| *$//g')

      echo "Welcome back, $SELECT_USERNAME! You have played $SELECT_GAMES_PLAYED games, and your best game took $SELECT_BEST_GAME guesses."
  fi

  echo "Guess the secret number between 1 and 1000:"

  read GUESSED_NUMBER

  NUMBER_OF_GUESSES=1

  UPDATE_GAMES_PLAYED=$($PSQL "UPDATE number_guess SET games_played = games_played + 1 WHERE username = '$SELECT_USERNAME'")

  until [[ $GUESSED_NUMBER -eq $SECRET_NUMBER ]]
  do
    # check if the number is an integer:
    if [[ $GUESSED_NUMBER =~ ^[0-9]+$ ]]
    then
        if (( GUESSED_NUMBER > SECRET_NUMBER ))
        then
            (( NUMBER_OF_GUESSES++ ))

            echo "It's lower than that, guess again:"

            read GUESSED_NUMBER
        else
            (( NUMBER_OF_GUESSES++ ))

            echo "It's higher than that, guess again:"

            read GUESSED_NUMBER
        fi
    else
        (( NUMBER_OF_GUESSES++ ))

        echo "That is not an integer, guess again:"

        read GUESSED_NUMBER
    fi
  done

  # update best_game
  SELECT_BEST_GAME=$(echo $($PSQL "SELECT best_game FROM number_guess WHERE username = '$SELECT_USERNAME'") | sed 's/^ *| *$//g')

  SELECT_GAMES_PLAYED=$(echo $($PSQL "SELECT games_played FROM number_guess WHERE username = '$SELECT_USERNAME'") | sed 's/^ *| *$//g')

  if [[ $SELECT_GAMES_PLAYED -eq 1 ]]
  then
    UPDATE_BEST_GAME=$($PSQL "UPDATE number_guess SET best_game = $NUMBER_OF_GUESSES WHERE username = '$SELECT_USERNAME'")
  elif [[ $SELECT_BEST_GAME -gt $NUMBER_OF_GUESSES ]]
  then
    UPDATE_BEST_GAME=$($PSQL "UPDATE number_guess SET best_game = $NUMBER_OF_GUESSES WHERE username = '$SELECT_USERNAME'")
  fi

  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
}

NUMBER_GUESS_GAME
