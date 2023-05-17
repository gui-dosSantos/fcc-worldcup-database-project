#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
TRUNCATE_TABLE="$($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY")"

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
do
  if [[ $YEAR != "year" ]] 
  then
    if [[ $ROUND == "Final" || $ROUND == "Third Place" ]]
    then
      WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
      if [[ -z $WINNER_ID ]]
      then
        WINNER_INSERT="$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")"
        WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
        echo Inserted $WINNER into teams
      fi
      OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"
      if [[ -z $OPPONENT_ID ]]
      then
        OPPONENT_INSERT="$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")"
        OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"
        echo Inserted $OPPONENT into teams
      fi
    elif [[ $ROUND == "Semi-Final" ]]
    then
      WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
      OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"
    else 
      WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
      OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"
      if [[ -z $OPPONENT_ID ]]
      then
        OPPONENT_INSERT="$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")"
        OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"
        echo Inserted $OPPONENT into teams
      fi
    fi
    GAME_INSERT="$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $W_GOALS, $O_GOALS)")"
    echo Inserted $YEAR $ROUND into games
  fi
done

