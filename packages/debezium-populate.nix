# Regenerate `npmDepsHash` after any change to `package-lock.json` with:
# `nix run nixpkgs#prefetch-npm-deps -- plugins/debezium-server/populate/package-lock.json`

{ buildNpmPackage, nodejs_24 }:

buildNpmPackage {
  pname = "debezium-populate";
  version = "1.0.0";

  src = ../plugins/debezium-server/populate;

  npmDepsHash = "sha256-gus8j4NRIy+B4XYFlMdfk6hQg+MnyXzOcPabcxk97x4=";

  # `populate.mjs` is plain ESM JavaScript run directly by node. There is no
  # build step: no bundler, no transpile, no committed artefact.
  #
  # It was TypeScript, run through `ts-node`. Node can strip type annotations
  # natively now, but explicitly refuses to do so for files under a
  # `node_modules` directory (ERR_UNSUPPORTED_NODE_MODULES_TYPE_STRIPPING), and
  # buildNpmPackage installs to `$out/lib/node_modules/<name>/`. Keeping `.ts`
  # would therefore have required adding a transpile step back, so the four type
  # annotations were dropped instead. `tsconfig.json` is retained with
  # `checkJs` so editors and an ad-hoc `npx tsc --noEmit` still typecheck it.
  dontNpmBuild = true;

  # Pinned rather than inherited from the consuming project: the wrapper below
  # is the only thing that ever runs this node.
  nodejs = nodejs_24;

  # The `bin` entry in package.json makes buildNpmPackage emit
  # `$out/bin/debezium-populate`, a makeWrapper shim around
  # `${nodejs_24}/bin/node $out/lib/node_modules/debezium-populate/populate.mjs`.
  # Node therefore never lands on PATH, only this one executable does.
  meta = {
    description = "Seeds Avro-encoded sample rows into a Debezium outbox table";
    mainProgram = "debezium-populate";
  };
}
