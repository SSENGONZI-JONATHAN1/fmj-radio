import pg from 'pg';
import 'dotenv/config';

async function test() {
  console.log('Testing PG connection...');
  const connectionString = process.env.DATABASE_URL;
  console.log('URL:', connectionString?.replace(/:[^:]+@/, ':****@'));
  
  const pool = new pg.Pool({ connectionString });
  
  try {
    const res = await pool.query('SELECT NOW()');
    console.log('Success!', res.rows[0]);
  } catch (err) {
    console.error('Failed!', err);
  } finally {
    await pool.end();
  }
}

test();
