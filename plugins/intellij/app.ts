import { inspect } from "util"

import { XMLParser, XMLBuilder } from "fast-xml-parser"
import * as fs from "fs"
import { Applications } from "./src/jdk-table-types"

// When does this script run?
// - devbox services up
// - init hook?
//     - check state?

// Does user jdktable exist?
// Does user jdktable contain project specific jdk?
// Is this JDK the correct version? (hasn't changed with branch/update)

// Does project file exist?
// Is this JDK the correct version? (hasn't changed with branch/update)

const getJdkChild = (key: string) => 

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
		const jdkTables: Applications = parser.parse(data)

		// console.log(jdkTables[0]["application"][0]["component"][0]["jdk"][0])

		// const injectedComponent = {
		// 	jdk: [
		// 		{
		// 			name: [],
		// 			":@": {
		// 				value: "foo-bar-baz",
		// 			},
		// 		},
		// 		{
		// 			roots: [

		// 			]
		// 		}
		// 	],
		// 	":@": { version: "2" },
		// }
		jdkTables[0].application[0].component[0].jdk.find()

		jdkTables[0]["application"][0]["component"] =
      jdkTables[0]["application"][0]["component"].concat(injectedComponent)

		console.log(jdkTables[0]["application"][0]["component"][0].jdk)

		const builder = new XMLBuilder(options)
		const xmlDataStr = builder.build(jdkTables)

		fs.writeFile("./output.xml", xmlDataStr, err => {
			if (err) throw err
		})
	}
)
