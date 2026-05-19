import fs from 'fs';
import https from 'https';

const EXPECTED_ROWS = 5976;
const EXPECTED_TYPES = { intro: 1512, effect: 1512, action: 1512, state: 1440 };
const MAX_FILE_BYTES = 900_000;

function readEnv() {
  const env = {};
  for (const line of fs.readFileSync('.env', 'utf8').split(/\r?\n/)) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const idx = trimmed.indexOf('=');
    if (idx < 0) continue;
    env[trimmed.slice(0, idx).trim()] = trimmed.slice(idx + 1).trim();
  }
  return env;
}

function parseCsvLine(line) {
  const result = [];
  let cell = '';
  let quoted = false;
  for (let i = 0; i < line.length; i++) {
    const ch = line[i];
    if (quoted) {
      if (ch === '"' && line[i + 1] === '"') {
        cell += '"';
        i++;
      } else if (ch === '"') {
        quoted = false;
      } else {
        cell += ch;
      }
    } else if (ch === '"') {
      quoted = true;
    } else if (ch === ',') {
      result.push(cell);
      cell = '';
    } else {
      cell += ch;
    }
  }
  result.push(cell);
  return result;
}

function readRows(csvPath) {
  const fileSize = fs.statSync(csvPath).size;
  if (fileSize > MAX_FILE_BYTES) {
    throw new Error(`${csvPath} is too large: ${fileSize} bytes`);
  }
  const raw = fs.readFileSync(csvPath, 'utf8').replace(/^\uFEFF/, '');
  const lines = raw.split(/\r?\n/).filter(Boolean);
  const header = parseCsvLine(lines[0]);
  if (header.join(',') !== 'code,type,text,weight') {
    throw new Error(`CSV header mismatch: ${header.join(',')}`);
  }
  return lines.slice(1).map((line, index) => {
    const [code, type, text, weight] = parseCsvLine(line);
    if (!code || !type || !text || !weight) {
      throw new Error(`CSV parse error at row ${index + 2}`);
    }
    return { code, type, text, weight: Number(weight) };
  });
}

function validateRows(rows) {
  if (rows.length !== EXPECTED_ROWS) {
    throw new Error(`row count mismatch: ${rows.length}`);
  }
  const counts = {};
  for (const row of rows) {
    counts[row.type] = (counts[row.type] || 0) + 1;
    if (!['A', 'B', 'B1', 'C', 'C1', 'D'].includes(row.code.split('_')[1])) {
      throw new Error(`bad tier: ${row.code}`);
    }
    if (!Number.isInteger(row.weight) || row.weight < 1 || row.weight > 10) {
      throw new Error(`bad weight: ${row.code}`);
    }
  }
  for (const [type, count] of Object.entries(EXPECTED_TYPES)) {
    if (counts[type] !== count) {
      throw new Error(`type count mismatch ${type}: ${counts[type]}`);
    }
  }
}

function request({ method, url, key, body, headers = {} }) {
  return new Promise((resolve, reject) => {
    const u = new URL(url);
    const payload = body == null ? null : JSON.stringify(body);
    const req = https.request(
      {
        method,
        hostname: u.hostname,
        path: `${u.pathname}${u.search}`,
        headers: {
          apikey: key,
          Authorization: `Bearer ${key}`,
          ...(payload
            ? {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(payload),
              }
            : {}),
          ...headers,
        },
      },
      (res) => {
        let data = '';
        res.setEncoding('utf8');
        res.on('data', (chunk) => (data += chunk));
        res.on('end', () => {
          if (res.statusCode >= 200 && res.statusCode < 300) {
            resolve({ status: res.statusCode, headers: res.headers, data });
          } else {
            reject(
              new Error(
                `${method} ${u.pathname}${u.search} HTTP ${res.statusCode}: ${data.slice(0, 500)}`,
              ),
            );
          }
        });
      },
    );
    req.on('error', reject);
    if (payload) req.write(payload);
    req.end();
  });
}

async function countRows(base, key, table) {
  const res = await request({
    method: 'GET',
    url: `${base}/rest/v1/${table}?select=id&limit=1`,
    key,
    headers: { Prefer: 'count=exact' },
  });
  return Number((res.headers['content-range'] || '').split('/')[1] ?? NaN);
}

async function upload(table, csvPath) {
  const env = readEnv();
  const base = env.SUPABASE_URL;
  const key = env.SUPABASE_ROLE_KEY || env.SUPABASE_ANON_KEY;
  if (!base || !key) throw new Error('SUPABASE_URL/SUPABASE_ROLE_KEY missing');

  const rows = readRows(csvPath);
  validateRows(rows);
  console.log(`${table}: local validated rows=${rows.length}, bytes=${fs.statSync(csvPath).size}`);
  console.log(`${table}: remote before=${await countRows(base, key, table)}`);

  await request({
    method: 'DELETE',
    url: `${base}/rest/v1/${table}?id=not.is.null`,
    key,
    headers: { Prefer: 'return=minimal' },
  });

  const batchSize = 300;
  let inserted = 0;
  for (let i = 0; i < rows.length; i += batchSize) {
    const batch = rows.slice(i, i + batchSize);
    await request({
      method: 'POST',
      url: `${base}/rest/v1/${table}`,
      key,
      body: batch,
      headers: { Prefer: 'return=minimal' },
    });
    inserted += batch.length;
    process.stdout.write(`${table}: inserted ${inserted}/${rows.length}\r`);
  }
  process.stdout.write('\n');

  const after = await countRows(base, key, table);
  console.log(`${table}: remote after=${after}`);
  if (after !== EXPECTED_ROWS) {
    throw new Error(`${table}: remote row count mismatch: ${after}`);
  }
}

const pairs = process.argv.slice(2);
if (pairs.length === 0 || pairs.length % 2 !== 0) {
  console.error('Usage: node tool/upload_fortune_style_table.mjs <table> <csvPath> [...]');
  process.exit(1);
}

for (let i = 0; i < pairs.length; i += 2) {
  await upload(pairs[i], pairs[i + 1]);
}
