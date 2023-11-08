#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if argument is provided
if [[ $1 ]]; then
  get_element=""
  # If argument is a number check if it is a valid atomic number
  if [[ $1 =~ ^[0-9]+$ ]]; then
    get_element=$($PSQL "SELECT properties.*, elements.symbol, elements.name, types.type FROM properties FULL JOIN elements ON elements.atomic_number = properties.atomic_number FULL JOIN types ON properties.type_id = types.type_id WHERE properties.atomic_number = $1")
  fi
  # If argument is a string check if it is a valid element name
  if [[ -z $get_element ]]; then
    get_element=$($PSQL "SELECT properties.*, elements.symbol, elements.name, types.type FROM properties FULL JOIN elements ON elements.atomic_number = properties.atomic_number FULL JOIN types ON properties.type_id = types.type_id WHERE elements.name = '$1'")
  fi
  # If argument is a string check if it is a valid element symbol
  if [[ -z $get_element ]]; then
    get_element=$($PSQL "SELECT properties.*, elements.symbol, elements.name, types.type FROM properties FULL JOIN elements ON elements.atomic_number = properties.atomic_number FULL JOIN types ON properties.type_id = types.type_id WHERE elements.symbol = '$1'")
  fi
  # Print element information if it is found
  if [[ -n $get_element ]]; then
    echo "$get_element" | while IFS="|" read -r atomic_number atomic_mass melting_point_celsius boiling_point_celsius type_id symbol name type; do
      echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point_celsius celsius and a boiling point of $boiling_point_celsius celsius."
    done
  # Print message if element is not found
  else
    echo "I could not find that element in the database."
  fi
# print message if argument is not provided
else
  echo -e "Please provide an element as an argument."
fi
