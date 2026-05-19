// Supabase fortune_ko 벌크 삽입 스크립트
// 실행: node F:/Yegamssi/etc/supabase_insert.mjs

import fs from 'fs';
import https from 'https';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;
const TABLE = 'fortune_ko';
const BATCH_SIZE = 200;

if (!SUPABASE_URL || !SUPABASE_KEY) {
  throw new Error('SUPABASE_URL and SUPABASE_ROLE_KEY or SUPABASE_ANON_KEY are required');
}

// SQL 파일 파싱
const sqlPath = new URL('./ko_full_insert.sql', import.meta.url).pathname.replace(/^\/([A-Z]:)/, '$1');
const sql = fs.readFileSync(sqlPath, 'utf8');

const rows = [];
for (const line of sql.split('\n')) {
  const t = line.trim().replace(/,$/, '').replace(/;$/, '');
  if (!t.startsWith("('")) continue;
  const m = t.match(/^\('([^']+)','([^']+)','((?:[^']|'')*)' *,(\d+)\)$/);
  if (m) {
    rows.push({
      code: m[1],
      type: m[2],
      text: m[3].replace(/''/g, "'"),
      weight: parseInt(m[4])
    });
  }
}

console.log(`📋 파싱 완료: ${rows.length}행`);

// REST API POST 함수
function postBatch(batch) {
  return new Promise((resolve, reject) => {
    const body = JSON.stringify(batch);
    const url = new URL(`/rest/v1/${TABLE}`, SUPABASE_URL);
    const options = {
      hostname: url.hostname,
      path: url.pathname,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${SUPABASE_KEY}`,
        'apikey': SUPABASE_KEY,
        'Prefer': 'return=minimal',
        'Content-Length': Buffer.byteLength(body),
      },
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve(res.statusCode);
        } else {
          reject(new Error(`HTTP ${res.statusCode}: ${data}`));
        }
      });
    });

    req.on('error', reject);
    req.write(body);
    req.end();
  });
}

// 배치 실행
let success = 0;
let fail = 0;

for (let i = 0; i < rows.length; i += BATCH_SIZE) {
  const batch = rows.slice(i, i + BATCH_SIZE);
  const batchNum = Math.floor(i / BATCH_SIZE) + 1;
  const totalBatches = Math.ceil(rows.length / BATCH_SIZE);
  process.stdout.write(`  배치 ${batchNum}/${totalBatches} (${i}~${Math.min(i+BATCH_SIZE, rows.length)}행)... `);

  try {
    await postBatch(batch);
    success += batch.length;
    process.stdout.write('✅\n');
  } catch (e) {
    fail += batch.length;
    process.stdout.write(`❌ ${e.message}\n`);
    // 첫 실패 시 중단 (권한 문제 등)
    if (fail === batch.length && batchNum === 1) {
      console.error('\n⛔ 첫 배치 실패 — 삽입 중단. 권한 또는 연결 문제를 확인하세요.');
      process.exit(1);
    }
  }
}

console.log(`\n🎉 완료: 성공 ${success}행 / 실패 ${fail}행`);
