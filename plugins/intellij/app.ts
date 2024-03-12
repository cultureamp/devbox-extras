import { inspect } from "util"

import { XMLParser, XMLBuilder } from "fast-xml-parser"
import * as fs from "fs"

const XMLData = fs.readFile(
  "/Users/tom.monaghan/Library/Application Support/JetBrains/IdeaIC2023.3/options/jdk.table.xml",
  (err, data) => {
    if (err) throw err
    const options = {
      ignoreAttributes: false,
      attributeNamePrefix: "",
      format: true,
      preserveOrder: true,
      suppressEmptyNode: true,
    }

    const parser = new XMLParser(options)
    var jdkTables = parser.parse(data)

    console.log(inspect(jdkTables, false, 1000, true))

    // console.log(jdkTables[0]["application"][0]["component"][0]["jdk"][0])
    const injectedComponent = {
      jdk: [
        {
          name: [],
          ":@": {
            value: "foo-bar-baz",
          },
        },
        {
          roots: [
           
          ]
        }
      ],
      ":@": { version: "2" },
    }

    jdkTables[0]["application"][0]["component"] =
      jdkTables[0]["application"][0]["component"].concat(injectedComponent)

    console.log(jdkTables[0]["application"][0]["component"][4]["jdk"][0])

    const builder = new XMLBuilder(options)
    let xmlDataStr = builder.build(jdkTables)

    fs.writeFile("./output.xml", xmlDataStr, err => {
      if (err) throw err
    })
  }
)
