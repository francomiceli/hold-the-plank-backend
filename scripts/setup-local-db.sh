#!/bin/bash

# Local Database Setup Script for Hold The Plank Backend
# This script creates the database and imports the schema

set -e

echo "🔧 Hold The Plank - Local Database Setup"
echo "========================================"

# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "⚠️  Warning: .env file not found. Using defaults from .env.example"
    export $(cat .env.example | grep -v '^#' | xargs)
fi

# Database credentials
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-3306}
DB_NAME=${DB_NAME:-hold_the_plank_dev}
DB_USER=${DB_USER:-root}
DB_PASSWORD=${DB_PASSWORD:-}

echo ""
echo "Configuration:"
echo "  Host: $DB_HOST"
echo "  Port: $DB_PORT"
echo "  Database: $DB_NAME"
echo "  User: $DB_USER"
echo ""

# Check if MySQL is installed
if ! command -v mysql &> /dev/null; then
    echo "❌ MySQL client is not installed. Please install MySQL first."
    echo ""
    echo "Installation instructions:"
    echo "  Ubuntu/Debian: sudo apt-get install mysql-client"
    echo "  macOS: brew install mysql-client"
    exit 1
fi

# Check if MySQL server is running
if ! mysqladmin ping -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" --silent 2>/dev/null; then
    echo "❌ Cannot connect to MySQL server at $DB_HOST:$DB_PORT"
    echo "Please ensure MySQL server is running."
    exit 1
fi

echo "✅ MySQL server is running"

# Create database if it doesn't exist
echo ""
echo "Creating database '$DB_NAME'..."

if [ -z "$DB_PASSWORD" ]; then
    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
else
    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
fi

echo "✅ Database created successfully"

# Import schema from SQL file
echo ""
echo "Importing schema from 'Conquer Plank.sql'..."

if [ -z "$DB_PASSWORD" ]; then
    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" "$DB_NAME" < "Conquer Plank.sql"
else
    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < "Conquer Plank.sql"
fi

echo "✅ Schema imported successfully"

# Verify tables were created
echo ""
echo "Verifying tables..."

if [ -z "$DB_PASSWORD" ]; then
    TABLE_COUNT=$(mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" "$DB_NAME" -sN -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$DB_NAME';")
else
    TABLE_COUNT=$(mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -sN -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$DB_NAME';")
fi

echo "✅ Found $TABLE_COUNT tables in database"

echo ""
echo "🎉 Local database setup complete!"
echo ""
echo "You can now run the application with:"
echo "  npm run dev"
