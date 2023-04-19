#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo "Welcome to My Salon, how can I help you?"
  fi
  

  SERVICES=$($PSQL "select service_id,name from services")

  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "没这个服务，只有下面这些↓"
  else
    SELECT_SERVICE_ID_RESULT=$($PSQL "select service_id from services where service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SELECT_SERVICE_ID_RESULT ]]
    then 
      MAIN_MENU "没这个服务，只有下面这些↓"
    else
      echo -e "\n请输入手机号"
      read CUSTOMER_PHONE
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_ID ]]
      then
        echo -e "\n请输入名字"
        read CUSTOMER_NAME
        echo -e "\n请输入预约时间"
        read SERVICE_TIME
        INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(name,phone) values('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
        INSERT_CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
        INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments(customer_id,service_id,time) values($INSERT_CUSTOMER_ID,$SELECT_SERVICE_ID_RESULT,'$SERVICE_TIME')")
        SELECT_SERVICE_NAME=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")
        echo -e "\nI have put you down for a $SELECT_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      else
        echo -e "\n请输入预约时间"
        read SERVICE_TIME
        INSERT_CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
        INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments(customer_id,service_id,time) values($INSERT_CUSTOMER_ID,$SELECT_SERVICE_ID_RESULT,'$SERVICE_TIME')")
        SELECT_SERVICE_NAME=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")
        CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'")
        echo -e "\nI have put you down for a $SELECT_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      fi
    fi
  fi
}

MAIN_MENU




