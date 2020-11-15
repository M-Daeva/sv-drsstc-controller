const l = console.log.bind(console);

const dec = [127, 30, 87, 10, 1, 127, 30];

let res = dec
  .reduce((acc, cur) => {
    let num = Number(cur).toString(2).split("").reverse().join("");
    while (num.length !== 8) num += "0";
    return acc + "_10_" + num;
  }, "")
  .slice(2);

l(`${res.replace(/_/g, "").length}'b${res}`);
