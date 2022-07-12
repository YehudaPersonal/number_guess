#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
# RANDOM_NUMBER=$(shuf -i 1-1000 -n 1)
RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))
let GUESS_COUNT=0

GUESS_LOOP() {
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read GUESS
    GUESS_LOOP
  fi
  let GUESS_COUNT++
  if [[ $GUESS < $RANDOM_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    read GUESS
    GUESS_LOOP
  elif [[ $GUESS > $RANDOM_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    read GUESS
    GUESS_LOOP
  fi
}


echo -e "Enter your username:"
read USERNAME

# check if username has been used before
USER_ID=$($PSQL "select user_id from users where username = '$USERNAME'")

if [[ -z $USER_ID ]]
then
  ADD_NEW_USER_RESULT=$($PSQL "insert into users(username,games_played,best_game) values('$USERNAME',1,0)")
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
else
  USER_DATA=$($PSQL "select games_played, best_game from users where user_id = $USER_ID")
  echo $USER_DATA | while IFS="|" read GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    let GAMES_PLAYED++
    INCREMENT_GAMES_PLAYED=$($PSQL "update users set games_played = $GAMES_PLAYED where username = '$USERNAME'")
  done
fi

echo "\nGuess the secret number between 1 and 1000:\n"
read GUESS

GUESS_LOOP

echo "You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"

# compare number of guesses to best guess in database
CURRENT_BEST_GUESS=$($PSQL "select best_game from users where username = '$USERNAME'")
# if number of guesses is lower update database
if [[ $GUEST_COUNT < $CURRENT_BEST_GUESS ]]
then
  UPDATE_BEST_GAME_RESULT=$($PSQL "update users set best_game = $GUESS_COUNT where username = '$USERNAME'")
fi

exit 0
