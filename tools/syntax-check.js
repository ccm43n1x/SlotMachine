const luaparse = require("luaparse");
const fs = require("fs");
const f = process.argv[2];
try {
  luaparse.parse(fs.readFileSync(f, "utf8"), {luaVersion: "5.1"});
  console.log("SYNTAX OK: " + f);
} catch (e) {
  console.log("SYNTAX FEHLER: " + e.message);
  process.exit(1);
}
