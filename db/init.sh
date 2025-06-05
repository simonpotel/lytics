#!/bin/bash
set -e

# get environment variables from .env file
DB_NAME=${DB_NAME:-NUTION}
DB_USER=${DB_USER:-dev}

echo "Checking if the database exists..."

# check if the database already exists
DB_EXISTS=$(psql -U "$DB_USER" -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME" && echo "true" || echo "false")

if [ "$DB_EXISTS" = "false" ]; then
    echo "Database $DB_NAME does not exist. Creating..."
    
    # create the database
    createdb -U "$DB_USER" "$DB_NAME"
    
    echo "Running setup script..."
    # run the setup script
    psql -U "$DB_USER" -d "$DB_NAME" -f /docker-entrypoint-initdb.d/db_setup.sql
    
    echo "Database $DB_NAME created and initialized successfully!"
else
    echo "Database $DB_NAME already exists. No action needed."
fi

DB_CONTENT=$(psql -U "$DB_USER" -d "$DB_NAME" -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" | grep -Eo '[0-9]+')
echo "Database $DB_NAME contains $DB_CONTENT tables."

