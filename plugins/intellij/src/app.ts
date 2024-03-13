import { XMLParser, XMLBuilder } from "fast-xml-parser"
import { writeFile, readFile } from "fs"
import { Applications, typeChecks } from "./jdk-table-types"

// When does this script run?
// - devbox services up
// - init hook?
//     - check state?

// Does user jdktable exist?
// Does user jdktable contain project specific jdk?
// Is this JDK the correct version? (hasn't changed with branch/update)

// Does project file exist?
// Is this JDK the correct version? (hasn't changed with branch/update)

// How often should this script run?
;(async () =>
  // fast-glob for /Users/tom.monaghan/Library/Application Support/JetBrains/*/options/jdk.table.xml

  await readFile(
    "/Users/tom.monaghan/Library/Application Support/JetBrains/IdeaIC2023.3/options/jdk.table.xml",
    async (err, data) => {
      if (err) throw err
      const options = {
        ignoreAttributes: false,
        attributeNamePrefix: "",
        format: true,
        preserveOrder: true,
        suppressEmptyNode: true,
      }

      const parser = new XMLParser(options)
      const jdkTables: Applications = parser.parse(data)

      const jdk = jdkTables[0].application[0].component[0].jdk

      const version = jdk.find(typeChecks.jdkChildren.isVersion)
      // const name = thing.find(typeChecks.jdkChildren.isName)

      // jdkTables[0]["application"][0]["component"] =
      //   jdkTables[0]["application"][0]["component"].concat(injectedComponent)

      // console.log(jdkTables[0]["application"][0]["component"][0].jdk)

      const builder = new XMLBuilder(options)
      const xmlDataStr = builder.build(jdkTables)

      await writeFile("./output.xml", xmlDataStr, err => {
        if (err) throw err
      })
    }
  ))()
