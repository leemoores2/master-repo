#!/bin/bash

# Recreate Keygen DB

su postgres
psql
drop database keygen;
create database keygen owner = postgres;
\q
exit

# Start up Keygen

java -jar /opt/software/licencekeygen-0.0.1-SNAPSHOT.war

# Reconfigure Keygen DB

su postgres
psql
\c keygen
delete from loginuser;
COPY customer FROM '/opt/postgres/customer.csv' DELIMITER ',' CSV;
COPY customer_contact FROM '/opt/postgres/contact.csv' DELIMITER ',' CSV;
COPY loginuser FROM '/opt/postgres/loginuser.csv' DELIMITER ',' CSV; 
\q
psql -U postgres -d keygen < /opt/postgres/licence_final.sql
psql
\c keygen
ALTER SEQUENCE customer_id_seq RESTART WITH 75;
ALTER SEQUENCE customer_contact_id_seq RESTART WITH 130;
ALTER SEQUENCE licence_id_seq RESTART WITH 800;
\q
exit
