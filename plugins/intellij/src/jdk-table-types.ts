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
const isName = (child: JdkChild): child is Name =>
  !!child.hasOwnProperty("name")

type Type = XmlElement<"type", "value", undefined>
const isType = (child: JdkChild): child is Type =>
  !!child.hasOwnProperty("type")

type Version = XmlElement<"version", "value", undefined>
const isVersion = (child: JdkChild): child is Version =>
  !!child.hasOwnProperty("version")

type HomePath = XmlElement<"homePath", "value", undefined>
const isHomePath = (child: JdkChild): child is HomePath =>
  !!child.hasOwnProperty("homePath")

type Additional = XmlElement<"additional", undefined, undefined>
const isAdditional = (child: JdkChild): child is Additional =>
  !!child.hasOwnProperty("additional")

type Roots = XmlElement<"roots", undefined, RootsChildren>
const isRoots = (child: JdkChild): child is Roots =>
  !!child.hasOwnProperty("roots")

type ParentRoot = XmlElement<"root", "type", ChildRoot>

type ChildRoot = {
  root: []
  ":@": {
    url: string
    type: string
  }
}

type RootsChildren = AnnotationsPath | ClassPath | SourcePath | JavaDocPath

type AnnotationsPath = XmlElement<"annotationsPath", undefined, ParentRoot>
const isAnnotationsPath = (child: RootsChildren): child is AnnotationsPath =>
  !!child.hasOwnProperty("annotationsPath")

type SourcePath = XmlElement<"sourcePath", undefined, ParentRoot>
const isSourcePath = (child: RootsChildren): child is SourcePath =>
  !!child.hasOwnProperty("sourcePath")

type ClassPath = XmlElement<"classPath", undefined, ParentRoot>
const isClassPath = (child: RootsChildren): child is ClassPath =>
  !!child.hasOwnProperty("classPath")

type JavaDocPath = XmlElement<"javaDocPath", undefined, ParentRoot>
const isJavaDocPath = (child: RootsChildren): child is JavaDocPath =>
  !!child.hasOwnProperty("javaDocPath")

export type JdkChild = Name | Type | Version | HomePath | Roots | Additional

type Component = XmlElement<"component", "name", Jdk>

type Jdk = XmlElement<"jdk", "version", JdkChild>

type Application = XmlElement<"application", undefined, Component>

export type Applications = Application[]

export const typeChecks = {
  jdkChildren: {
    isName,
    isType,
    isVersion,
    isHomePath,
    isAdditional,
    isRoots,
  },
  rootsChildren: {
    isAnnotationsPath,
    isSourcePath,
    isClassPath,
    isJavaDocPath,
  },
}
