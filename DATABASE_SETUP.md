# Database Setup Guide - Hold The Plank Backend

This guide covers database setup for all environments: local development, CI/CD, and production (EC2).

## Table of Contents
- [Local Development Setup](#local-development-setup)
- [GitHub Actions CI/CD](#github-actions-cicd)
- [Production Setup (EC2)](#production-setup-ec2)
- [Database Schema](#database-schema)
- [Troubleshooting](#troubleshooting)

---

## Local Development Setup

### Prerequisites
- MySQL 8.0+ installed and running
- Node.js 20+ installed
- Git repository cloned

### Quick Start

1. **Install MySQL** (if not already installed):

   **Ubuntu/Debian:**
   ```bash
   sudo apt-get update
   sudo apt-get install mysql-server
   sudo systemctl start mysql
   ```

   **macOS:**
   ```bash
   brew install mysql
   brew services start mysql
   ```

   **Windows:**
   Download and install from [MySQL Downloads](https://dev.mysql.com/downloads/installer/)

2. **Configure environment variables:**
   ```bash
   cp .env.example .env
   ```

   Edit `.env` with your local settings:
   ```env
   DB_HOST=localhost
   DB_PORT=3306
   DB_NAME=hold_the_plank_dev
   DB_USER=root
   DB_PASSWORD=your_password
   ```

3. **Run the automated setup script:**
   ```bash
   bash scripts/setup-local-db.sh
   ```

   This script will:
   - Create the database `hold_the_plank_dev`
   - Import the schema from `Conquer Plank.sql`
   - Verify table creation

4. **Install dependencies and start the server:**
   ```bash
   npm install
   npm run dev
   ```

### Manual Setup (Alternative)

If you prefer to set up manually:

```bash
# Connect to MySQL
mysql -u root -p

# Create database
CREATE DATABASE hold_the_plank_dev CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# Use the database
USE hold_the_plank_dev;

# Import schema
SOURCE /path/to/Conquer\ Plank.sql;

# Verify tables
SHOW TABLES;
```

---

## GitHub Actions CI/CD

The project includes automated CI/CD pipeline at [.github/workflows/ci.yml](.github/workflows/ci.yml).

### What It Does

- ✅ Runs on every push to `main` or `develop` branches
- ✅ Runs on pull requests
- ✅ Spins up MySQL 8.0 service container
- ✅ Imports database schema automatically
- ✅ Runs build process
- ✅ Runs tests (when available)
- ✅ Validates TypeScript compilation

### GitHub Secrets Required

Add these secrets to your GitHub repository (Settings → Secrets and variables → Actions):

```
PRIVY_APP_ID         - Your Privy application ID
PRIVY_APP_SECRET     - Your Privy application secret
```

### How It Works

1. **MySQL Service**: GitHub Actions spins up a MySQL 8.0 container
2. **Schema Import**: The workflow imports `Conquer Plank.sql` automatically
3. **Environment Setup**: Creates test `.env` file with test database credentials
4. **Build & Test**: Compiles TypeScript and runs tests
5. **Artifacts**: Uploads build artifacts for deployment

### Viewing CI/CD Results

- Go to the "Actions" tab in your GitHub repository
- Click on any workflow run to see detailed logs
- Green checkmark = all tests passed
- Red X = something failed (check logs for details)

---

## Production Setup (EC2)

### Prerequisites

- Ubuntu 20.04+ EC2 instance
- SSH access to the instance
- Root or sudo privileges
- At least 1GB RAM (2GB+ recommended)

### Step-by-Step Production Setup

#### 1. Connect to Your EC2 Instance

```bash
ssh -i your-key.pem ubuntu@your-ec2-ip-address
```

#### 2. Update System and Install Dependencies

```bash
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y git curl build-essential
```

#### 3. Install Node.js 20+

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
node --version  # Verify installation
```

#### 4. Clone Your Repository

```bash
cd /home/ubuntu
git clone https://github.com/your-username/hold-the-plank-backend.git
cd hold-the-plank-backend
```

#### 5. Run the Automated Production Setup

```bash
sudo bash scripts/setup-production-db.sh
```

This script will:
- ✅ Install and configure MySQL 8.0
- ✅ Create production database and user
- ✅ Generate secure random password
- ✅ Import database schema
- ✅ Create `.env.production` file
- ✅ Configure MySQL for production
- ✅ Save credentials securely

**IMPORTANT**: The script will display database credentials. **Save them securely!**

#### 6. Update Environment Variables

```bash
# Copy production env to .env
cp .env.production .env

# Edit with your actual values
nano .env
```

Update these critical values:
```env
PRIVY_APP_ID=your_actual_privy_app_id
PRIVY_APP_SECRET=your_actual_privy_app_secret
FRONTEND_URL=https://your-frontend-domain.com
```

#### 7. Install Application Dependencies

```bash
npm install --production
```

#### 8. Build the Application

```bash
npm run build
```

#### 9. Set Up PM2 for Process Management

```bash
# Install PM2 globally
sudo npm install -g pm2

# Start the application
pm2 start dist/index.js --name hold-the-plank

# Save PM2 configuration
pm2 save

# Set up PM2 to start on system boot
pm2 startup systemd
# Follow the instructions printed by the command above
```

#### 10. Configure Firewall (Security Group)

In AWS Console, update your EC2 Security Group:

**Inbound Rules:**
- Port 3000 (API) - Allow from your frontend IP or load balancer
- Port 22 (SSH) - Allow from your IP only
- Port 80/443 (if using Nginx) - Allow from anywhere

**Do NOT expose port 3306 (MySQL) to the internet!**

#### 11. Optional: Set Up Nginx Reverse Proxy

```bash
sudo apt-get install -y nginx

# Create Nginx configuration
sudo nano /etc/nginx/sites-available/hold-the-plank
```

Add this configuration:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/hold-the-plank /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

#### 12. Optional: Set Up SSL with Let's Encrypt

```bash
sudo apt-get install -y certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

### Production Database Credentials

Credentials are saved in two locations:

1. **Root credentials file**: `/root/.hold-the-plank-db-credentials`
   ```bash
   sudo cat /root/.hold-the-plank-db-credentials
   ```

2. **Application .env file**: `/home/ubuntu/hold-the-plank-backend/.env`
   ```bash
   cat .env
   ```

**Security Best Practices:**
- ✅ Never commit `.env` or credentials to Git
- ✅ Rotate database passwords regularly
- ✅ Use environment variables for secrets
- ✅ Restrict SSH access to specific IPs
- ✅ Keep MySQL on localhost only
- ✅ Enable CloudWatch logs for monitoring

### Production Management Commands

```bash
# View application logs
pm2 logs hold-the-plank

# Restart application
pm2 restart hold-the-plank

# Stop application
pm2 stop hold-the-plank

# Monitor application
pm2 monit

# View database credentials
sudo cat /root/.hold-the-plank-db-credentials

# Connect to production database
mysql -u plank_user -p hold_the_plank_prod

# Check MySQL status
sudo systemctl status mysql

# View MySQL error logs
sudo tail -f /var/log/mysql/error.log
```

---

## Database Schema

The database schema is defined in [Conquer Plank.sql](Conquer Plank.sql).

### Tables Overview

1. **users** - User accounts and wallet information
2. **guilds** - Team/clan data
3. **sessions** - Plank exercise sessions
4. **session_proofs** - AI verification snapshots
5. **gyms** - Physical gym locations with QR codes
6. **gym_checkins** - User check-ins at gyms
7. **transactions** - Financial ledger (PLANK/AURA)
8. **items_catalog** - NFT and in-game items
9. **user_inventory** - User-owned items and NFTs

### Database Migrations

The application uses Sequelize with `sync({ alter: true })` in development. For production:

**DO NOT** use `sync()` in production. Instead:

1. Make schema changes in a new SQL file (e.g., `migrations/001_add_column.sql`)
2. Apply manually to production:
   ```bash
   mysql -u plank_user -p hold_the_plank_prod < migrations/001_add_column.sql
   ```

---

## Troubleshooting

### Local Development Issues

**Problem: "Cannot connect to database"**
```bash
# Check if MySQL is running
sudo systemctl status mysql

# Start MySQL
sudo systemctl start mysql

# Check credentials in .env file
cat .env
```

**Problem: "Access denied for user"**
```bash
# Reset MySQL root password
sudo mysql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_password';
FLUSH PRIVILEGES;
```

**Problem: "Table already exists"**
- Drop and recreate database:
  ```bash
  mysql -u root -p
  DROP DATABASE hold_the_plank_dev;
  CREATE DATABASE hold_the_plank_dev;
  USE hold_the_plank_dev;
  SOURCE Conquer\ Plank.sql;
  ```

### GitHub Actions Issues

**Problem: "MySQL health check failed"**
- Wait longer for MySQL to start
- Check workflow logs for specific errors
- Verify `Conquer Plank.sql` syntax

**Problem: "Secrets not found"**
- Add `PRIVY_APP_ID` and `PRIVY_APP_SECRET` to GitHub Secrets
- Go to: Repository Settings → Secrets and variables → Actions

### Production Issues

**Problem: "Cannot connect to EC2 instance"**
- Check Security Group allows SSH (port 22) from your IP
- Verify you're using the correct key pair
- Check instance is running

**Problem: "Application won't start"**
```bash
# Check PM2 logs
pm2 logs hold-the-plank

# Check if port 3000 is in use
sudo lsof -i :3000

# Verify .env file exists and has correct values
cat .env
```

**Problem: "Database connection failed in production"**
```bash
# Test database connection
mysql -u plank_user -p hold_the_plank_prod

# Check MySQL is running
sudo systemctl status mysql

# View MySQL logs
sudo tail -f /var/log/mysql/error.log

# Verify credentials in .env match database
cat .env
sudo cat /root/.hold-the-plank-db-credentials
```

**Problem: "Out of memory"**
- Upgrade EC2 instance type (minimum t3.small recommended)
- Add swap space:
  ```bash
  sudo fallocate -l 2G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  ```

### Getting Help

If you encounter issues not covered here:

1. Check application logs: `pm2 logs hold-the-plank`
2. Check MySQL logs: `sudo tail -f /var/log/mysql/error.log`
3. Verify all environment variables are set correctly
4. Ensure firewall/security group rules are correct

---

## Summary

- **Local**: Run `bash scripts/setup-local-db.sh`
- **CI/CD**: Automated via GitHub Actions
- **Production**: Run `sudo bash scripts/setup-production-db.sh` on EC2

All environments use the same schema from `Conquer Plank.sql` for consistency.
