const fs = require('fs')

function read() {
    const jsonString = fs.readFileSync("data.json", "utf8");
    const obj = JSON.parse(jsonString);
    console.log(typeof(obj))
    console.log("inside fucntion",obj)
    return obj;
}

function write(data) {
  fs.writeFileSync("./data.json", JSON.stringify(data), (err) => {
    if (err) console.log("Error writing file:", err);
  });
}

function isConfigured() {
  data = read();
  if (!data.configured) {
    return false;
  }
}

function test() {
    x = read()
    console.log("outside function",x)
}


test()
