#!/bin/bash

set -e

info() {
  echo -e "\033[1;34m$1\033[0m"
}

warn() {
  echo "::warning :: $1"
}

error() {
  echo "::error :: $1"
  exit 1
}

source_file="${1}"
scene_names="${2}"
args="${3}"
manim_repo="${4}"
extra_packages="${5}"
extra_system_packages="${6}"
extra_repos="${7}"
pre_render="${8}"
post_render="${9}"
fonts_dir="${10}"

info "Copy source files to /manim"
cp -r * /manim
cd /manim

if [[ -z "$source_file" ]]; then
  error "Input 'source_file' is missing."
fi

if [[ -n $fonts_dir ]]; then
  info "Adding fonts..."
  cp -r "$fonts_dir" /usr/share/fonts/custom
  ls /usr/share/fonts/custom
  apt install fontconfig -y
  mkfontscale
  mkfontdir
  fc-cache -fv
fi

if [[ -n "$extra_system_packages" ]]; then
  for pkg in $extra_system_packages; do
    info "Installing $pkg by apk..."
    apk --no-cache add "$pkg"
  done
fi

if [[ -n "$extra_packages" ]]; then
  for pkg in $extra_packages; do
    info "Installing $pkg by pip..."
    python -m pip install "$pkg"
  done
fi

if [[ -n "$extra_repos" ]]; then
  for repo in $extra_repos; do
    info "Cloning $repo by git..."
    git clone "$repo" --depth=1
  done
fi

if [[ -n "$pre_render" ]]; then
  info "Run pre compile commands"
  eval "$pre_render"
fi

info "Rendering..."
for sce in $scene_names; do
  manim ${args[@]} "$source_file" $sce 
  if [ $? -ne 0 ]; then
    error "manim render error"
  fi
done

if [[ -n "$post_render" ]]; then
  info "Run post compile commands"
  eval "$post_render"
fi

info "Searching outputs..."
cnt=0
videos_path="/manim/media/videos"
for sce in $scene_names; do
  video=$(find ${videos_path} -name "${sce}.mp4" -o -name "${sce}.png")
  output[$cnt]=$video
  cnt=$cnt+1
done

mkdir /github/workspace/outputs/
for file in ${output[@]}; do
  info Copying $file into "/github/workspace/outputs/"
  cp $file "/github/workspace/outputs/"
done

echo "All ${#output[@]} outputs: ${output[@]}"
ls /github/workspace/outputs
echo "::set-output name=video_path::./outputs/*"
