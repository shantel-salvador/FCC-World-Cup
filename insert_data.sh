#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Truncate tables to avoid duplicates
echo "$($PSQL "TRUNCATE TABLE games, teams")"

# Read games.csv and process each line
cat games.csv | while IFS=',' read -r year round winner opponent winner_goals opponent_goals
do
  # Skip the header line
  if [[ $year != "year" ]]
  then
    # Insert unique teams into the teams table
    echo "$($PSQL "INSERT INTO teams(name) VALUES('$winner') ON CONFLICT (name) DO NOTHING")"
    echo "$($PSQL "INSERT INTO teams(name) VALUES('$opponent') ON CONFLICT (name) DO NOTHING")"

    # Get team IDs for winner and opponent
    winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
    opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")

    # Insert game data into the games table
    echo "$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals)")"
  fi
done
