// Validates every .sql file against real Postgres grammar (libpg_query).
// Run: npm --prefix scripts install && npm --prefix scripts run check:sql
import { parse } from "pgsql-parser";
import { readFileSync, readdirSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const files = [
  ...readdirSync(join(root, "supabase/migrations")).filter((f) => f.endsWith(".sql")).map((f) => "supabase/migrations/" + f),
  ...["supabase/seed.sql", "supabase/seed-wave2.sql"].filter((f) => {
    try { readFileSync(join(root, f)); return true; } catch { return false; }
  }),
];
let bad = 0;
for (const f of files) {
  try {
    parse(readFileSync(join(root, f), "utf8"));
    console.log("OK   " + f);
  } catch (e) {
    bad++;
    console.log("FAIL " + f + ": " + String(e.message).split("\n").slice(0, 2).join(" | "));
  }
}
if (bad) { console.log(bad + " file(s) invalid"); process.exit(1); }
console.log("All SQL valid Postgres.");
