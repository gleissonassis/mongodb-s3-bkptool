#!/bin/bash

DATABASES=${DATABASE_NAME}

# Check if all necessary variables are defined
if [ -z "$DATABASE_NAME" ] || [ -z "$S3_BUCKET_PATH" ] || [ -z "$S3_ACCESS_KEY" ] || [ -z "$S3_SECRET_KEY" ] || [ -z "$S3_ENDPOINT_URL" ] || [ -z "$SOURCE" ]; then
    echo "Error: Environment variables not defined."
    exit 1
fi

# Setting the current date and date from 7 days ago
DATA_ATUAL=$(date +%Y-%m-%d)
# DATA_ANTIGA=$(date --date='7 days ago' +%Y-%m-%d)

IFS=','  # Setting the internal field separator to a comma
for DB in $DATABASES; do
    echo "Running backup for database $DB..."

    # Setting up temporary directories
    DUMP_DIR="./mongodump-$DB"
    DUMP_FILE="$DB-$(date +%Y%m%d%H%M%S).tar.gz"

    # Performing the database dump
    echo "Exporting database..."
    mongodump --uri="$SOURCE" --db="$DB" --out="$DUMP_DIR"

    # Checking if the dump was successful
    if [ $? -ne 0 ]; then
        echo "Error during database dump."
        exit 1
    fi

    # Compressing the dump
    echo "Compressing the dump..."
    tar -czvf "$DUMP_FILE" -C "$DUMP_DIR" .

    # Checking if the compression was successful
    if [ $? -ne 0 ]; then
        echo "Error during file compression."
        exit 1
    fi

    # Setting AWS S3 credentials
    export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY
    export AWS_SECRET_ACCESS_KEY=$S3_SECRET_KEY
    export AWS_ENDPOINT_URL=$S3_ENDPOINT_URL

    # Uploading the dump to the S3 bucket
    echo "Uploading the dump to S3..."
    aws s3 cp "$DUMP_FILE" "$S3_BUCKET_PATH/$DATA_ATUAL/$DB/$DUMP_FILE" --endpoint-url $S3_ENDPOINT_URL

    echo "Database backup successfully uploaded to S3 and old backup removed, if it existed."

    # Cleaning up local files
    rm -rf "$DUMP_DIR"
    rm -f "$DUMP_FILE"
done
