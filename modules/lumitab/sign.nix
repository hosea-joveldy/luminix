{ writeShellApplication, web-ext, jq }:

writeShellApplication {
  name = "sign-lumitab";
  runtimeInputs = [ web-ext jq ];
  excludeShellChecks = [ "SC1091" ];
  text = ''
    set -a
    source "$HOME/.secrets/lumitab.env"
    set +a

    jq '.version |= (split(".") | .[-1] |= ((tonumber) + 1 | tostring) | join("."))' \
      manifest.json > manifest.tmp && mv manifest.tmp manifest.json

    web-ext sign --channel=unlisted \
      --api-key="$WEB_EXT_API_KEY" \
      --api-secret="$WEB_EXT_API_SECRET" \
      --artifacts-dir "$HOME/lab/lumitab-signed"
  '';
}
