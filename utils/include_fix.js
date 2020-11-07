/**
 * moves files from ./src to ./dist importing modules from ./modules
 * and adding id's to prevent include duplication error
 */
/*
import fs from "fs";

const l = console.log.bind(console);
const getID = () => (Date.now() + "" + Math.random()).replace(".", "");

const folders = { src: "./src", dist: "./dist", mod: "./modules" };

const files = fs.readdirSync(folders.src);

for (let file of files) {
  // get src file
  const src_text = fs.readFileSync(`${folders.src}/${file}`, "utf8");
  const re = /`include "\.\/modules\/((\w+)\.s?v)"/g;

  let repl;
  const id = getID();

  try {
    // create dist file
    let dist_text = src_text.replace(re, (match, fileName, moduleName) => {
      repl = { key: moduleName, val: `${moduleName}_${id} ` };
      //l({ match, fileName, moduleName });
      // skip defines
      if (moduleName === "defines") return match;

      // open import file
      const imp = fs.readFileSync(`${folders.mod}/${fileName}`, "utf8");

      return imp.replace(repl.key, repl.val).trim();
    });

    let reG = new RegExp(`${repl.key} `, "g");
    l(reG);
    dist_text = dist_text.replace(reg, repl.val);
    //dist_text = dist_text.replace(/pwm /g, "pwm_hash");
    let a = dist_text.search(/pwm #/g);
    if (a !== -1) l(a, file, reG);

    fs.writeFileSync(`${folders.dist}/${file}`, dist_text);
  } catch {
    fs.writeFileSync(`${folders.dist}/${file}`, src_text);
  }
}
*/

import fs from "fs";

const l = console.log.bind(console);
const getID = () => (Date.now() + "" + Math.random()).replace(".", "");

const folders = { src: "./src", dist: "./dist", mod: "./modules" };

const files = fs.readdirSync(folders.src);

for (let file of files) {
  // get src file
  const src_text = fs.readFileSync(`${folders.src}/${file}`, "utf8");
  let dist_text;

  const re = /`include "\.\/modules\/\w+\.sv"/g;

  let ms = src_text.match(re);

  // skip if no includes
  if (ms === null) {
    fs.writeFileSync(`${folders.dist}/${file}`, src_text);
    continue;
  }

  let names = ms.map((item) => item.match(/(\w+).sv/)[1]);

  //skip if include defines only
  if (names.filter((item) => item !== "defines").length === 0) {
    fs.writeFileSync(`${folders.dist}/${file}`, src_text);
    continue;
  }

  // replace modules calls
  const id = getID();
  dist_text = src_text;
  names.forEach((name) => {
    if (name !== "defines") {
      let re = new RegExp(`${name} `, "g");
      dist_text = dist_text.replace(re, `${name}_${id} `);

      // open import file
      let imp = fs.readFileSync(`${folders.mod}/${name}.sv`, "utf8");

      imp = imp.replace(name, `${name}_${id}`);
      // l(imp);
      dist_text =
        '`include "./modules/defines.sv"\n' +
        dist_text
          .replace(`\`include "./modules/${name}.sv"`, imp)
          .replace(new RegExp('`include "./modules/defines.sv"', "g"), "")
          .trim();
    }
  });

  fs.writeFileSync(`${folders.dist}/${file}`, dist_text);
}
