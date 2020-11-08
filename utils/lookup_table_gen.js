import fs from "fs";

const ratio = 1e4, // 1e8
  dig = Math.ceil(Math.log2(ratio)),
  getVal = (i) => Math.round(ratio / i) - 1,
  getRow = (i) => `8'd${i}: cnt <= ${dig}'d${getVal(i)}; \\\n`;

let temp = `\`define lookup \\\n`;
for (let i = 1; i <= 255; i++) temp += getRow(i);
temp = temp.trim().slice(0, -2);

let defines = fs.readFileSync("./modules/defines.sv", "utf8");
if (defines.includes("`define lookup"))
  defines = defines.slice(0, defines.search("`define lookup"));
defines = defines.trim() + "\n\n" + temp;
fs.writeFileSync("./modules/defines.sv", defines);
