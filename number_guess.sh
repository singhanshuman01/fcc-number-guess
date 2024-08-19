#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username:"
read username

user_id=$($PSQL "select user_id from players where username='$username'")



if [[ -z $user_id ]]
then
  echo -e "\nWelcome, $username! It looks like this is your first time here."
  insert=$($PSQL "insert into players(username) values('$username')")



else
  username=$($PSQL "select username from players where user_id=$user_id")
  games_played=$($PSQL "select games_played from players where username='$username'")
  best_game=$($PSQL "select best_game from players where username='$username'")
  
  echo Welcome back, $username\! You have played $games_played games, and your best game took $best_game guesses.
fi

secret_number=$(( RANDOM % 1000 + 1 ))
# echo $secret_number
guess_count=0


echo -e "\nGuess the secret number between 1 and 1000:"
read guess

until [[ $guess == $secret_number ]]
do 
  if [[ ! $guess =~ ^[0-9]+$ ]]
  then 
    echo -e "\nThat is not an integer, guess again:"
    read guess

    ((guess_count++))
  else
    if [[ $guess < $secret_number ]]
    then
      echo -e "\nIt's lower than that, guess again:"
      read guess

      ((guess_count++))

    else
      echo -e "\nIt's higher than that, guess again:"
      read guess

      ((guess_count++))
    fi
  fi
done

((guess_count++))

user_id=$($PSQL "select user_id from players where username='$username'")

insert_game=$($PSQL "insert into games(username,guesses,user_id) values('$username',$guess_count,$user_id)")
games=$($PSQL "select sum(game) from games")
best_game=$($PSQL "select min(guesses) from games")


insert_players=$($PSQL "update players set games_played=$games where user_id=$user_id")
insert_players=$($PSQL "update players set best_game=$best_game where user_id=$user_id")

echo -e "\nYou guessed it in $guess_count tries. The secret number was $secret_number. Nice job!"
