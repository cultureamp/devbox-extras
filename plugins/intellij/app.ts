const { XMLParser, XMLBuilder } = require("fast-xml-parser");
import * as fs from 'fs';

const XMLData = fs.readFile("/Users/tom.monaghan/Library/Application Support/JetBrains/IdeaIC2023.3/options/jdk.table.xml", (err, data) => {
  if (err) throw err;
  const options = {
    ignoreAttributes: false,
    attributeNamePrefix: "@_"
  }
  const parser = new XMLParser(options);
  let jObj = parser.parse(data)
  console.log(jObj["application"]["component"]["jdk"][0]["roots"]["classPath"]["root"])
})
