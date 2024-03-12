type KeyValues = "version" | "value" | "type" | "url" | "name"

interface ChildArray<QueryKey extends string, Child> {
  data: {
    [key in QueryKey]: Child[]
  }
}

interface KeyValueElement<KeyValue extends KeyValues> {
  ":@": {
    [key in KeyValue]: string
  }
}

type ConditionalKeyValue<KeyValue> = KeyValue extends KeyValues
  ? KeyValueElement<KeyValue>
  : {}

type XmlElement<
  QueryKey extends string,
  KeyValue extends KeyValues | undefined,
  Child
> = ChildArray<QueryKey, Child>["data"] & ConditionalKeyValue<KeyValue>

type Name = XmlElement<"name", "value", undefined>
type Type = XmlElement<"type", "value", undefined>
type Version = XmlElement<"version", "value", undefined>
type HomePath = XmlElement<"homePath", "value", undefined>
type Additional = XmlElement<"additional", undefined, undefined>

type Roots = XmlElement<"roots", undefined, undefined>
// Roots has missing children

type JdkChildren = Name | Type | Version | HomePath | Roots | Additional

type Component = XmlElement<"component", "name", JDK>
type JDK = XmlElement<"jdk", "version", JdkChildren>
type Application = XmlElement<"application", undefined, Component>

// We are missing the types for Everything below the roots element
