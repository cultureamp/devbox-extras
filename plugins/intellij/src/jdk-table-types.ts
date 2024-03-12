type Application = {
  application: Component[]
}

type KeyValues = {
  version?: string
  value?: string
  type?: string
  url?: string
  name?: string
}

type Component = {
  component: Jdk[]
  ":@": Pick<KeyValues, "name">
}

type Jdk = {
  jdk: JdkChildren[]
  ":@": Pick<KeyValues, "version">
}

type JdkChildren = Name | Type | Version | HomePath | Roots | Additional

type Name = {
  name: []
  ":@": Pick<KeyValues, "value">
}

type Type = {
  type: []
  ":@": Pick<KeyValues, "value">
}

type Version = {
  version: []
  ":@": Pick<KeyValues, "value">
}

type HomePath = {
  homePath: []
  ":@": Pick<KeyValues, "value">
}

type Roots = {
  roots: []
}

type Additional = {
  additional: []
}

export type JdkTable = Application[]

const jdkTable: JdkTable = [
  {
    application: [
      {
        component: [
          {
            jdk: [],
            ":@": {
              version: "2",
            },
          },
        ],
        ":@": {
          name: "11",
        },
      },
    ],
  },
]
