A GitHub Action that uses manim to render videos

It runs on [the manim community docker image](https://github.com/ManimCommunity/manim/tree/main/docker).
This Action is based on [manim_action_renderer](https://github.com/manim-kindergarten/manim_action_renderer) by 
[manim-kindergarten](https://github.com/manim-kindergarten).

## Inputs

* `source_file`

    **Required**, the source file with the scenes you want to render (relative to the current repo).
    ```yaml
    - uses: pavelzw/manim_community_renderer@master
      with:
        source_file: path/to/your/file.py
    ```

* `scene_names`

    The name of the scenes to be rendered in the source file, in the form of a string. The default is to render all (with a `-a` flag). Multiple scenes need to be separated by spaces in `""` or write them in multiple lines:
    ```yaml
    - uses: pavelzw/manim_community_renderer@master
      with:
        source_file: path/to/your/file.py
        scene_names: |
          SceneName1
          SceneName2
    ```

* `args`

    The arguments passed to the manim command line. Usually controls the resolution of the exported video. The default is `-qp --progress_bar none` which means render at `1440p@60` without showing the progress bar in the logs.

* `extra_packages`

    Additional python modules that need to be used, use `pip` to install them. Use a space to separate every two or write them in multiple lines, e.g.: `"packageA packageB"` or :
    ```yaml
    - uses: pavelzw/manim_community_renderer@master
      with:
        extra_packages: |
          packageA
          packageB
    ```

* `extra_system_packages`

    The system packages that need to be used, use the `apk` to install them.

* `extra_repos`

    Extra repositories you want to clone to the current workspace. Use a space to separate every two repos, or write them in multiple lines.

* `pre_render`

    The shell command to be executed before rendering.

* `post_render`

    The shell command to be executed after rendering.

* `fonts_dir`

    The extra font files dir relative to the current repo. They will be installed automatically.

## Outputs

* `video_path`

    The directory (`./outputs/`) where all videos are stored after rendering is used to upload the results to artifacts.

## Example

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Rendering Scenes
        uses: pavelzw/manim_community_renderer@master
        id: renderer
        with:
          source_file: example_scenes.py
          scene_names: |
            OpeningManimExample
            WriteStuff
        args: "-qk"
      - name: Save output as artifacts
        uses: actions/upload-artifact@v2
        with:
          name: Videos
          path: ${{ steps.renderer.outputs.video_path }}
```

The final generated video file will be delivered to the artifacts part of the action running page.