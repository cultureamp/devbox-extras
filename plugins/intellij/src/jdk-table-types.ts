// NOTE: May need to export injected types if inferring not working

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

type ParentRoot = XmlElement<"root", "type", ChildRoot> 

type ChildRoot = {
  root: []  
  ":@": {
    url: string
    type: string
  }
}

type Roots = XmlElement<"roots", undefined, RootsChildren>

type RootsChildren = AnnotationsPath | ClassPath | SourcePath | JavaDocPath

type AnnotationsPath = XmlElement<"annotationsPath", undefined, ParentRoot>

type SourcePath = XmlElement<"sourcePath", undefined, ParentRoot>

type ClassPath = XmlElement<"classPath", undefined, ParentRoot>

type JavaDocPath = XmlElement<"javaDocPath", undefined, ParentRoot>

type JdkChildren = Name | Type | Version | HomePath | Roots | Additional

type Component = XmlElement<"component", "name", Jdk>

type Jdk = XmlElement<"jdk", "version", JdkChildren>

type Application = XmlElement<"application", undefined, Component>

export type Applications = Application[]
