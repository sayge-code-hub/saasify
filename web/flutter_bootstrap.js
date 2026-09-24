{{flutter_js}}
{{flutter_build_config}}

// Avoid service-worker caching of stale/broken assets (common “blank app” cause).
_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine({
      // Prefer local CanvasKit shipped with the build.
      canvasKitBaseUrl: "canvaskit/",
    });
    await appRunner.runApp();
  },
});
