#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Inserting data into the Postgres

echo -e "\n~~ INSERTING DATA... ~~\n";

echo "$($PSQL "TRUNCATE TABLE games, teams")"

# Pipe contents and perform operations
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Skip the labels found at the top of csv file
  if [[ $YEAR == 'year' ]]
  then
    continue 
  fi

  # ~~ TEAMS ~~

  # Check if winner team exists in teams table
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

  # If not exist
  if [[ -z $WINNER_ID ]]
  then
    # Insert the winner team
    INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
    
    if [[ $INSERT_WINNER_RESULT == 'INSERT 0 1' ]]
    then
      echo -e "\U1F7E9 Successfully inserted $WINNER into the Teams table"

      # Set the winner_id once again to prevent nulls
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    else
      echo -e "\U1F7E5 Failed to insert $WINNER into the Teams table"
      continue
    fi
  fi

  # Check if opponent team exists in teams table
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

  # If not exist
  if [[ -z $OPPONENT_ID ]]
  then
    # Insert the OPPONENT team
    INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
    
    if [[ $INSERT_OPPONENT_RESULT == 'INSERT 0 1' ]]
    then
      echo -e "\U1F7E9 Successfully inserted $OPPONENT into the Teams table"

      # Set the opponent_id once again to prevent nulls
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    else
      echo -e "\U1F7E5 Failed to insert $OPPONENT into the Teams table"
      continue
    fi
  fi

  # ~~ GAMES ~~~

  # Insert games data to games table
  INSERT_GAMES_DATA=$($PSQL "
    INSERT INTO games(year, round, winner_goals, opponent_goals, winner_id, opponent_id)
    VALUES($YEAR, '$ROUND', $WINNER_GOALS, $OPPONENT_GOALS, $WINNER_ID, $OPPONENT_ID) 
  ")

  if [[ $INSERT_GAMES_DATA == "INSERT 0 1" ]]
  then
    echo -e "\U1F7E9 Successfully inserted games data for $WINNER vs $OPPONENT"
  else
    echo -e "\U1F7E5 Failed to insert games data for $WINNER vs $OPPONENT\n"
  fi
done