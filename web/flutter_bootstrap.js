{{flutter_js}}
{{flutter_build_config}}

const bootstrapUrl = new URL(document.currentScript.src);
const buildId = bootstrapUrl.searchParams.get('v');

if (buildId) {
  for (const build of _flutter.buildConfig.builds) {
    if (build.mainJsPath) {
      build.mainJsPath = `${build.mainJsPath}?v=${encodeURIComponent(buildId)}`;
    }
  }
}

_flutter.loader.load();
