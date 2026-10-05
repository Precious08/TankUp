// ONE-OFF (already run): demo.html's national RAW rows -> supabase/seed-wave2.sql.
// Kept for audit trail. Source of truth from here on is supabase/*.sql;
// demos consume generated data/stations.js (see build-stations.mjs).
import { readFileSync, writeFileSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const html = readFileSync(join(root, "demo.html"), "utf8");
const m = html.match(/const RAW = (\[[\s\S]*?\n\];)/);
if (!m) throw new Error("RAW block not found in demo.html");
const RAW = new Function("return (" + m[1].replace(/\];$/, "]") + ")")();

const FEXP = { P: ["Petrol"], PC: ["Petrol", "CNG"], PE: ["Petrol", "EV"], PCE: ["Petrol", "CNG", "EV"], C: ["CNG"], E: ["EV"] };
const q = (s) => "'" + String(s).replace(/'/g, "''") + "'";
const rows = RAW.map((r, i) => {
  const fuels = FEXP[r[7]];
  const pp = r[8], unit = r[9] || "/L", open = r[10] !== 0;
  const petrol = fuels.includes("Petrol") && unit === "/L" ? pp : "null";
  const cng = fuels.includes("CNG") && unit === "/SCM" ? pp : "null";
  const ev = fuels.includes("EV") && unit === "/kWh" ? pp : "null";
  const rate = (3.7 + ((100 + i) % 9) * 0.1).toFixed(1);
  const rc = 20 + ((100 + i) * 37) % 180;
  return ` (${q(r[0])},${q(r[1])},${q(r[2])},'',${q(r[3])},${q(r[4])},ST_GeogFromText('SRID=4326;POINT(${r[5]} ${r[6]})'),'${"{" + fuels.join(",") + "}"}',${petrol},${cng},${ev},${q(unit)},now(),${open},'{}',${q(open ? "Open 24 hrs" : "Closed · opens 6am")},${rate},${rc})`;
});

const sql = `-- TankUp seed wave 2 — national sample, 36 states + FCT (demo data, verify before launch; see seed-national.md).
-- Generated from the audited in-app dataset by scripts/extract-wave2.mjs — do not hand-edit rows.
-- Run after 0002_coverage.sql. To reseed cleanly: delete from stations; re-run seed.sql then this file.

insert into stations
  (name, state, lga, lcda, area, address, location, fuels, petrol_price, cng_price, ev_price,
   price_unit, price_updated_at, is_open, availability, hours, rating, review_count)
values
${rows.join(",\n")}
on conflict do nothing;
`;
writeFileSync(join(root, "supabase/seed-wave2.sql"), sql);
console.log("Wrote supabase/seed-wave2.sql with " + rows.length + " rows.");
