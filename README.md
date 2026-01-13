# Hold The Plank - Backend API

Backend API for the Hold The Plank fitness gamification platform with blockchain integration.

## Features

- 🔐 **Privy Authentication** - Web3 wallet login
- 💪 **Plank Sessions** - Track and verify plank exercises
- 🏆 **Guilds System** - Team-based competition
- 🏋️ **Gym Check-ins** - QR code verification at partner gyms
- 💰 **$PLANK Token** - In-app currency and rewards
- ✨ **AURA Points** - Reputation and leveling system
- 🖼️ **NFT Items** - Collectible skins and effects
- 📸 **AI Verification** - Photo proof of plank form

## Quick Start

### Local Development
```bash
npm install
cp .env.example .env
npm run db:setup
npm run dev
```

### Production on EC2
```bash
sudo bash scripts/setup-production-db.sh
cp .env.production .env
npm install --production && npm run build
pm2 start dist/index.js --name hold-the-plank
```

📖 **See [QUICK_START.md](QUICK_START.md) for step-by-step instructions**

## Documentation

- **[QUICK_START.md](QUICK_START.md)** - Get started in 5 minutes
- **[DATABASE_SETUP.md](DATABASE_SETUP.md)** - Complete database setup guide
- **[Conquer Plank.sql](Conquer%20Plank.sql)** - Database schema

## Tech Stack

- **Runtime**: Node.js 20+ with TypeScript
- **Framework**: Express.js
- **Database**: MySQL 8.0
- **ORM**: Sequelize
- **Auth**: Privy (Web3 authentication)
- **Deployment**: EC2 with PM2

## API Endpoints

- `GET /health` - Health check
- `POST /auth/*` - Authentication endpoints
- More endpoints coming soon...

## Database Schema

The application uses 9 main tables:
- **users** - User accounts and wallets
- **guilds** - Team/clan data
- **sessions** - Plank exercise sessions
- **session_proofs** - AI verification snapshots
- **gyms** - Physical locations
- **gym_checkins** - User check-ins
- **transactions** - Financial ledger
- **items_catalog** - NFT items
- **user_inventory** - User items

## Environment Variables

```env
PORT=3000
NODE_ENV=development
DB_HOST=localhost
DB_PORT=3306
DB_NAME=hold_the_plank_dev
DB_USER=root
DB_PASSWORD=
PRIVY_APP_ID=
PRIVY_APP_SECRET=
FRONTEND_URL=http://localhost:8080
```

## Scripts

- `npm run dev` - Start development server with hot reload
- `npm run build` - Build for production
- `npm start` - Start production server
- `npm run db:setup` - Set up local database automatically
- `npm test` - Run tests

## CI/CD

The project uses GitHub Actions for continuous integration:
- ✅ Automated testing on push/PR
- ✅ MySQL database setup
- ✅ TypeScript compilation check
- ✅ Build artifact generation

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

ISC

## Support

For issues or questions, please open a GitHub issue.
