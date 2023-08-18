#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"

read USERNAME
USERNAME_CHECK=$($PSQL "SELECT name FROM users WHERE name = '$USERNAME'")

if [[ -z $USERNAME_CHECK ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(name, games_played, best_game) VALUES('$USERNAME', 0, 1001)")
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE name = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE name = '$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read USER_GUESS
GUESSES=1
SECRET_NUMBER=$(( ( RANDOM % 1000 )  + 1 ))
echo $SECRET_NUMBER

GAME()
{
  if [[ $USER_GUESS =~ [0-9]*.*[0-9]*[A-Za-z]+[0-9]*.*[0-9]*[A-Za-z]* ]]
  then
    echo "That is not an integer, guess again:"
    read USER_GUESS
    GUESSES=$(($GUESSES+1))
    GAME
  fi

  if [[ $USER_GUESS == $SECRET_NUMBER ]]
  then
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE name='$USERNAME'")+1
    BEST_GAME_SO_FAR=$($PSQL "SELECT best_game FROM users WHERE name='$USERNAME'")
    if (( $GUESSES < $BEST_GAME_SO_FAR ))
    then
      BEST_GAME_SO_FAR=$GUESSES
    fi
    UPDATE_USER=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED, best_game = $BEST_GAME_SO_FAR WHERE name='$USERNAME'")
    echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
  fi

  if [[ $USER_GUESS < $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    GUESSES=$(($GUESSES+1))
    read USER_GUESS
    GAME
  fi

  if [[ $USER_GUESS > $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    GUESSES=$(($GUESSES+1))
    read USER_GUESS
    GAME
  fi
}

GAME
