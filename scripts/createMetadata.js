const fs = require("fs");
const path = require("path");

const tierCount = 4;
const rowCount = 5;
const columnCount = 5;
const tiers = ["Gold", "Silver", "Iron", "Bronce"];
const tierPieceDescriptions = [
  "Gold Piece Desc",
  "Silver Piece Desc",
  "Iron Piece Desc",
  "Bronce Piece Desc",
];

const tierPuzzleDescriptions = [
  "Gold Puzzle Desc",
  "Silver Puzzle Desc",
  "Iron Puzzle Desc",
  "Bronce Puzzle Desc",
];

fs.mkdirSync(path.join(__dirname, "/metadata/pieces"), { recursive: true });
fs.mkdirSync(path.join(__dirname, "/metadata/puzzles"), { recursive: true });

for (let t = 1; t <= tierCount; t++) {
  fs.writeFileSync(
    path.join(__dirname, `/metadata/puzzles/${t}.json`),
    JSON.stringify({
      image: `https://raw.githubusercontent.com/CastleNFT/castle-test-data/99f79cd00aae1135063c28a10633f3b3efdd7002/images/puzzles/${t}.png`,
      title: `${tiers[t - 1]} Puzzle`,
      description: tierPuzzleDescriptions[t - 1],
    })
  );
  for (let r = 1; r <= rowCount; r++) {
    for (let c = 1; c <= columnCount; c++) {
      const id =
        1 + (t - 1) * rowCount * columnCount + ((r - 1) * rowCount + (c - 1));
      fs.writeFileSync(
        path.join(__dirname, `/metadata/pieces/${id}.json`),
        JSON.stringify({
          image: `https://raw.githubusercontent.com/CastleNFT/castle-test-data/99f79cd00aae1135063c28a10633f3b3efdd7002/images/pieces/${id}.png`,
          title: `${tiers[t - 1]} Piece`,
          description: tierPieceDescriptions[t - 1],
        })
      );
    }
  }
}
