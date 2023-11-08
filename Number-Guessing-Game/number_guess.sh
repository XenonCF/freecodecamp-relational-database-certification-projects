#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
mystery_number=$(( $RANDOM % 1000 + 1 ))

echo "Enter your username:"
read username

get_user=$($PSQL "select games_played, best_game from users where user_name = '$username'")
games_played=""
best_game=""
if [[ -z "$get_user" ]]; then
  new_user=$($PSQL "insert into users(user_name, games_played, best_game) values('$username', 0, 0)")
  games_played=0
  best_game=0
  echo "Welcome, $username! It looks like this is your first time here."
else
  IFS="|" read -r games_played best_game <<< "$get_user"
  echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read guess
tries=1

while [[ $guess -ne $mystery_number ]]; do
  if [[ $guess =~ ^[0-9]+$ ]]; then
    if [[ $guess -lt $mystery_number ]]; then
      echo "It's higher than that, guess again:"
    else
      echo "It's lower than that, guess again:"
    fi
    (( tries++ ))
    read guess
  else
    echo "That is not an integer, guess again:"
    (( tries++ ))
    read guess
  fi
done

(( games_played++ ))
if [[ $best_game -gt $tries || $best_game -eq 0 ]]; then
  best_game=$tries
fi
game_end=$($PSQL "update users set games_played=$games_played, best_game=$best_game where user_name='$username'")
echo "You guessed it in $tries tries. The secret number was $mystery_number. Nice job!"