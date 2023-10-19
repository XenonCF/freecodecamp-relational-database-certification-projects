#! /bin/bash
echo -e "\n~~~~~ MY SALON ~~~~~"
PSQL='psql --username=freecodecamp --dbname=salon --tuples-only -A -c'
SERVICE_ID_SELECTED=""
MAIN_MENU() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  else
    echo -e "\nWelcome to My Salon, how can I help you?\n"
  fi
  # List services
  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id ")
  echo "$SERVICES" | while IFS="|" read -r SERVICE_ID NAME; do
    echo "$SERVICE_ID) $NAME"
  done

  # Get service id input
  read SERVICE_ID_SELECTED
}

SERVICE_ID_VALIDATOR() {
  NUMBER_REGEX='^[0-9]+$'
  
  if [[ $1 =~ $NUMBER_REGEX ]]; then
    SERVICE_SELECTION_QUERY=$($PSQL "select * from services where service_id=$1")
    if [[ -n $SERVICE_SELECTION_QUERY ]]; then
      echo 0
    else
      echo 1
    fi
  else
    echo 1
  fi
}

SALON() {
  echo -e "\nPlease enter your phone number"
  read CUSTOMER_PHONE

  PHONE_SELECTION_QUERY=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_ID=""
  CUSTOMER_NAME=""

  if [[ -z $PHONE_SELECTION_QUERY ]]; then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    NEW_CUSTOMER_QUERY=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id from customers WHERE phone='$CUSTOMER_PHONE'")
  else
    while IFS="|" read ID NAME; do
      CUSTOMER_ID=$ID
      CUSTOMER_NAME=$NAME
    done <<< "$PHONE_SELECTION_QUERY"
  fi
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  NEW_APPOINTMENT_QUERY=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}


MAIN_MENU
while [[ $(SERVICE_ID_VALIDATOR "$SERVICE_ID_SELECTED") == 1 ]]; do
  MAIN_MENU "I could not find that service. What would you like today?"
done
SALON