#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

FUNCTION_GUESS() {
  echo -e $1
  read ANSWER
  SECRET_NUMBER=$2

  if [[ $ANSWER =~ ^[0-9]+$ ]]
  then  
    if [[ $ANSWER -gt $SECRET_NUMBER ]]
    then 
      return 1
    elif [[ $ANSWER -lt $SECRET_NUMBER ]]
    then
      return 2
    elif [[ $ANSWER -eq $SECRET_NUMBER ]]
    then
      return 3
    fi
  fi
}

DATABASE() {
  USERNAME=$1
  NB_TRY=$2
  DATABASE_NAME=$($PSQL "SELECT * FROM players WHERE username='$USERNAME';")

   echo $DATABASE_NAME | while IFS='|' read USERNAME GAMES_PLAYED BEST_GAME
    do
    if [[ BEST_GAME==0 ]]
    then
    GAMES_PLAYED=$(($GAMES_PLAYED+1))
    BEST_GAME=$NB_TRY
    elif [[ $NB_TRY -lt $BEST_GAME ]]
    then
    GAMES_PLAYED=$(($GAMES_PLAYED+1))
    BEST_GAME=$NB_TRY
    elif [[ $NB_TRY -ge $BEST_GAME ]]
    then
    GAMES_PLAYED=$(($GAMES_PLAYED+1))
    fi
    UPDATE_DATABASE=$($PSQL "UPDATE players SET best_game=$BEST_GAME,games_played=$GAMES_PLAYED WHERE username='$USERNAME';")
    done
  

}

# Generate a randome number
SECRET_NUMBER=$((RANDOM%1001))

#Ask for a name
echo "Enter your username:"
read USERNAME

  # Look if it is into the database
  DATABASE_NAME=$($PSQL "SELECT * FROM players WHERE username='$USERNAME';")
    # If not,Create a new user DB
    if [[ -z $DATABASE_NAME ]]
    then
    NEW_USER=$($PSQL "INSERT INTO players(username,best_game,games_played) VALUES ('$USERNAME',0,0);")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    else  
    # if it into the db, it says hello
    echo $DATABASE_NAME | while IFS='|' read USERNAME GAMES_PLAYED BEST_GAME
    do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    done
    fi

    TEST=0
    ECHO="Guess the secret number between 1 and 1000:"
    NB_TRY=0

    while [[ $TEST -eq 0 ]]
    do
    NB_TRY=$(($NB_TRY+1))
    FUNCTION_GUESS "$ECHO" $SECRET_NUMBER
    case $? in
    1) ECHO="It's lower than that, guess again:";;
    2) ECHO="It's higher than that, guess again:";;
    3)
    (( TEST ++ ))
    DATABASE $USERNAME $NB_TRY
    echo "You guessed it in $NB_TRY tries. The secret number was $SECRET_NUMBER. Nice job!";;
    *) 
    NB_TRY=$(($NB_TRY-1))
    ECHO="That is not an integer, guess again:";
    esac
    done



#INSERT INTO players(username) VALUES ("Adeline");
#UPDATE players SET best_game=20,games_played=2 WHERE username='Adeline';
