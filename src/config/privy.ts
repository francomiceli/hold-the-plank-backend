import { PrivyClient } from '@privy-io/server-auth';
import dotenv from 'dotenv';

dotenv.config();

const privyClient = new PrivyClient(
  process.env.PRIVY_APP_ID || '',
  process.env.PRIVY_APP_SECRET || ''
);

export default privyClient;